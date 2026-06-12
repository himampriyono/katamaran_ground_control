import 'package:flutter/material.dart';
import '../screens/camera_dashboard.dart';

class CameraApp extends StatelessWidget {
  const CameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CameraDashboard(),
    );
  }
}