import 'package:flutter/material.dart';
import '../../../services/mission_service.dart';
import '../widgets/action_button.dart';
import '../widgets/setting_page_header.dart';
import '../widgets/settings_group.dart';
import '../widgets/settings_tile.dart';
import '../windows/fc_radio_monitor.dart';
import '../windows/parameter_manager.dart';
import '../windows/pwm_output_monitor.dart';

class VehiclePage extends StatelessWidget {
  const VehiclePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingPageHeader(
            title: "Vehicle",
            subtitle:
                "Configure flight controller tools and vehicle diagnostics.",
          ),
          SizedBox(height: 4),
          SettingsGroup(
            title: "RC",
            child: SettingsTile(
              title: "Ship Radio Monitor",
              trailing: ActionButton(
                text: "Open Radio Monitor",
                color: Colors.orange,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return const FcRadioMonitor();
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Divider(),
          const SizedBox(height: 6),
          SettingsGroup(
            title: "Parameters List",
            child: SettingsTile(
              title: "Parameter",
              trailing: ActionButton(
                text: "Open Parameter List",
                color: Colors.orange,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return const ParameterManager();
                    },
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 12),
          SettingsGroup(
            title: "TES",
            child: SettingsTile(
              title: "Tes Misi",
              trailing: ActionButton(
                text: "Dw misi",
                color: Colors.red,
                onTap: () {
                  MissionService.requestMissionList();
                },
              ),
            ),
          ),
          // SettingsGroup(
          //   title: "Output",
          //   child: SettingsTile(
          //     title: "PWM Output",
          //     trailing: ActionButton(
          //       text: "Open Output Monitor",
          //       color: Colors.orange,
          //       onTap: () {
          //         showDialog(
          //           context: context,
          //           builder: (_) {
          //             return PwmOutputMonitor();
          //           },
          //         );
          //       },
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
