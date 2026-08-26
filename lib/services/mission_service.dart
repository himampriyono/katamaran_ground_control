import 'package:dart_mavlink/dialects/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:katamaran_ground_control/utils/mission_extensions.dart';
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

    MavlinkData.missionTransfer.value = MissionTransferProgress(
      type: MissionTransferType.download,
      current: 0,
      total: message.count,
      message: "Downloading Mission",
      active: true,
    );

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

    if (message.seq > 0) {
      MavlinkData.missionItems.add(item);
    }
    MavlinkData.missionLoaded = nextSequence;

    MavlinkData.missionTransfer.value = MissionTransferProgress(
      type: MissionTransferType.download,
      current: message.seq + 1,
      total: MavlinkData.missionCount,
      message: "Downloading Mission",
      active: true,
    );

    if (nextSequence < MavlinkData.missionCount) {
      MavlinkService.requestMissionItem(nextSequence);
    } else {
      MavlinkData.isLoadingMission = false;
      debugPrint("Mission is received completely");
      MavlinkData.missionTransfer.value = MissionTransferProgress(
        type: MissionTransferType.download,
        current: 1,
        total: 1,
        message: "Download Completed",
        active: true,
      );

      Future.delayed(const Duration(milliseconds: 800), () {
        MavlinkData.missionTransfer.value =
            const MissionTransferProgress.idle();
      });
    }

    NotifierService.triggerMissionUpdate();
  }

  static Future<void> uploadMission() async {
    debugPrint("Uploading mission");
    MavlinkService.sendMissionCount(
      targetSystem: MavlinkData.targetSystemId ?? 1,
      targetComponent: MavlinkData.targetComponentId ?? 1,
      count: MavlinkData.missionItems.length + 1,
    );

    MavlinkData.missionTransfer.value = MissionTransferProgress(
      type: MissionTransferType.upload,
      current: 0,
      total: MavlinkData.missionItems.length + 1,
      message: "Uploading mission",
      active: true,
    );
  }

  static void handleMissionRequest(MissionRequest packet) {
    debugPrint("Requested seq: ${packet.seq}");

    if (packet.seq == 0) {
      MavlinkService.sendMissionitemInt(
        mission: createHomeMission(),
        targetSystem: MavlinkData.targetSystemId ?? 1,
        targetComponent: MavlinkData.targetComponentId ?? 1,
      );
    } else {
      final mission = MavlinkData.missionItems[packet.seq - 1].copyWith(
        seq: packet.seq,
      );

      MavlinkService.sendMissionitemInt(
        mission: mission,
        targetSystem: MavlinkData.targetSystemId ?? 1,
        targetComponent: MavlinkData.targetComponentId ?? 1,
      );

      MavlinkData.missionTransfer.value = MissionTransferProgress(
        type: MissionTransferType.upload,
        current: packet.seq + 1,
        total: MavlinkData.missionItems.length,
        message: "Upload Mission",
        active: true,
      );
    }
  }

  static void sendMissionCount() {}
  static void sendMissionItemInt() {}
  static void handleMissionAck(MissionAck packet) {
    debugPrint("[Mission] Upload finished: ${packet.type}");

    MavlinkData.missionTransfer.value = MissionTransferProgress(
      type: MissionTransferType.upload,
      current: 1,
      total: 1,
      message: "Upload Complete",
      active: true,
    );

    Future.delayed(const Duration(milliseconds: 800), () {
      MavlinkData.missionTransfer.value = const MissionTransferProgress.idle();
    });
  }

  static MissionItem createHomeMission() {
    late final double latitude;
    late final double longitude;
    late final double altitude;

    if (MavlinkData.lastHomePosition != null) {
      latitude = MavlinkData.lastHomePosition!.latitude / 1e7;
      longitude = MavlinkData.lastHomePosition!.longitude / 1e7;
      altitude = MavlinkData.lastHomePosition!.altitude / 1000.0;
    } else if (MavlinkData.lastGlobalPositionInt != null) {
      latitude = MavlinkData.lastGlobalPositionInt!.lat / 1e7;
      longitude = MavlinkData.lastGlobalPositionInt!.lon / 1e7;
      altitude = MavlinkData.lastGlobalPositionInt!.relativeAlt / 1000;
    } else {
      latitude = -6.175392;
      longitude = 106.827153;
      altitude = 0.0;
    }

    return MissionItem(
      param1: 0,
      param2: 0,
      param3: 0,
      param4: double.nan,
      x: latitude,
      y: longitude,
      z: altitude,
      seq: 0,
      command: mavCmdNavWaypoint,
      targetSystem: MavlinkData.targetSystemId ?? 1,
      targetComponent: MavlinkData.targetComponentId ?? 1,
      frame: mavFrameGlobalRelativeAlt,
      current: 0,
      autocontinue: 1,
      missionType: mavMissionTypeMission,
    );
  }
}
