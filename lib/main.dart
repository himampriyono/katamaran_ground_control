import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'data/app_data.dart';
import 'screens/main_dashboard.dart';
import 'services/jetson_monitor_service.dart';
import 'services/mavlink_service.dart';
import 'services/parameter_metadata_service.dart';
import 'widgets/snackbar.dart';
import 'utils/joystick.dart';
import 'services/settings_service.dart';
// import 'debug/mbtiles_test_page.dart';

final mavlinkService = MavlinkService();

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();
  const options = WindowOptions(
    // fullScreen: true,
    center: true,
    title: "",
  );
  windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  await SettingsService.initialize();
  SettingsService.loadSettings();

  await _initializeServices();

  runApp(const MainApp());
}

Future<void> _initializeServices() async {
  debugPrint("Starting ${AppData.appName}...");

  await mavlinkService.connect(
    host: SettingsService.vesselIp,
    port: SettingsService.udpPort,
  );

  JetsonMonitorService.connect(SettingsService.vesselIp);

  Joystick.startRecoverJoystick();
  await ParameterMetadataService.load();
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: Snackbar.messengerKey,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
      ),
      home: const MainDashboard(),
      // home: const JoystickTest(),
      // home: const MbTilesTestPage(),
    );
  }
}
