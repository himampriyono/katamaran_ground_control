import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dart_mavlink/mavlink.dart';
import 'package:dart_mavlink/dialects/common.dart';
import '../data/app_data.dart';
import '../data/mavlink_data.dart';
import 'notifier_service.dart';
import '../widgets/snackbar.dart';

class MavlinkService {
  MavlinkService._internal();

  factory MavlinkService() => instance;
  static final MavlinkService instance = MavlinkService._internal();
  static RawDatagramSocket? udpSocket;
  final MavlinkParser _parser = MavlinkParser(MavlinkDialectCommon());

  static int sequence = 1;
  static bool isSending = false;
  static Timer? _gcsSchedulerTimer;
  static int _schedulerTicks = 0;
  static Timer? _linkStatsTimer;
  static int _pingSequence = 0;
  static final Map<int, int> _pendingPings = {};

  static final Queue<MavlinkFrame> sendQueue = Queue<MavlinkFrame>();

  bool _lastConnectionSat = false;

  Future<void> connect(int port) async {
    try {
      debugPrint("Connecting to port $port");
      udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
      debugPrint("Connected to port $port");
      _startLinkStatistics();
      MavlinkData.reset();
      NotifierService.triggerConnectionUpdate();

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

      Timer.periodic(const Duration(seconds: 1), (timer) {
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
            Future.delayed(const Duration(milliseconds: 500), () {
              MavlinkService.requestHomePosition();
              MavlinkService.configureTelemetry();
            });
          } else {
            debugPrint("Disconnected!");
            _startGcsScheduler();
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
    } else if (message is SysStatus) {
      MavlinkData.lastSysStatus = message;
      NotifierService.triggerStatusUpdate();
    } else if (message is VfrHud) {
      MavlinkData.lastVfrHud = message;
      NotifierService.triggerVfrUpdate();
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
    // } else if (message is Timesync) {
    //   debugPrint(
    //     "TIMESYNC RX "
    //     "tc1=${message.tc1} "
    //     "ts1=${message.ts1}",
    //   );

    //   if (message.tc1 == 0) {
    //     final now = DateTime.now().microsecondsSinceEpoch;

    //     debugPrint(
    //       "TIMESYNC REPLY "
    //       "tc1=$now "
    //       "ts1=${message.ts1}"
    //       "TIMESYNC from sys=${frame.systemId}"
    //       "comp=${frame.componentId}",
    //     );

    //     final reply = Timesync(
    //       tc1: now,
    //       ts1: message.ts1,
    //       targetSystem: frame.systemId,
    //       targetComponent: frame.componentId,
    //     );

    //     _queueMessage(reply);
    //   }
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
    debugPrint("sys: $targetSys, comp: $targetComp");
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
      // debugPrint("TX ${frame.message.runtimeType}");
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
      if (udpSocket == null) {
        _stopGcsScheduler();
        return;
      }

      if (MavlinkData.currentHost.isNotEmpty) {
        if (AppData.joystickStatus.value) {
          sendRcOverride();
        }
      } else {
        debugPrint(
          "⏳ Menunggu paket masuk dari kapal untuk mendapatkan alamat IP...",
        );
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
    debugPrint("gcsSchedule stop");
  }

  static void _startLinkStatistics() {
    _linkStatsTimer?.cancel();

    _linkStatsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      MavlinkData.packetsPerSecond = MavlinkData.packetsThisSecond;

      MavlinkData.packetsThisSecond = 0;

      NotifierService.triggerConnectionUpdate();
    });
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

  static int _timesyncSequence = 0;

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

    final msg = RcChannelsOverride(
      targetSystem: targetSys,
      targetComponent: targetComp,
      chan1Raw: AppData.joystickData[0],
      // chan2Raw: AppData.joystickData[1],
      chan2Raw: 1500,
      chan3Raw: AppData.joystickData[2],
      // chan4Raw: AppData.joystickData[3],
      chan4Raw: 1500,
      chan5Raw: AppData.joystickData[4],
      chan6Raw: AppData.joystickData[5],
      chan7Raw: AppData.joystickData[6],
      chan8Raw: AppData.joystickData[7],
      chan9Raw: AppData.joystickData[8],
      chan10Raw: AppData.joystickData[9],
      chan11Raw: AppData.joystickData[10],
      chan12Raw: AppData.joystickData[11],
      chan13Raw: AppData.joystickData[12],
      chan14Raw: AppData.joystickData[13],
      chan15Raw: AppData.joystickData[14],
      chan16Raw: AppData.joystickData[15],
      chan17Raw: 0,
      chan18Raw: 0,
    );

    _queueMessage(msg);
  }
}
