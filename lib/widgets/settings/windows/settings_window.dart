import 'package:flutter/material.dart';
import '../../../data/app_data.dart';
import '../pages/about_page.dart';
import '../pages/general_page.dart';
import '../pages/joystick_page.dart';
import '../pages/mission_page.dart';
import '../pages/telemetry_page.dart';
import '../pages/vehicle_page.dart';

enum SettingTab { general, vehicle, joystick, mission, telemetry, about }

class SettingsWindow extends StatefulWidget {
  const SettingsWindow({super.key});

  @override
  State<SettingsWindow> createState() => _SettingWindowsState();
}

class _SettingWindowsState extends State<SettingsWindow> {
  SettingTab _selectedTab = SettingTab.general;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            width: 800,
            height: 550,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 30,
                  spreadRadius: 2,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white12)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Center(
                        child: Icon(Icons.settings_rounded, size: 18),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Settings",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          AppData.showSettings.value = false;
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      _buildSideBar(),
                      const VerticalDivider(width: 1, thickness: 1),
                      Expanded(child: _buildContent()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSideBar() {
    return SizedBox(
      width: 200,
      child: Column(
        children: [
          _buildSidebarItem(
            icon: Icons.tune,
            title: "General",
            tab: SettingTab.general,
          ),

          _buildSidebarItem(
            icon: Icons.directions_boat,
            title: "Vehicle",
            tab: SettingTab.vehicle,
          ),

          _buildSidebarItem(
            icon: Icons.sports_esports,
            title: "Joystick",
            tab: SettingTab.joystick,
          ),

          _buildSidebarItem(icon: Icons.route, title: "Mission", tab: SettingTab.mission),

          _buildSidebarItem(
            icon: Icons.settings_input_antenna,
            title: "Telemetry",
            tab: SettingTab.telemetry,
          ),

          const Spacer(),

          _buildSidebarItem(
            icon: Icons.info_outline,
            title: "About",
            tab: SettingTab.about,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case SettingTab.general:
        return const GeneralPage();

      case SettingTab.vehicle:
        return const VehiclePage();

      case SettingTab.joystick:
        return const JoystickPage();

      case SettingTab.mission:
        return const MissionPage();

      case SettingTab.telemetry:
        return const TelemetryPage();

      case SettingTab.about:
        return const AboutPage();
    }
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String title,
    required SettingTab tab,
  }) {
    final bool selected = _selectedTab == tab;

    return Padding(
      padding: const EdgeInsetsGeometry.symmetric(horizontal: 10, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            setState(() {
              _selectedTab = tab;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFF3B82F6).withAlpha(30)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? const Color(0xFF3B82F6).withAlpha(30)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected ? const Color(0xFF64B5F6) : Colors.white60,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
