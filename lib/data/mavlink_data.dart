import 'package:dart_mavlink/dialects/common.dart';
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
  static List<int> rcChannels = List.filled(16, 1500);
  static List<int> pwmOutput = List.filled(16, 950);
  static final Map<String, MavParameter> parameters = {};
  static int parameterCount = 0;
  static int parameterLoaded = 0;
  static bool isLoadingParameters = false;

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
