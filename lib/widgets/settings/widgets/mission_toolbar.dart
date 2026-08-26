import 'package:flutter/material.dart';

import '../../../data/mavlink_data.dart';
import '../../../services/notifier_service.dart';

class MissionToolbar extends StatelessWidget {
  final VoidCallback? onDownload;
  final VoidCallback? onUpload;
  final VoidCallback? onImport;
  final VoidCallback? onExport;

  const MissionToolbar({
    super.key,
    this.onDownload,
    this.onUpload,
    this.onImport,
    this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onUpload,
                icon: Icon(Icons.upload, size: 18, color: Colors.orange),
                label: Text("Upload", style: TextStyle(color: Colors.orange)),
              ),
              const SizedBox(width: 6),
              OutlinedButton.icon(
                onPressed: onDownload,
                icon: Icon(Icons.download, size: 18, color: Colors.green),
                label: Text("Download", style: TextStyle(color: Colors.green)),
              ),
            ],
          ),
          const SizedBox(width: 6),
          OutlinedButton.icon(
            onPressed: () {
              MavlinkData.missionItems.clear();
              NotifierService.triggerMissionUpdate();
            },
            icon: Icon(
              Icons.cleaning_services_rounded,
              size: 18,
              color: Colors.red,
            ),
            label: Text("Clear", style: TextStyle(color: Colors.red)),
          ),
          const SizedBox(width: 6),
          Column(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onExport,
                icon: Icon(Icons.save_as_sharp, size: 18, color: Colors.purple),
                label: Text("Export", style: TextStyle(color: Colors.purple)),
              ),
              const SizedBox(width: 6),
              OutlinedButton.icon(
                onPressed: onImport,
                icon: Icon(Icons.folder_open, size: 18, color: Colors.blue),
                label: Text("Import", style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String text,
    VoidCallback? onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(text),
    );
  }
}
