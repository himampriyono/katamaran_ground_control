import 'package:dart_mavlink/dialects/common.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/mav_parameter.dart';

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
  static List<int> rcChannels = List.filled(16, 1500);
  static List<int> pwmOutput = List.filled(16, 950);
  static MissionCurrent? lastMissionCurrent;

  static final Map<String, MavParameter> parameters = {};
  static int parameterCount = 0;
  static int parameterLoaded = 0;
  static bool isLoadingParameters = false;

  static final List<MissionItem> missionItems = [];
  static bool isLoadingMission = false;
  static int missionCount = 0;
  static int missionLoaded = 0;

  static LatLng? gotoTarget;
  // static LatLng? circleTarget;
  // static LatLng? objectCoord;
  static bool isObjectValid = false;

  static final missionTransfer = ValueNotifier(
    const MissionTransferProgress.idle(),
  );

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
