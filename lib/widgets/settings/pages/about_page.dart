import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(children: [
        const Text("Katamaran Mission Monitoring Console"),
        const Text("- 2026")
      ]),
    );
  }
}
