import 'package:flutter/material.dart';
import '../widgets/main_appbar.dart';
import 'main_sidepanel.dart';
import 'map_area.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboard();
}

class _MainDashboard extends State<MainDashboard> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1E1E24),
      appBar: MainAppbar(),
      body: Row(
        children: [
          MapArea(),
          MainSidePanel(),
        ],
      ),
    );
  }
}