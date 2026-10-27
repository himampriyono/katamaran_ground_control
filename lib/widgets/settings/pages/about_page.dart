import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          const Text("Katamaran Mission Monitoring Console"),
          const Text("- 2026"),
          SizedBox(height: 32),
          Text(
            "Developed in HyLab (2026)",
            style: TextStyle(color: Colors.grey.withAlpha(1)),
          ),
          Text(
            "ProjectId: 48796D-53434D-4B6170616C",
            style: TextStyle(color: Colors.grey.withAlpha(1)),
          ),
        ],
      ),
    );
  }
}
