import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum SpeedUnit { metric, naval }

enum PositionUnit { utm, latlon, dms }

enum JoystickStatus { connected, connecting, disconnected }

enum JoystickCalibrationStatus { normal, calibrating }

enum MapType { vectorOffline, satelliteOffline, googleMap }

enum GotoMenuAction { none, goHere, circleHere }

class AppData {
  static final appName = "Katamaran Mission Monitoring Console";
  static final ValueNotifier<SpeedUnit> selectedSpeedUnit = ValueNotifier(
    SpeedUnit.metric,
  );
  static final ValueNotifier<PositionUnit> selectedPosUnit = ValueNotifier(
    PositionUnit.latlon,
  );
  static final ValueNotifier<MapType> selectedMapType = ValueNotifier(
    MapType.vectorOffline,
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

  static ValueNotifier<LatLng> objectCoord = ValueNotifier(LatLng(0, 0));

  static ValueNotifier<bool> showSettings = ValueNotifier(false);

  static ValueNotifier<bool> showMissionOnMainMap = ValueNotifier(true);

  static GotoMenuAction gotoAction = GotoMenuAction.none;

  static final ValueNotifier<double> headingToTarget = ValueNotifier(0.0);

  static final ValueNotifier<JetsonTelemetry> jetsonTelemetry = ValueNotifier(
    const JetsonTelemetry(),
  );

  static bool camFrontReady = false;
  static bool camLeftReady = false;
  static bool camRearReady = false;
  static bool camRightReady = false;
}

class JetsonTelemetry {
  final bool connected;
  final double cpuTemp;
  final double gpuTemp;
  final double junctionTemp;

  const JetsonTelemetry({
    this.connected = false,
    this.cpuTemp = 0,
    this.gpuTemp = 0,
    this.junctionTemp = 0,
  });
}
