import 'package:flutter/material.dart';

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
              _buildButton(
                icon: Icons.upload,
                text: "Upload",
                onPressed: onUpload,
              ),
              const SizedBox(width: 6),
              OutlinedButton.icon(
                onPressed: onDownload,
                icon: Icon(Icons.download, size: 18),
                label: Text("Download"),
              ),
            ],
          ),
          const SizedBox(width: 6),
          Column(
            spacing: 8,
            children: [
              _buildButton(
                icon: Icons.save_alt,
                text: "Export",
                onPressed: onExport,
              ),
              const SizedBox(width: 6),
              _buildButton(
                icon: Icons.folder_open,
                text: "Import",
                onPressed: onImport,
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
