import 'package:dart_mavlink/dialects/common.dart';

extension MissionItemExtension on MissionItem {
  String get commandName {
    switch (command) {
      case 16:
        return "Waypoint";
      case 22:
        return "Takeoff";
      case 20:
        return "Return to Launch";
      case 21:
        return "Land";
      default:
        return "Unknown";
    }
  }
}