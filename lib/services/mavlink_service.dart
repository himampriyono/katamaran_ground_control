import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dart_mavlink/mavlink.dart';
import 'package:dart_mavlink/dialects/common.dart';
import 'package:flutter/services.dart';
import '../data/app_data.dart';
import '../data/mavlink_data.dart';
import '../models/mav_parameter.dart';
import '../utils/app_utils.dart';
import 'mavlink_server_service.dart';
import 'mission_service.dart';
import 'notifier_service.dart';
import '../widgets/snackbar.dart';

class MavlinkService {
  // MavlinkService._internal();

  factory MavlinkService() => instance;
  static final MavlinkService instance = MavlinkService._internal();
  MavlinkService._internal() {
    _initLocalServer();
  }

  void _initLocalServer() {
    MavlinkServerService.instance.startServer();
  }

  static RawDatagramSocket? udpSocket;
  late MavlinkParser _parser;

  static int sequence = 1;
  static bool isSending = false;
  static Timer? _gcsSchedulerTimer;
  static int _schedulerTicks = 0;
  static Timer? _linkStatsTimer;
  static int _pingSequence = 0;
  static final Map<int, int> _pendingPings = {};
  static Timer? _connectionMonitorTimer;

  static final Queue<MavlinkFrame> sendQueue = Queue<MavlinkFrame>();

  bool _lastConnectionSat = false;

  static Completer<bool>? _parameterWriteCompleter;
  static String? _waitingParameterName;
  static double? _waitingParameterValue;

