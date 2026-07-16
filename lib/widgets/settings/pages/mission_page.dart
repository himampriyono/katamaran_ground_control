import 'package:flutter/material.dart';

import '../../../services/mission_service.dart';
import '../widgets/action_button.dart';
import '../widgets/setting_page_header.dart';
import '../widgets/settings_group.dart';
import '../widgets/settings_tile.dart';

class MissionPage extends StatelessWidget {
  const MissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SettingPageHeader(
            title: "Mission",
            subtitle: "Configure the ship auto mission",
          ),
          SizedBox(height: 4),
          Column(
            children: [
              SettingsTile(
                title: "Mission Manager",
                trailing: ActionButton(
                  text: "Tes Download Mission",
                  color: Colors.orange,
                  onTap: () {
                    MissionService.requestMissionList();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
