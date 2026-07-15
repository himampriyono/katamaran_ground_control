import 'package:flutter/material.dart';
import '../../../data/app_data.dart';
import '../../../utils/joystick.dart';
import '../widgets/setting_page_header.dart';
import '../widgets/settings_group.dart';
import '../widgets/settings_tile.dart';
import '../widgets/action_button.dart';
import '../widgets/joystick_port_selector.dart';
import '../windows/joystick_calibration.dart';
import '../windows/joystick_monitor_window.dart';

class JoystickPage extends StatelessWidget {
  const JoystickPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SettingPageHeader(
            title: "Joystick",
            subtitle: "Configure Joystick connection settings.",
          ),
          const SizedBox(height: 4),
          SettingsGroup(
            title: "Connection",
            child: Column(
              children: [
                SettingsTile(
                  title: "Status",
                  trailing: ValueListenableBuilder(
                    valueListenable: AppData.joystickStatus,
                    builder: (context, connection, child) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 10,
                            color:
                                (AppData.joystickStatus.value ==
                                    JoystickStatus.connected)
                                ? Colors.green
                                : ((AppData.joystickStatus.value ==
                                          JoystickStatus.disconnected)
                                      ? Colors.red
                                      : Colors.orange),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            (AppData.joystickStatus.value ==
                                    JoystickStatus.connected)
                                ? "Connected"
                                : ((AppData.joystickStatus.value ==
                                          JoystickStatus.disconnected)
                                      ? "Disconnected"
                                      : "Connecting"),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color:
                                  (AppData.joystickStatus.value ==
                                      JoystickStatus.connected)
                                  ? Colors.green
                                  : ((AppData.joystickStatus.value ==
                                            JoystickStatus.disconnected)
                                        ? Colors.red
                                        : Colors.orange),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SettingsTile(
                  title: "Port",
                  trailing: ValueListenableBuilder(
                    valueListenable: AppData.selectedPort,
                    builder: (context, port, child) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            port,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                // Divider(),
                SettingsTile(
                  title: "Manual Connection Toggle",
                  trailing: ValueListenableBuilder(
                    valueListenable: AppData.joystickStatus,
                    builder: (_, status, _) {
                      return ActionButton(
                        text:
                            AppData.joystickStatus.value ==
                                JoystickStatus.connected
                            ? "Disconnect"
                            : "Connect",
                        color:
                            AppData.joystickStatus.value ==
                                JoystickStatus.connected
                            ? Colors.red
                            : Colors.green,
                        onTap: () async {
                          if (AppData.joystickStatus.value ==
                              JoystickStatus.connected) {
                            await Joystick.disconnect();
                          } else {
                            final ports = Joystick.scanUsbPort();

                            final selected = await showJoystickPortSelector(
                              context,
                              ports: ports,
                            );

                            if (selected == null) return;

                            await Joystick.connect(selected);
                          }
                        },
                      );
                    },
                  ),
                ),
                SettingsTile(
                  title: "Automatic Joystick Connection",
                  trailing: ValueListenableBuilder(
                    valueListenable: AppData.joystickStatus,
                    builder: (_, status, _) {
                      final connecting = status == JoystickStatus.connecting;

                      return ActionButton(
                        text: connecting ? "Scanning..." : "Auto Connect",
                        color: connecting ? Colors.orange : Colors.blue,
                        onTap: connecting
                            ? null
                            : () async {
                                await Joystick.startAutoConnectJoystick();
                              },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          SettingsGroup(
            title: "Tools",
            child: Column(
              children: [
                SettingsTile(
                  title: "Channel Monitor",
                  trailing: ActionButton(
                    text: "Monitor",
                    // icon: Icons.monitor,
                    color: Colors.cyan,
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (_) {
                          return const JoystickMonitorWindow();
                        },
                      );
                    },
                  ),
                ),
                SettingsTile(
                  title: "Joystick Caibration",
                  trailing: ActionButton(
                    text: "Open Calibrate Window",
                    // icon: Icons.monitor,
                    color: Colors.orangeAccent,
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (_) {
                          return const JoystickCalibration();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
