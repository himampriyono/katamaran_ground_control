import 'package:dart_mavlink/dialects/common.dart';
import 'package:flutter/material.dart';
import '../../../utils/mission_extensions.dart';

class MissionEditorTile extends StatelessWidget {
  final MissionItem mission;

  const MissionEditorTile({super.key, required this.mission});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text("${mission.seq}", overflow: TextOverflow.ellipsis),
          ),
          SizedBox(
            width: 180,
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 24,
                        child: Icon(Icons.arrow_drop_down, size: 18),
                      ),
                      Text(
                        mission.commandName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.cyan),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              mission.x.toStringAsFixed(7),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              mission.y.toStringAsFixed(7),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          const Icon(Icons.drag_handle, color: Colors.white54),
        ],
      ),
    );
  }
}
