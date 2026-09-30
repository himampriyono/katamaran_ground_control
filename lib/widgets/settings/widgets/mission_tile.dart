// import 'package:dart_mavlink/dialects/common.dart';
import 'package:dart_mavlink/dialects/ardupilotmega.dart';
import 'package:flutter/material.dart';
import '../../../utils/mission_extensions.dart';

class MissionTile extends StatelessWidget {
  final MissionItem mission;

  const MissionTile({super.key, required this.mission});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(width: 75, child: Text("${mission.seq}")),
          Text(mission.commandName, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.cyan),),
          const Spacer(),
          SizedBox(
            width: 200,
            child: Text(
              "${mission.x.toStringAsFixed(7)}, ${mission.y.toStringAsFixed(7)}",
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
