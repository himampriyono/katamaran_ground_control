import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_data.dart';
import '../data/mavlink_data.dart';

class SettingsService {
  SettingsService._();

  static late SharedPreferences _prefs;

  static const String _torpedoMissionKey = "torpedo.mission";

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static void loadSettings() {
    AppData.selectedSpeedUnit.value = speedUnit;
    AppData.selectedPosUnit.value = positionUnit;
    AppData.selectedMapType.value = mapType;
    AppData.showMissionOnMainMap.value = showMission;
    loadTorpedoMission();
  }

  // ============

  static String get vesselIp =>
      _prefs.getString("network.vessel_ip") ?? "192.168.137.78";

  static int get udpPort => _prefs.getInt("network.udp_port") ?? 14550;

  static SpeedUnit get speedUnit {
    final value = _prefs.getInt("display.speed_unit") ?? 0;
    return SpeedUnit.values[value];
  }

  static PositionUnit get positionUnit {
    final value = _prefs.getInt("display.position_unit") ?? 0;
    return PositionUnit.values[value];
  }

  static MapType get mapType {
    final value = _prefs.getInt("map.type") ?? 0;
    return MapType.values[value];
  }

  static bool get showMission {
    final value = _prefs.getBool("map.mission_display") ?? false;
    return value;
  }

  static void loadTorpedoMission() {
    final raw = _prefs.getString(_torpedoMissionKey);

    if (raw == null) {
      return;
    }

    try {
      final data = jsonDecode(raw);

      if (data is! Map) {
        return;
      }

      final mission = MavlinkData.torpedo;

      mission.autoTargetHeading = data["autoTargetHeading"] as bool? ?? true;

      mission.heading = (data["heading"] as num?)?.toDouble() ?? 0.0;

      mission.depth = (data["depth"] as num?)?.toDouble() ?? 1.0;

      mission.power = (data["power"] as num?)?.toDouble() ?? 5000.0;

      mission.startDelay = (data["startDelay"] as num?)?.toDouble() ?? 3.0;

      mission.duration = (data["duration"] as num?)?.toDouble() ?? -1.0;
    } catch (e) {
      debugPrint("[TORPEDO] Failed to load mission settings: $e");
    }
  }

  static int get joystickReverseMask {
    final value = _prefs.getInt("joystick.reverse_mask") ?? 0;
    return value;
  }

  static bool isJoystickChannelReversed(int channel) {
    if (channel < 1 || channel > 16) return false;

    return (joystickReverseMask & (1 << (channel - 1))) != 0;
  }

  //  --------

  static Future<void> setVesselIp(String ip) async {
    await _prefs.setString("network.vessel_ip", ip);
  }

  static Future<void> setUdpPort(int port) async {
    await _prefs.setInt("network.udp_port", port);
  }

  static Future<void> setSpeedUnit(SpeedUnit unit) async {
    await _prefs.setInt("display.speed_unit", unit.index);
  }

  static Future<void> setPositionUnit(PositionUnit unit) async {
    await _prefs.setInt("display.position_unit", unit.index);
  }

  static Future<void> setMapType(MapType type) async {
    await _prefs.setInt("map.type", type.index);
  }

  static Future<void> setShowMission(bool show) async {
    await _prefs.setBool("map.mission_display", show);
  }

  static Future<void> setTorpedoMission(TorpedoMissionData mission) async {
    final data = {
      "autoTargetHeading": mission.autoTargetHeading,
      "heading": mission.heading,
      "depth": mission.depth,
      "power": mission.power,
      "startDelay": mission.startDelay,
      "duration": mission.duration,
    };

    await _prefs.setString(_torpedoMissionKey, jsonEncode(data));
  }

  static Future<void> setJoystickReverseMask(int mask) async {
    await _prefs.setInt("joystick.reverse_mask", mask);
  }

  static Future<void> setJoystickChannelReversed(
    int channel,
    bool reversed,
  ) async {
    if (channel < 1 || channel > 16) return;

    int mask = joystickReverseMask;
    final bit = 1 << (channel - 1);

    if (reversed) {
      mask |= bit;
    } else {
      mask &= bit;
    }

    await setJoystickReverseMask(mask);
  }
}
