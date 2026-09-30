// import 'package:dart_mavlink/dialects/common.dart';
import 'package:dart_mavlink/dialects/ardupilotmega.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../data/mavlink_data.dart';
import '../../../services/notifier_service.dart';
import '../../map/map.dart';
import '../widgets/mission_panel.dart';

class MissionEditor extends StatefulWidget {
  const MissionEditor({super.key});

  @override
  State<MissionEditor> createState() => _MissionEditorState();
}

class _MissionEditorState extends State<MissionEditor> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(32),
      child: SizedBox(
        width: 1800,
        height: 1000,
        child: Column(
          children: [
            _buildHeader(context),
            const Divider(),
            Expanded(
              child: Row(
                children: [
                  MissionPanel(),
                  const VerticalDivider(width: 1),
                  _buildMapPanel(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Icon(Icons.route),
          const SizedBox(width: 12),
          const Text(
            "Mission Editor",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPanel(BuildContext context) {
    return Expanded(child: MapWidget(onMapTap: _addMissionWaypoint));
  }

  void _addMissionWaypoint(LatLng point) {
    final mission = MissionItem(
      param1: 0,
      param2: 0,
      param3: 0,
      param4: double.nan,
      x: point.latitude,
      y: point.longitude,
      z: 0,
      seq: MavlinkData.missionItems.isEmpty
          ? 1
          : MavlinkData.missionItems.last.seq + 1,
      command: mavCmdNavWaypoint,
      targetSystem: MavlinkData.targetSystemId ?? 1,
      targetComponent: MavlinkData.targetComponentId ?? 1,
      frame: mavFrameGlobalRelativeAlt,
      current: 0,
      autocontinue: 1,
      missionType: mavMissionTypeMission,
    );

    MavlinkData.missionItems.add(mission);
    NotifierService.triggerMissionUpdate();
  }
}
