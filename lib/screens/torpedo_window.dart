import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/settings/widgets/action_button.dart';
import '../../data/mavlink_data.dart';
import '../services/mavlink_service.dart';
import '../services/settings_service.dart';

class TorpedoWindow extends StatefulWidget {
  const TorpedoWindow({super.key});

  @override
  State<TorpedoWindow> createState() => _TorpedoWindowState();
}

class _TorpedoWindowState extends State<TorpedoWindow> {
  late final TextEditingController _headingController;
  late final TextEditingController _depthController;
  late final TextEditingController _rpmController;
  late final TextEditingController _startDelayController;
  late final TextEditingController _durationController;

  late bool _autoTargetHeading;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();

    final mission = MavlinkData.torpedo;

    _autoTargetHeading = mission.autoTargetHeading;

    _headingController = TextEditingController(
      text: mission.heading.toString(),
    );

    _depthController = TextEditingController(text: mission.depth.toString());

    _rpmController = TextEditingController(
      text: mission.power.toStringAsFixed(0),
    );

    _startDelayController = TextEditingController(
      text: mission.startDelay.toString(),
    );

    _durationController = TextEditingController(
      text: mission.duration.toString(),
    );
  }

  @override
  void dispose() {
    _headingController.dispose();
    _depthController.dispose();
    _rpmController.dispose();
    _startDelayController.dispose();
    _durationController.dispose();

    super.dispose();
  }

  Future<void> _saveTorpedoMission() async {
    final heading = double.tryParse(_headingController.text);

    final depth = double.tryParse(_depthController.text);

    final rpm = double.tryParse(_rpmController.text);

    final startDelay = double.tryParse(_startDelayController.text);

    final duration = double.tryParse(_durationController.text);

    if (heading == null ||
        depth == null ||
        rpm == null ||
        startDelay == null ||
        duration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid torpedo mission value.')),
      );

      return;
    }

    if (depth < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Depth cannot be negative.')),
      );

      return;
    }

    if (rpm < 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('RPM cannot be negative.')));

      return;
    }

    if (startDelay < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start delay cannot be negative.')),
      );

      return;
    }

    final mission = MavlinkData.torpedo;

    mission.autoTargetHeading = _autoTargetHeading;
    mission.heading = heading;
    mission.depth = depth;
    mission.power = rpm;
    mission.startDelay = startDelay;
    mission.duration = duration;

    await SettingsService.setTorpedoMission(mission);

    debugPrint(
      '[TORPEDO] Mission settings updated | '
      'Mode=${mission.autoTargetHeading ? "AUTO" : "MANUAL"} | '
      'Heading=${mission.heading} | '
      'Depth=${mission.depth} | '
      'RPM=${mission.power} | '
      'StartDelay=${mission.startDelay} | '
      'Duration=${mission.duration}',
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (tabContext) {
          return AlertDialog(
            title: const Text('TORPEDO MENU', textAlign: TextAlign.center,),
            content: SizedBox(
              width: 720,
              height: 640,
              child: Column(
                children: [
                  const Divider(),
                  TabBar(
                    onTap: (index) {
                      setState(() {
                        _selectedTab = index;
                      });
                    },
                    tabs: const [
                      Tab(text: 'GRIPPER CONTROL'),
                      Tab(text: 'MISSION'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TabBarView(
                      children: [
                        SingleChildScrollView(child: _buildGripperControls()),
                        SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildHeadingMode(),
                              const SizedBox(height: 16),
                              _buildNumberField(
                                controller: _headingController,
                                label: 'Manual Heading',
                                suffix: '°',
                                enabled: !_autoTargetHeading,
                                decimal: true,
                              ),
                              const SizedBox(height: 12),
                              _buildNumberField(
                                controller: _depthController,
                                label: 'Depth',
                                suffix: 'm',
                                decimal: true,
                              ),
                              const SizedBox(height: 12),
                              _buildNumberField(
                                controller: _rpmController,
                                label: 'RPM',
                                decimal: false,
                              ),
                              const SizedBox(height: 12),
                              _buildNumberField(
                                controller: _startDelayController,
                                label: 'Start Delay',
                                suffix: 's',
                                decimal: true,
                              ),
                              const SizedBox(height: 12),
                              _buildNumberField(
                                controller: _durationController,
                                label: 'Duration',
                                suffix: 's',
                                decimal: true,
                                signed: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              if (_selectedTab == 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ActionButton(
                      text: 'CANCEL',
                      color: Colors.red,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 12),
                    ActionButton(
                      text: 'RESET TORPEDO',
                      color: Colors.orange,
                      onTap: () {
                        for (int torpedoId = 21; torpedoId <= 24; torpedoId++) {
                          MavlinkService.sendTorpedoReset(torpedoId: torpedoId);
                        }
                      },
                    ),
                    const SizedBox(width: 12),
                    ActionButton(
                      text: 'SAVE',
                      color: Colors.green,
                      onTap: _saveTorpedoMission,
                    ),
                  ],
                )
              else
                Align(
                  alignment: Alignment.centerRight,
                  child: ActionButton(
                    text: 'CANCEL',
                    color: Colors.red,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeadingMode() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          const Icon(Icons.navigation_rounded, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auto Set Heading To Target',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                SizedBox(height: 2),
                Text(
                  'Calculate heading to locked target automatically',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          Switch(
            value: _autoTargetHeading,
            onChanged: (value) {
              setState(() {
                _autoTargetHeading = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    String? suffix,
    bool enabled = true,
    bool decimal = true,
    bool signed = false,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      style: TextStyle(fontSize: 16),
      keyboardType: TextInputType.numberWithOptions(
        decimal: decimal,
        signed: signed,
      ),
      inputFormatters: [
        if (decimal)
          FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))
        else
          FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildGripperControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Manual Gripper Control',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 32),

        for (final torpedoId in [21, 22, 23, 24])
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GRIPPER ${torpedoId - 20}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                ActionButton(
                  text: 'OPEN',
                  color: Colors.green,
                  onTap: () =>
                      _sendGripperCommand(torpedoId: torpedoId, open: true),
                ),
                const SizedBox(width: 8),
                ActionButton(
                  text: 'CLOSE',
                  color: Colors.red,
                  onTap: () =>
                      _sendGripperCommand(torpedoId: torpedoId, open: false),
                ),
              ],
            ),
          ),

        const SizedBox(height: 4),
        // const Text(
        //   'Gripper position is not confirmed by telemetry.',
        //   style: TextStyle(fontSize: 11),
        // ),
      ],
    );
  }

  void _sendGripperCommand({required int torpedoId, required bool open}) {
    MavlinkService.sendTorpedoGripper(torpedoId: torpedoId, open: open);

    debugPrint(
      '[GRIPPER] ${open ? "OPEN" : "CLOSE"} command sent '
      'to torpedo $torpedoId',
    );
  }
}
