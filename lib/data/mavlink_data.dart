// import 'package:dart_mavlink/dialects/common.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/mav_parameter.dart';
import 'package:dart_mavlink/dialects/ardupilotmega.dart';

enum TorpedoStatus { standby, ready, released }

class MavlinkData {
  static const int mySystemId = 255;
  static const int myComponentId = mavTypeGcs;

  static String currentHost = "127.0.0.1";
  static int currentPort = 14550;
  static int? targetSystemId;
  static int? targetComponentId;

  static bool isArdupilotReady = false;
  static bool isMavlinkConnected = false;
  static DateTime? lastPacketReceivedTime;
  static int packetsThisSecond = 0;
  static int packetsPerSecond = 0;
  static int timesyncCounter = 0;
  static bool isArmed = false;

  static Heartbeat? lastHeartbeat;
  static SysStatus? lastSysStatus;
  static Attitude? lastAttitude;
  static VfrHud? lastVfrHud;
  static GlobalPositionInt? lastGlobalPositionInt;
  static HomePosition? lastHomePosition;
  static GpsRawInt? lastGpsRawInt;
  static McuStatus? lastMcuStatus;
  static List<int> rcChannels = List.filled(16, 1500);
  static List<int> pwmOutput = List.filled(16, 950);
  static MissionCurrent? lastMissionCurrent;
  static NamedValueInt? torpedoStatus;
  static List<TorpedoStatus> torpedoStatuses = List.filled(
    4,
    TorpedoStatus.released,
  );
  static final ValueNotifier<TorpedoVoltage> torpedoVoltage = ValueNotifier(
    const TorpedoVoltage(),
  );
  static final ValueNotifier<BoatEngineTelemetry> boatEngineTelemetry =
      ValueNotifier(const BoatEngineTelemetry());

  static final Map<String, MavParameter> parameters = {};
  static int parameterCount = 0;
  static int parameterLoaded = 0;
  static bool isLoadingParameters = false;

  static final List<MissionItem> missionItems = [];
  static bool isLoadingMission = false;
  static int missionCount = 0;
  static int missionLoaded = 0;

  static LatLng? gotoTarget;
  static bool isObjectValid = false;

  static Rpm? rpm;
  static EfiStatus? efiStatus;

  static double? motor1Rpm;
  static double? motor2Rpm;

  static final missionTransfer = ValueNotifier(
    const MissionTransferProgress.idle(),
  );

  static final TorpedoMissionData torpedo = TorpedoMissionData();

  static void reset() {
    isMavlinkConnected = false;
    lastPacketReceivedTime = null;
    isArdupilotReady = false;
    targetSystemId = null;
    targetComponentId = null;
    lastHeartbeat = null;
    lastAttitude = null;
    lastHomePosition = null;
    packetsThisSecond = 0;
    packetsPerSecond = 0;
  }
}

class MavMessages {
  static const int heartbeat = 0;
  static const int sysStatus = 1;
  static const int attitude = 30;
  static const int globalPositionInt = 33;
  static const int vfrHud = 74;
  static const int homePosition = 242;
  static const int rawRpm = 339;
  static const int efiStatus = 225;
}

enum MissionTransferType { none, upload, download }

class MissionTransferProgress {
  final MissionTransferType type;
  final int current;
  final int total;
  final String message;
  final bool active;

  const MissionTransferProgress({
    required this.type,
    required this.current,
    required this.total,
    required this.message,
    required this.active,
  });

  double get progress => total == 0 ? 0 : current / total;

  const MissionTransferProgress.idle()
    : type = MissionTransferType.none,
      current = 0,
      total = 0,
      message = "",
      active = false;
}

class TorpedoMissionData {
  bool autoTargetHeading;
  double heading;
  double depth;
  double power;
  double startDelay;
  double duration;

  TorpedoMissionData({
    this.autoTargetHeading = true,
    this.heading = 0,
    this.depth = 0,
    this.power = 0,
    this.startDelay = 0,
    this.duration = -1,
  });
}

class TorpedoVoltage {
  final Map<int, double> values;

  const TorpedoVoltage({this.values = const {}});

  double get(int torpedoId) {
    return values[torpedoId] ?? 0.0;
  }
}

class BoatEngineTelemetry {
  final double? motor1Rpm;
  final double? motor2Rpm;
  final double? motor1FuelPercent;
  final double? motor2FuelPercent;

  const BoatEngineTelemetry({
    this.motor1Rpm,
    this.motor2Rpm,
    this.motor1FuelPercent,
    this.motor2FuelPercent,
  });

  BoatEngineTelemetry copyWith({
    double? motor1Rpm,
    double? motor2Rpm,
    double? motor1FuelPercent,
    double? motor2FuelPercent,
  }) {
    return BoatEngineTelemetry(
      motor1Rpm: motor1Rpm ?? this.motor1Rpm,
      motor2Rpm: motor2Rpm ?? this.motor2Rpm,
      motor1FuelPercent: motor1FuelPercent ?? this.motor1FuelPercent,
      motor2FuelPercent: motor2FuelPercent ?? this.motor2FuelPercent,
    );
  }
}
