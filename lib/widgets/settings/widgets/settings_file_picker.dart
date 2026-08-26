import 'package:flutter/material.dart';
import 'action_button.dart';

class SettingsFilePicker extends StatelessWidget {
  const SettingsFilePicker({
    super.key,
    required this.title,
    required this.path,
    required this.onBrowse,
  });

  final String title;
  final String path;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 16, 10),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(title),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Tooltip(
              message: path,
              child: Text(
                path.isEmpty ? "Not selected" : path,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white30
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          ActionButton(
            text: "Browse",
            color: Colors.deepOrange,
            onTap: onBrowse,
          ),
        ],
      ),
    );
  }
}