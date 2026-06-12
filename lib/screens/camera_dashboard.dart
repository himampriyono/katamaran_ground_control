import 'package:flutter/material.dart';
// import 'package:media_kit/media_kit.dart';
// import 'package:media_kit_video/media_kit_video.dart';

class CameraDashboard extends StatelessWidget {
  const CameraDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          "CAMERA WINDOW",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}