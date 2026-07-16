import 'package:dart_mavlink/dialects/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/mavlink_data.dart';
import 'mavlink_service.dart';
import 'notifier_service.dart';

class MissionService {
  static void requestMissionList() {
    MavlinkData.missionItems.clear();
    MavlinkData.missionLoaded = 0;
    MavlinkData.missionCount = 0;
    MavlinkData.isLoadingMission = true;

    NotifierService.triggerMissionUpdate();
    MavlinkService.requestMissionList();
    debugPrint("requesting...");
  }

  static void handleMissionCount(MissionCount message) {
    MavlinkData.missionCount = message.count;
    MavlinkData.missionLoaded = 0;
    NotifierService.triggerMissionUpdate();

    if (message.count == 0) {
      MavlinkData.isLoadingMission = false;
      NotifierService.triggerMissionUpdate();
      debugPrint("No Mission on FC");
      return;
    }

    debugPrint("Mission Count : ${message.count}");
    MavlinkService.requestMissionItem(0);
  }

  static void handleMissionItem(MissionItemInt message) {
    final item = MissionItem(
      param1: message.param1,
      param2: message.param2,
      param3: message.param3,
      param4: message.param4,
      x: message.x / 1e7,
      y: message.y / 1e7,
      z: message.z,
      seq: message.seq,
      command: message.command,
      targetSystem: message.targetSystem,
      targetComponent: message.targetComponent,
      frame: message.frame,
      current: message.current,
      autocontinue: message.autocontinue,
      missionType: message.missionType,
    );

    final nextSequence = message.seq + 1;

    MavlinkData.missionItems.add(item);
    MavlinkData.missionLoaded = nextSequence;

    debugPrint(
      "Seq=${message.seq} "
      "Cmd=${message.command} "
      "Lat=${message.x / 1e7} "
      "Lon=${message.y / 1e7} "
      "Alt=${message.z}",
    );

    if (nextSequence < MavlinkData.missionCount) {
      MavlinkService.requestMissionItem(nextSequence);
    } else {
      MavlinkData.isLoadingMission = false;
      debugPrint("Mission is received completely");
    }

    NotifierService.triggerMissionUpdate();
  }

  static void handleMissionAck() {}
  static void uploadMission() {}
}
