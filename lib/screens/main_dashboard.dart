import 'package:flutter/material.dart';
import '../widgets/main_appbar.dart';
import 'main_sidepanel.dart';
import 'map_area.dart';
import '../widgets/settings/windows/settings_window.dart';
import '../data/app_data.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboard();
}

class _MainDashboard extends State<MainDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E24),
      appBar: MainAppbar(),
      body: Stack(
        children: [
          Row(children: [MapArea(), MainSidePanel()]),
          ValueListenableBuilder(
            valueListenable: AppData.showSettings,
            builder: (context, show, child) {
              if (show) {
                return const SettingsWindow();
              } else {
                return const SizedBox();
              }
            },
          ),
        ],
      ),
    );
  }
}
