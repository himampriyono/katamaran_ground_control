import 'package:flutter/material.dart';

import '../../../data/mavlink_data.dart';
import '../../../services/mission_service.dart';
import '../../../services/notifier_service.dart';
import '../widgets/action_button.dart';
import '../widgets/mission_tile.dart';
import '../widgets/setting_page_header.dart';
import '../windows/mission_editor.dart';

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
          SizedBox(height: 12),
          Row(
            children: [
              ActionButton(
                text: "Download",
                color: Colors.orange,
                onTap: () {
                  MissionService.requestMissionList();
                },
              ),
              const SizedBox(width: 24),
              ActionButton(text: "Upload", color: Colors.green, onTap: () {}),
              const SizedBox(width: 24),
              ActionButton(
                text: "Edit",
                color: Colors.cyan,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return MissionEditor();
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Divider(),
          const SizedBox(height: 5),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Mission List",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 12),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: NotifierService.missionTrigger,
              builder: (context, _, _) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: MavlinkData.missionItems.length,
                  itemBuilder: (context, index) {
                    return MissionTile(
                      mission: MavlinkData.missionItems[index],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
