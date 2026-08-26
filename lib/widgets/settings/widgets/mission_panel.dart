import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:katamaran_ground_control/utils/mission_extensions.dart';
import '../../../data/mavlink_data.dart';
import '../../../services/mission_file_service.dart';
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
      width: 600,
      child: Padding(
        padding: const EdgeInsetsGeometry.symmetric(horizontal: 12),
        child: Column(
          children: [
            SizedBox(height: 8),
            MissionToolbar(
              onDownload: () {
                MissionService.requestMissionList();
              },
              onUpload: () {
                MissionService.uploadMission();
              },
              onExport: () async {
                await _showExportMissionDialog(context);
              },
              onImport: () async {
                await _showImportMissiondialog(context);
              },
            ),
            SizedBox(height: 8),
            const Divider(height: 2),
            _buildHeader(),
            const SizedBox(height: 4),
            _buildMissionTransferProgress(),
            const SizedBox(height: 4),
            const Divider(),
            _buildMissionListHeader(),
            const SizedBox(height: 2),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: NotifierService.missionTrigger,
                builder: (context, _, _) {
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
                        previousMission: index > 0
                            ? MavlinkData.missionItems[index - 1]
                            : null,
                        onMissionChange: (mission) {
                          MavlinkData.missionItems[index] = mission;
                          NotifierService.triggerMissionUpdate();
                        },
                        onDelete: () {
                          MavlinkData.missionItems.removeAt(index);
                          for (
                            var i = 0;
                            i < MavlinkData.missionItems.length;
                            i++
                          ) {
                            MavlinkData.missionItems[i] = MavlinkData
                                .missionItems[i]
                                .copyWith(seq: i);
                          }
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

  Widget _buildMissionTransferProgress() {
    return ValueListenableBuilder(
      valueListenable: MavlinkData.missionTransfer,
      builder: (context, transfer, child) {
        if (!transfer.active) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  transfer.type == MissionTransferType.upload
                      ? Icons.upload
                      : Icons.download,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  "${transfer.message} (${(transfer.current / transfer.total * 100).toStringAsFixed(0)}%)",
                ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 24),
              child: LinearProgressIndicator(
                value: transfer.progress,
                minHeight: 6,
                borderRadius: BorderRadius.circular(8),
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation(
                  transfer.type == MissionTransferType.upload
                      ? Colors.orange
                      : Colors.green,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showExportMissionDialog(BuildContext context) async {
    final now = DateTime.now();

    final controller = TextEditingController(
      text:
          "mission_${now.year}"
          "${now.month.toString().padLeft(2, '0')}"
          "${now.day.toString().padLeft(2, '0')}_"
          "${now.hour.toString().padLeft(2, '0')}"
          "${now.minute.toString().padLeft(2, '0')}",
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Export Mission"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: "File Name",
              suffixText: ".waypoints",
            ),
            autofocus: true,
            onSubmitted: (value) async {
              Navigator.pop(context);

              await MissionFileService.exportMission(value.trim());
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                return Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);

                await MissionFileService.exportMission(controller.text.trim());
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showImportMissiondialog(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['waypoints'],
    );

    if (result == null) {
      return;
    }

    final path = result.files.single.path;

    if (path == null) {
      return;
    }

    await MissionFileService.importMission(path);
  }

  void _onReorder(int oldIndex, int newIndex) {
    // debugPrint("move $oldIndex -> $newIndex");
    if (newIndex > oldIndex) {
      newIndex--;
    }

    final item = MavlinkData.missionItems.removeAt(oldIndex);
    MavlinkData.missionItems.insert(newIndex, item);

    for (var i = 0; i < MavlinkData.missionItems.length; i++) {
      MavlinkData.missionItems[i] = MavlinkData.missionItems[i].copyWith(
        seq: i,
      );
    }

    NotifierService.triggerMissionUpdate();
  }
}

Widget _buildMissionListHeader() {
  return Container(
    height: 34,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.white.withAlpha(25),
      border: const Border(bottom: BorderSide(color: Colors.white24)),
    ),
    child: const Row(
      children: [
        SizedBox(
          width: 30,
          child: Text(
            "#",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
        ),
        SizedBox(
          width: 180,
          child: Text(
            "Command",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
        ),
        SizedBox(
          width: 100,
          child: Text(
            "Latitude",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
        ),
        SizedBox(
          width: 100,
          child: Text(
            "Longitude",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
        ),
        SizedBox(
          width: 70,
          child: Text(
            "Dist.",
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
        ),
        SizedBox(width: 32),
        SizedBox(width: 24),
      ],
    ),
  );
}
