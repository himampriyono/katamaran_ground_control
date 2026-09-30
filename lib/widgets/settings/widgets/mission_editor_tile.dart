// import 'package:dart_mavlink/dialects/common.dart';
import 'package:dart_mavlink/dialects/ardupilotmega.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../data/mavlink_data.dart';
import '../../../services/notifier_service.dart';
import '../../../utils/mission_extensions.dart';

class MissionEditorTile extends StatelessWidget {
  final MissionItem mission;
  final ValueChanged<MissionItem> onMissionChange;
  final MissionItem? previousMission;
  final VoidCallback onDelete;

  const MissionEditorTile({
    super.key,
    required this.mission,
    required this.onMissionChange,
    required this.previousMission,
    required this.onDelete,
  });

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
            child: _MissionCommandCell(
              mission: mission,
              onChanged: _changeCommand,
            ),
          ),
          SizedBox(
            width: 100,
            child: _MissionCoordinateCell(
              value: mission.x,
              onTap: () => _showCoordinateDialog(context),
            ),
          ),
          SizedBox(
            width: 100,
            child: _MissionCoordinateCell(
              value: mission.y,
              onTap: () => _showCoordinateDialog(context),
            ),
          ),
          SizedBox(
            width: 70,
            child: _MissionDistanceCell(
              previousMission: previousMission,
              mission: mission,
            ),
          ),
          SizedBox(
            width: 45,
            child: IconButton(
              tooltip: "Delete waypoint",
              splashRadius: 18,
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.delete_outline,
                size: 18,
                color: Colors.redAccent,
              ),
              onPressed: onDelete,
            ),
          ),
          ReorderableDragStartListener(
            index: mission.seq,
            child: const Icon(Icons.menu_sharp, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  void _changeCommand(int command) {
    onMissionChange(mission.copyWith(command: command));
  }

  void _changeLatitude(double latitude) {
    onMissionChange(mission.copyWith(x: latitude));
  }

  void _changeLongitude(double longitude) {
    onMissionChange(mission.copyWith(y: longitude));
  }

  void _changeAltitude(double altitude) {
    onMissionChange(mission.copyWith(z: altitude));
  }

  void _changeSequence(int seq) {
    onMissionChange(mission.copyWith(seq: seq));
  }

  Future<void> _showCoordinateDialog(BuildContext context) async {
    final latitudeController = TextEditingController(
      text: mission.x.toStringAsFixed(7),
    );

    final longitudeController = TextEditingController(
      text: mission.y.toStringAsFixed(7),
    );

    final result = await showDialog<(double, double)>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Coordinate"),
          content: SizedBox(
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: latitudeController,
                  decoration: const InputDecoration(labelText: "Latitude"),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: longitudeController,
                  decoration: const InputDecoration(labelText: "Latitude"),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () {
                final lat = double.tryParse(latitudeController.text);
                final lon = double.tryParse(longitudeController.text);

                if (lat == null || lon == null) {
                  return;
                }
                Navigator.pop(context, (lat, lon));
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );

    latitudeController.dispose();
    longitudeController.dispose();

    if (result == null) {
      return;
    }

    onMissionChange(mission.copyWith(x: result.$1, y: result.$2));
  }
}

class _MissionCommandCell extends StatelessWidget {
  const _MissionCommandCell({required this.mission, required this.onChanged});

  final MissionItem mission;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      tooltip: "",
      onSelected: (value) {
        onChanged(value);
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 22, child: Text("TAKEOFF")),
        PopupMenuItem(value: 16, child: Text("WAYPOINT")),
        PopupMenuItem(value: 21, child: Text("LAND")),
        PopupMenuItem(value: 20, child: Text("RTL")),
      ],
      child: Row(
        children: [
          const SizedBox(
            width: 24,
            child: Icon(Icons.arrow_drop_down, size: 18),
          ),
          Expanded(
            child: Text(
              mission.commandName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.cyan),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionCoordinateCell extends StatelessWidget {
  const _MissionCoordinateCell({required this.value, required this.onTap});

  final double value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(value.toStringAsFixed(7), overflow: TextOverflow.ellipsis),
    );
  }
}

class _MissionDistanceCell extends StatelessWidget {
  const _MissionDistanceCell({
    required this.previousMission,
    required this.mission,
  });

  final MissionItem? previousMission;
  final MissionItem mission;

  @override
  Widget build(BuildContext context) {
    if (previousMission == null) {
      return const Text(
        "---",
        textAlign: TextAlign.right,
        style: TextStyle(color: Colors.white54),
      );
    }

    const distance = Distance();

    final meter = distance(
      LatLng(previousMission!.x, previousMission!.y),
      LatLng(mission.x, mission.y),
    );

    final text = meter >= 1000
        ? "${(meter / 1000).toStringAsFixed(2)} km"
        : "${meter.toStringAsFixed(1)} m";

    return Text(
      text,
      textAlign: TextAlign.right,
      style: const TextStyle(color: Colors.white70, fontSize: 12),
      overflow: TextOverflow.ellipsis,
    );
  }
}
