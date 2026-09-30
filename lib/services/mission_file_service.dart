import 'dart:io';
// import 'package:dart_mavlink/dialects/common.dart';
import 'package:dart_mavlink/dialects/ardupilotmega.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../data/mavlink_data.dart';
import 'notifier_service.dart';

class MissionFileService {
  static Future<void> exportMission(String filename) async {
    final content = _buildMissionFile();

    await _saveMissionFile(filename, content);
  }

  static String _buildMissionFile() {
    final buffer = StringBuffer();

    buffer.writeln("QGC WPL 110");

    for (final mission in MavlinkData.missionItems) {
      buffer.writeln(
        "${mission.seq}\t"
        "${mission.current}\t"
        "${mission.frame}\t"
        "${mission.command}\t"
        "${mission.param1}\t"
        "${mission.param2}\t"
        "${mission.param3}\t"
        "${mission.param4}\t"
        "${mission.x}\t"
        "${mission.y}\t"
        "${mission.z}\t"
        "${mission.autocontinue}\t",
      );
    }

    return buffer.toString();
  }

  static Future<void> _saveMissionFile(String filename, String content) async {
    if (filename.isEmpty) {
      filename = "mission";
    }

    if (!filename.toLowerCase().endsWith(".waypoints")) {
      filename += ".waypoints";
    }

    final documents = await getApplicationDocumentsDirectory();

    final missionDir = Directory(
      path.join(documents.parent.path, "Documents", "Katamaran", "Missions"),
    );

    if (!await missionDir.exists()) {
      await missionDir.create(recursive: true);
    }

    filename = filename.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');

    final file = File(path.join(missionDir.path, filename));

    await file.writeAsString(content);

    debugPrint("Mission exported to ${file.path}");
  }

  static Future<void> importMission(String filePath) async {
    final file = File(filePath);

    if (!await file.exists()) {
      debugPrint("Mission file not found");
      return;
    }

    final content = await file.readAsString();
    final missions = _parseMissionFile(content);

    MavlinkData.missionItems
      ..clear()
      ..addAll(missions);

    NotifierService.triggerMissionUpdate();
  }

  static List<MissionItem> _parseMissionFile(String content) {
    final mission = <MissionItem>[];

    final lines = content.split('\n');

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.isEmpty) {
        continue;
      }

      final fields = line.split('\t');

      if (fields.length < 12) {
        debugPrint("Invalid mission line: $line");
        continue;
      }

      mission.add(
        MissionItem(
          targetSystem: MavlinkData.targetSystemId ?? 1,
          targetComponent: MavlinkData.targetComponentId ?? 1,
          seq: int.parse(fields[0]),
          current: int.parse(fields[1]),
          frame: int.parse(fields[2]),
          command: int.parse(fields[3]),
          param1: double.parse(fields[4]),
          param2: double.parse(fields[5]),
          param3: double.parse(fields[6]),
          param4: double.parse(fields[7]),
          x: double.parse(fields[8]),
          y: double.parse(fields[9]),
          z: double.parse(fields[10]),
          autocontinue: int.parse(fields[11]),
          missionType: mavMissionTypeMission,
        ),
      );
    }

    return mission;
  }
}
