import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_data.dart';

class SettingsService {
  SettingsService._();

  static late SharedPreferences _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static void loadSettings() {
    AppData.selectedSpeedUnit.value = speedUnit;
    AppData.selectedPosUnit.value = positionUnit;
    AppData.selectedMapType.value = mapType;
    AppData.showMissionOnMainMap.value = showMission;
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

  static bool get showMission{
    final value = _prefs.getBool("map.mission_display") ?? false;
    return value;
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

  static Future<void> setShowMission(bool show) async{
    await _prefs.setBool("map.mission_display", show);
  }
}
