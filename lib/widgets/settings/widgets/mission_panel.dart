import 'package:flutter/material.dart';
import 'package:katamaran_ground_control/utils/mission_extensions.dart';
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
            onUpload: (){
              MissionService.uploadMission();
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
                // return ListView.builder(
                //   padding: const EdgeInsets.all(8),
                //   itemCount: MavlinkData.missionItems.length,
                //   itemBuilder: (context, index) {
                //     return MissionEditorTile(
                //       mission: MavlinkData.missionItems[index],
                //       onMissionChange: (updatedMission) {
                //         MavlinkData.missionItems[index] = updatedMission;

                //         NotifierService.triggerMissionUpdate();
                //       },
                //     );
                //   },
                // );
                return ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: false,
                  itemCount: MavlinkData.missionItems.length,
                  onReorder: _onReorder,
                  itemBuilder: (context, index) {
                    return MissionEditorTile(
                      key: ValueKey(MavlinkData.missionItems[index].seq),
                      mission: MavlinkData.missionItems[index],
                      onMissionChange: (mission) {
                        MavlinkData.missionItems[index] = mission;
                        NotifierService.triggerMissionUpdate();
                      },
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
        "Mission List",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    // debugPrint("move $oldIndex -> $newIndex");
    if (newIndex > oldIndex){
      newIndex--;
    }

    final item = MavlinkData.missionItems.removeAt(oldIndex);
    MavlinkData.missionItems.insert(newIndex, item);

    for (var i = 0; i < MavlinkData.missionItems.length; i++){
      MavlinkData.missionItems[i] = MavlinkData.missionItems[i].copyWith(seq: i);
    }

    NotifierService.triggerMissionUpdate();
  }
}