  Future<void> connect({required String host, required int port}) async {
    try {
      debugPrint("Connecting to port $port");
      udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 14550);
      udpSocket!.send(Uint8List(0), InternetAddress(host), port);
      debugPrint("Connecting to $host:$port");
      debugPrint("Local Port : ${udpSocket!.port}");
      // debugPrint("Connected to port $port");
      _startLinkStatistics();
      MavlinkData.reset();
      NotifierService.triggerConnectionUpdate();

      _parser = MavlinkParser(MavlinkDialectCommon());
      udpSocket?.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? dg = udpSocket?.receive();
          if (dg != null) {
            MavlinkData.currentHost = dg.address.address;
            MavlinkData.currentPort = dg.port;
            _parser.parse(dg.data);
          }
        }
      });

      _parser.stream.listen((MavlinkFrame frame) {
        _handleIncomingFrame(frame);
      });

      _connectionMonitorTimer?.cancel();

      _connectionMonitorTimer = Timer.periodic(const Duration(seconds: 1), (
        timer,
      ) {
        if (udpSocket == null) {
          timer.cancel();
          _stopGcsScheduler();
          return;
        }

        final now = DateTime.now();
        final last = MavlinkData.lastPacketReceivedTime;
        final bool connected =
            last != null && now.difference(last).inSeconds <= 5;
        MavlinkData.isMavlinkConnected = connected;

        if (connected != _lastConnectionSat) {
          _lastConnectionSat = connected;
          if (connected) {
            debugPrint("Connected!");
            _startGcsScheduler();
            Snackbar.show("Mavlink Connected!");
            debugPrint(
              "Target = "
              "${MavlinkData.targetSystemId} "
              "${MavlinkData.targetComponentId}",
            );
            Future.delayed(const Duration(milliseconds: 500), () {
              MavlinkService.requestHomePosition();
              MavlinkService.configureTelemetry();
            });
          } else {
            debugPrint("Disconnected!");
            _stopGcsScheduler();
            Snackbar.show("Mavlink Disconnected!", isWarning: true);
          }
          NotifierService.triggerConnectionUpdate();
        }
      });
    } catch (e) {
      debugPrint("Error connecting to UDP socket: $e");
    }
  }

  void _handleIncomingFrame(MavlinkFrame frame) {
    MavlinkData.lastPacketReceivedTime = DateTime.now();
    MavlinkData.packetsThisSecond++;

    final message = frame.message;
    // debugPrint("MSG ${message.runtimeType} (${message.mavlinkMessageId})");

    if (message is Heartbeat) {
      if (message.customMode != MavlinkData.lastHeartbeat?.customMode) {
        NotifierService.triggerConnectionUpdate();
      }
      MavlinkData.lastHeartbeat = message;
      MavlinkData.targetSystemId = frame.systemId;
      MavlinkData.targetComponentId = frame.componentId;
      final bool isArmed = (message.baseMode & 128) != 0;
      if (MavlinkData.isArmed != isArmed) {
        MavlinkData.isArmed = isArmed;
        NotifierService.triggerConnectionUpdate();
      }

      if (!MavlinkData.isMavlinkConnected) {
        MavlinkData.isMavlinkConnected = true;
        NotifierService.triggerConnectionUpdate();
      }
    } else if (message is Attitude) {
      MavlinkData.lastAttitude = message;
      NotifierService.triggerAttitudeUpdate();
    } else if (message is GlobalPositionInt) {
      MavlinkData.lastGlobalPositionInt = message;
      NotifierService.triggerPositionUpdate();
      if (MavlinkData.gotoTarget != null) {
        checkGotoArrival();
      }
      final double lat = message.lat / 1e7;
      final double lon = message.lon / 1e7;
      // Heading di GlobalPositionInt biasanya dalam centi-degrees (0 - 36000), ubah ke derajat (0 - 360)
      // Jika heading bernilai 65535 (UINT16_MAX), artinya heading tidak valid/tidak tersedia, bisa di-fallback ke 0 atau ambil dari VfrHud.
      final double heading = (message.hdg != 65535)
          ? message.hdg / 100.0
          : 0.0;
      MavlinkServerService.instance.broadcastVesselState(lat, lon, heading);
    } else if (message is SysStatus) {
      MavlinkData.lastSysStatus = message;
      NotifierService.triggerStatusUpdate();
    } else if (message is VfrHud) {
      MavlinkData.lastVfrHud = message;
      NotifierService.triggerVfrUpdate();
    } else if (message is GpsRawInt) {
      MavlinkData.lastGpsRawInt = message;
      NotifierService.triggerGpsUpdate();
    } else if (message is HomePosition) {
      MavlinkData.lastHomePosition = message;
      NotifierService.triggerHomeUpdate();
    } else if (message is Ping) {
      debugPrint(
        "PING RX: "
        "seq=${message.seq}, "
        "time=${message.timeUsec}, "
        "targetSys=${message.targetSystem}, "
        "targetComp=${message.targetComponent}",
      );
    } else if (message is RcChannels) {
      MavlinkData.rcChannels[0] = message.chan1Raw;
      MavlinkData.rcChannels[1] = message.chan2Raw;
      MavlinkData.rcChannels[2] = message.chan3Raw;
      MavlinkData.rcChannels[3] = message.chan4Raw;
      MavlinkData.rcChannels[4] = message.chan5Raw;
      MavlinkData.rcChannels[5] = message.chan6Raw;
      MavlinkData.rcChannels[6] = message.chan7Raw;
      MavlinkData.rcChannels[7] = message.chan8Raw;
      MavlinkData.rcChannels[8] = message.chan9Raw;
      MavlinkData.rcChannels[9] = message.chan10Raw;
      MavlinkData.rcChannels[10] = message.chan11Raw;
      MavlinkData.rcChannels[11] = message.chan12Raw;
      MavlinkData.rcChannels[12] = message.chan13Raw;
      MavlinkData.rcChannels[13] = message.chan14Raw;
      MavlinkData.rcChannels[14] = message.chan15Raw;
      MavlinkData.rcChannels[15] = message.chan16Raw;
      NotifierService.triggerRcUpdate();
    } else if (message is ServoOutputRaw) {
      MavlinkData.pwmOutput[0] = message.servo1Raw;
      MavlinkData.pwmOutput[1] = message.servo2Raw;
      MavlinkData.pwmOutput[2] = message.servo3Raw;
      MavlinkData.pwmOutput[3] = message.servo4Raw;
      MavlinkData.pwmOutput[4] = message.servo5Raw;
      MavlinkData.pwmOutput[5] = message.servo6Raw;
      MavlinkData.pwmOutput[6] = message.servo7Raw;
      MavlinkData.pwmOutput[7] = message.servo8Raw;
      MavlinkData.pwmOutput[8] = message.servo9Raw;
      MavlinkData.pwmOutput[9] = message.servo10Raw;
      MavlinkData.pwmOutput[10] = message.servo11Raw;
      MavlinkData.pwmOutput[11] = message.servo12Raw;
      MavlinkData.pwmOutput[12] = message.servo13Raw;
      MavlinkData.pwmOutput[13] = message.servo14Raw;
      MavlinkData.pwmOutput[14] = message.servo15Raw;
      MavlinkData.pwmOutput[15] = message.servo16Raw;
      NotifierService.triggerPwmUpdate();
    } else if (message is ActuatorOutputStatus) {
      debugPrint(message.toString());
    } else if (message is ParamValue) {
      final name = AppUtils.charListToString(message.paramId);

      MavlinkData.parameters[name] = MavParameter(
        name: name,
        value: message.paramValue,
        type: message.paramType,
      );

      MavlinkData.parameterLoaded = message.paramIndex + 1;
      MavlinkData.parameterCount = message.paramCount;

      if (message.paramIndex + 1 == message.paramCount) {
        MavlinkData.isLoadingParameters = false;
        NotifierService.triggerParameterUpdate();
        debugPrint(
          "Parameter loaded successfully (${MavlinkData.parameterCount} parameter)",
        );
      }
      NotifierService.triggerParameterUpdate();
      if (_parameterWriteCompleter != null) {
        if (name == _waitingParameterName &&
            message.paramValue == _waitingParameterValue) {
          _parameterWriteCompleter!.complete(true);
          _parameterWriteCompleter = null;
          _waitingParameterName = null;
          _waitingParameterValue = null;
        }
      }
    } else if (message is MissionCount) {
      MissionService.handleMissionCount(message);
    } else if (message is MissionItemInt) {
      MissionService.handleMissionItem(message);
    } else if (message is MissionRequest) {
      debugPrint("[RX] MissionRequestInt seq=${message.seq}");
      MissionService.handleMissionRequest(message);
      // } else if (message is MissionRequest) {
      //   debugPrint("Dapat miss req");
      // debugPrint("[RX] MissionRequestInt seq=${message.seq}");
      // MissionService.handleMissionRequestInt(message);
    } else if (message is MissionAck) {
      MissionService.handleMissionAck(message);
    } else if (message is MissionCurrent) {
      MavlinkData.lastMissionCurrent = message;
      NotifierService.triggerMissionUpdate();
    }
  }

  static void sendCommandLong({
    required int command,
    double param1 = 0,
    double param2 = 0,
    double param3 = 0,
    double param4 = 0,
    double param5 = 0,
    double param6 = 0,
    double param7 = 0,
    int confirmation = 0,
  }) {
    final targetSys = MavlinkData.targetSystemId ?? 1;
    final targetComp = MavlinkData.targetComponentId ?? 1;

    final msg = CommandLong(
      targetSystem: targetSys,
      targetComponent: targetComp,
      command: command,
      confirmation: confirmation,
      param1: param1,
      param2: param2,
      param3: param3,
      param4: param4,
      param5: param5,
      param6: param6,
      param7: param7,
    );
    _queueMessage(msg);
    debugPrint("CMD $command -> sys=$targetSys comp=$targetComp");
  }

  static void _queueMessage(MavlinkMessage message) {
    if (udpSocket == null) {
      debugPrint("Cant send command");
      return;
    }

    final frame = MavlinkFrame.v2(sequence, 255, mavTypeGcs, message);
    sequence = (sequence + 1) % 256;
    sendQueue.add(frame);
    processSendQueue();
  }

  static Future<void> processSendQueue() async {
    if (isSending || sendQueue.isEmpty) {
      return;
    }

    if (udpSocket == null) {
      return;
    }

    isSending = true;

    try {
      final frame = sendQueue.removeFirst();
      final dataToSend = frame.serialize();

      if (udpSocket != null) {
        try {
          udpSocket!.send(
            dataToSend,
            InternetAddress(MavlinkData.currentHost),
            MavlinkData.currentPort,
          );
        } catch (e) {
          debugPrint("Error: $e");
          sendQueue.clear();
        }
      }
    } catch (e) {
      debugPrint("Error queuing: $e");
    } finally {
      isSending = false;

      if (sendQueue.isNotEmpty) {
        Future.microtask(() => processSendQueue());
      }
    }
  }

  static void _startGcsScheduler() {
    _gcsSchedulerTimer?.cancel();
    _schedulerTicks = 0;
    debugPrint("gcsSchedule start");
    sendGcsHeartbeat();

    _gcsSchedulerTimer = Timer.periodic(const Duration(milliseconds: 250), (
      timer,
    ) {
      // debugPrint("Scheduler Tick");
      if (udpSocket == null) {
        _stopGcsScheduler();
        return;
      }

      if (AppData.joystickStatus.value == JoystickStatus.connected) {
        sendRcOverride();
      }

      if (_schedulerTicks % 4 == 0) {
        sendGcsHeartbeat();
        // sendPingRequest();
        // sendTimesyncRequest;
      }

      _schedulerTicks = (_schedulerTicks + 1) % 4;
    });
  }

  static void _stopGcsScheduler() {
    _gcsSchedulerTimer?.cancel();
    _gcsSchedulerTimer = null;
  }

  static void _startLinkStatistics() {
    _linkStatsTimer?.cancel();

    _linkStatsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      MavlinkData.packetsPerSecond = MavlinkData.packetsThisSecond;

      MavlinkData.packetsThisSecond = 0;

      NotifierService.triggerConnectionUpdate();
    });
  }

  Future<void> disconnect() async {
    debugPrint("Disconnecting...");

    _stopGcsScheduler();
    MavlinkServerService.instance.stopServer();

    udpSocket?.close();
    udpSocket = null;

    MavlinkData.reset();
    MavlinkData.isMavlinkConnected = false;
    _linkStatsTimer?.cancel();
    _linkStatsTimer = null;

    _lastConnectionSat = false;
    _connectionMonitorTimer?.cancel();
    _connectionMonitorTimer = null;
    NotifierService.triggerConnectionUpdate();

    Snackbar.show("Mavlink Disconnected!", isWarning: true);
  }

  // ==== === =====

  static void setMessageRate({required int messageId, required double rateHz}) {
    if (rateHz <= 0) return;

    sendCommandLong(
      command: mavCmdSetMessageInterval,
      param1: messageId.toDouble(),
      param2: 1000000.0 / rateHz,
    );
  }

  static void configureTelemetry() {
    debugPrint("Configuring message rate");

    setMessageRate(messageId: MavMessages.attitude, rateHz: 5);
    setMessageRate(messageId: MavMessages.globalPositionInt, rateHz: 5);
    setMessageRate(messageId: MavMessages.sysStatus, rateHz: 2);
    setMessageRate(messageId: MavMessages.vfrHud, rateHz: 2);
    setMessageRate(messageId: 375, rateHz: 2);
  }

  static void sendGcsHeartbeat() {
    if (udpSocket == null) return;

    final msg = Heartbeat(
      type: mavTypeGcs,
      autopilot: 8, // MAV_AUTOPILOT_INVALID
      baseMode: 0,
      customMode: 0,
      systemStatus: 4, // MAV_STATE_ACTIVE
      mavlinkVersion: 2,
    );

    _queueMessage(msg);
  }

  static void sendTimesyncRequest() {
    if (udpSocket == null) return;

    final targetSys = MavlinkData.targetSystemId ?? 1;
    final targetComp = MavlinkData.targetComponentId ?? 1;

    final msg = Timesync(
      tc1: 0,
      ts1: DateTime.now().microsecondsSinceEpoch,
      targetSystem: targetSys,
      targetComponent: targetComp,
    );

    debugPrint(
      "TIMESYNC TX "
      "tc1=0 "
      "ts1=${msg.ts1}",
    );

    _queueMessage(msg);
  }

  static void requestHomePosition() {
    debugPrint("Requesting home position...");

    sendCommandLong(
      command: mavCmdRequestMessage, // MAV_CMD_REQUEST_MESSAGE
      param1: 242, // ID Paket MAVLink untuk HOME_POSITION
    );
  }

  static void setMode(int modeNum) {
    debugPrint("Sending setMode command to cmd id: $modeNum");

    sendCommandLong(
      command: mavCmdDoSetMode,
      param1: 1.0,
      param2: modeNum.toDouble(),
    );
  }

  static void sendRcOverride() {
    if (udpSocket == null) return;

    final targetSys = MavlinkData.targetSystemId ?? 1;
    final targetComp = MavlinkData.targetComponentId ?? 1;

    final channels = AppData.joystickChannels.value;

    // debugPrint("RC: ${channels.join(', ')}");
    final msg = RcChannelsOverride(
      targetSystem: targetSys,
      targetComponent: targetComp,
      chan1Raw: channels[0],
      chan2Raw: channels[1],
      chan3Raw: channels[2],
      chan4Raw: channels[3],
      chan5Raw: channels[4],
      chan6Raw: channels[5],
      chan7Raw: channels[6],
      chan8Raw: channels[7],
      chan9Raw: channels[8],
      chan10Raw: channels[9],
      chan11Raw: channels[10],
      chan12Raw: channels[11],
      chan13Raw: channels[12],
      chan14Raw: channels[13],
      chan15Raw: channels[14],
      chan16Raw: channels[15],
      chan17Raw: 0,
      chan18Raw: 0,
    );

    _queueMessage(msg);
  }

  static void requestParameterList() {
    if (udpSocket == null) {
      return;
    }

    debugPrint("Requesting Parameter list...");

    MavlinkData.parameters.clear();
    MavlinkData.parameterLoaded = 0;
    MavlinkData.parameterCount = 0;
    MavlinkData.isLoadingParameters = true;

    NotifierService.triggerParameterUpdate();

    final msg = ParamRequestList(
      targetSystem: MavlinkData.targetSystemId ?? 1,
      targetComponent: MavlinkData.targetComponentId ?? 1,
    );

    _queueMessage(msg);
  }

  static void requestParameter(String parameterName) {
    if (udpSocket == null) {
      return;
    }

    final msg = ParamRequestRead(
      paramIndex: -1,
      targetSystem: MavlinkData.targetSystemId ?? 1,
      targetComponent: MavlinkData.targetComponentId ?? 1,
      paramId: AppUtils.stringToCharList(parameterName),
    );

    _queueMessage(msg);

    debugPrint("Requesting parameter: $parameterName");
  }

  static Future<bool> setParameter(MavParameter parameter, double value) async {
    if (udpSocket == null) {
      return false;
    }

    if (_parameterWriteCompleter != null) {
      return false;
    }

    _parameterWriteCompleter = Completer<bool>();
    _waitingParameterName = parameter.name;
    _waitingParameterValue = value;

    final msg = ParamSet(
      paramValue: value,
      targetSystem: MavlinkData.targetSystemId ?? 1,
      targetComponent: MavlinkData.targetComponentId ?? 1,
      paramId: AppUtils.stringToCharList(parameter.name),
      paramType: mavParamTypeReal32,
    );

    debugPrint("TX Paramset: $parameter.name = $value");
    _queueMessage(msg);

    Future.delayed(const Duration(seconds: 2), () {
      if (_parameterWriteCompleter != null &&
          !_parameterWriteCompleter!.isCompleted) {
        _parameterWriteCompleter!.complete(false);
        _parameterWriteCompleter = null;
        _waitingParameterName = null;
        _waitingParameterValue = null;
      }
    });

    return _parameterWriteCompleter!.future;
  }

  static void requestMissionList() {
    final message = MissionRequestList(
      targetSystem: MavlinkData.targetSystemId ?? 1,
      targetComponent: MavlinkData.targetComponentId ?? 1,
      missionType: mavMissionTypeMission,
    );

    _queueMessage(message);
  }

  static void requestMissionItem(int sequence) {
    final message = MissionRequestInt(
      seq: sequence,
      targetSystem: MavlinkData.targetSystemId ?? 1,
      targetComponent: MavlinkData.targetComponentId ?? 1,
      missionType: mavMissionTypeMission,
    );

    _queueMessage(message);
    debugPrint("Request Mission Item $sequence");
  }

  static void sendMissionCount({
    required int targetSystem,
    required int targetComponent,
    required int count,
  }) {
    final packet = MissionCount(
      targetSystem: targetSystem,
      targetComponent: targetComponent,
      count: count,
      missionType: mavMissionTypeMission,
      opaqueId: 0,
    );

    _queueMessage(packet);
  }

  static void sendMissionitemInt({
    required MissionItem mission,
    required int targetSystem,
    required int targetComponent,
  }) {
    final packet = MissionItemInt(
      param1: mission.param1,
      param2: mission.param2,
      param3: mission.param3,
      param4: mission.param4,
      x: (mission.x * 1e7).round(),
      y: (mission.y * 1e7).round(),
      z: mission.z,
      seq: mission.seq,
      command: mission.command,
      targetSystem: targetSystem,
      targetComponent: targetComponent,
      frame: mission.frame,
      current: mission.current,
      autocontinue: mission.autocontinue,
      missionType: mission.missionType,
    );
    // debugPrint("[Mission] Sending item ${mission.seq}");
    debugPrint("[Mission] Sending item ${mission.seq}");
    debugPrint(
      "[Mission] Sending seq=${mission.seq}, "
      "cmd=${mission.command}, "
      "lat=${mission.x}, "
      "lon=${mission.y}",
    );

    _queueMessage(packet);
  }

  static void sendGoto({required double latitude, required double longitude}) {
    final guided = 15;

    if (MavlinkData.lastHeartbeat?.customMode != guided) {
      setMode(guided);
    }

    final message = CommandInt(
      param1: -1,
      param2: 0,
      param3: 0,
      param4: double.nan,
      x: (latitude * 1e7).round(),
      y: (longitude * 1e7).round(),
      z: 0,
      command: mavCmdDoReposition,
      targetSystem: MavlinkData.targetSystemId ?? 1,
      targetComponent: MavlinkData.targetComponentId ?? 1,
      frame: mavFrameGlobalRelativeAltInt,
      current: 0,
      autocontinue: 0,
    );

    _queueMessage(message);
  }

  void checkGotoArrival() {
    final loiter = 5;
    final circle = 9;
    final distance = AppUtils.calculateDistance(
      MavlinkData.lastGlobalPositionInt!.lat / 1e7,
      MavlinkData.lastGlobalPositionInt!.lon / 1e7,
      MavlinkData.gotoTarget!.latitude,
      MavlinkData.gotoTarget!.longitude,
    );

    if (distance < 7) {
      MavlinkData.gotoTarget = null;

      if (AppData.gotoAction == GotoMenuAction.circleHere) {
        MavlinkService.setMode(circle);
      } else if (AppData.gotoAction == GotoMenuAction.goHere) {
        MavlinkService.setMode(loiter);
      }
    }
  }
}
