import 'package:flutter/material.dart';
import '../../../data/mavlink_data.dart';
import '../../../services/mission_service.dart';
import '../../../services/notifier_service.dart';
import 'mission_editor_tile.dart';
import 'mission_tile.dart';
import 'mission_toolbar.dart';

class MissionPanel extends StatelessWidget {
  const MissionPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: Column(
        children: [
          SizedBox(height: 8),
          MissionToolbar(
            onDownload: () {
              MissionService.requestMissionList();
            },
          ),
          SizedBox(height: 5),
          const Divider(height: 2),
          _buildHeader(),
          const Divider(),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: NotifierService.missionTrigger,
              builder: (context, _, _) {
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: MavlinkData.missionItems.length,
                  itemBuilder: (context, index) {
                    return MissionEditorTile(
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

  Widget _buildHeader() {
    return Container(
      height: 48,
      alignment: Alignment.center,
      child: Text(
        "Mission List (${MavlinkData.missionItems.length})",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
