import 'package:flutter/material.dart';
import 'screens/main_dashboard.dart';
import 'services/mavlink_service.dart';
import 'utils/joystick_handler.dart';
import 'widgets/snackbar.dart';
import 'data/app_data.dart';

final mavlinkService = MavlinkService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint("Starting ${AppData.appName}...");

  mavlinkService.connect(14550);
  JoystickHandler.startAutoReconnectJoystick(
    targetPort: 'COM5',
    baudRate: 115200,
    onStatusChanged: (statusUpdate) {
      debugPrint("Joystick Status: $statusUpdate");
    },
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blueGrey,
      ),
      scaffoldMessengerKey: Snackbar.messengerKey,
      home: const MainDashboard(),
    );
  }
}
