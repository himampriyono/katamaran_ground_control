import 'package:flutter/material.dart';
import 'data/app_data.dart';
import 'screens/main_dashboard.dart';
import 'services/mavlink_service.dart';
import 'utils/joystick_handler.dart';
import 'widgets/snackbar.dart';

final mavlinkService = MavlinkService();

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeServices();

  runApp(const MainApp());
}

Future<void> _initializeServices() async {
  debugPrint("Starting ${AppData.appName}...");

  await mavlinkService.connect(14550);

  JoystickHandler.startAutoReconnectJoystick(
    targetPort: 'COM5',
    baudRate: 115200,
    onStatusChanged: (statusUpdate) {
      debugPrint("Joystick Status: $statusUpdate");
    },
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: Snackbar.messengerKey,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blueGrey,
      ),
      home: const MainDashboard(),
    );
  }
}
