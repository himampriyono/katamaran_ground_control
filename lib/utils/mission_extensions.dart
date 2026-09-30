// import 'package:dart_mavlink/dialects/common.dart';
import 'package:dart_mavlink/dialects/ardupilotmega.dart';

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

extension MissionItemCopy on MissionItem {
  MissionItem copyWith({
    int? seq,
    int? command,
    int? frame,
    int? current,
    int? autocontinue,
    double? param1,
    double? param2,
    double? param3,
    double? param4,
    double? x,
    double? y,
    double? z,
  }) {
    return MissionItem(
      targetSystem: targetSystem,
      targetComponent: targetComponent,
      seq: seq ?? this.seq,
      frame: frame ?? this.frame,
      command: command ?? this.command,
      current: current ?? this.current,
      autocontinue: autocontinue ?? this.autocontinue,
      param1: param1 ?? this.param1,
      param2: param2 ?? this.param2,
      param3: param3 ?? this.param3,
      param4: param4 ?? this.param4,
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
      missionType: missionType,
    );
  }
}
