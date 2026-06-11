import 'package:flutter/material.dart';

enum SpeedUnit { metric, naval }
enum PositionUnit { utm, latlon }

class AppData {
  static final appName = "KaGol";
  static final ValueNotifier<SpeedUnit> selectedSpeedUnit = ValueNotifier(SpeedUnit.metric);
  static final ValueNotifier<PositionUnit> selectedPosUnit = ValueNotifier(PositionUnit.latlon);
  static List<String> availablePorts = [];
  static String selectedPort = "";
  static ValueNotifier<bool> joystickStatus = ValueNotifier<bool>(false);
  static List<int> joystickData = List.generate(16, (index) => 0);
}