import 'package:flutter/material.dart';

enum SpeedUnit { metric, naval }

enum PositionUnit { utm, latlon }

enum JoystickStatus { connected, connecting, disconnected }

enum JoystickCalibrationStatus { normal, calibrating }

class AppData {
  static final appName = "Katamaran ######";
  static final ValueNotifier<SpeedUnit> selectedSpeedUnit = ValueNotifier(
    SpeedUnit.metric,
  );
  static final ValueNotifier<PositionUnit> selectedPosUnit = ValueNotifier(
    PositionUnit.latlon,
  );
  static ValueNotifier<JoystickStatus> joystickStatus = ValueNotifier(
    JoystickStatus.disconnected,
  );
  static ValueNotifier<JoystickCalibrationStatus> joystickCalibrationStatus =
      ValueNotifier(JoystickCalibrationStatus.normal);
  static ValueNotifier<List<int>> joystickCalibrationMin = ValueNotifier(
    List.filled(16, 2000),
  );
  static ValueNotifier<List<int>> joystickCalibrationMax = ValueNotifier(
    List.filled(16, 1000),
  );

  static List<String> availablePorts = [];
  static ValueNotifier<String> selectedPort = ValueNotifier<String>("-");
  // static List<int> joystickData = List.generate(16, (index) => 0);
  static ValueNotifier<List<int>> joystickChannels = ValueNotifier(
    List.filled(16, 1500),
  );

  static ValueNotifier<bool> showSettings = ValueNotifier(false);
}
