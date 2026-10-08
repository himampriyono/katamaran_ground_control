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
    return AlertDialog(
      title: const Text('Custom Torpedo Target'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
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
      ),
      actions: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ActionButton(
              text: "CANCEL",
              color: Colors.red,
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(width: 12),
            ActionButton(
              text: "RESET TORPEDO",
              color: Colors.orange,
              onTap: () {
                for (int torpedoId = 21; torpedoId <= 24; torpedoId++) {
                  MavlinkService.sendTorpedoReset(torpedoId: torpedoId);
                }
              },
            ),
            const SizedBox(width: 12),
            ActionButton(
              text: "SAVE",
              color: Colors.green,
              onTap: () {
                _saveTorpedoMission();
              },
            ),
          ],
        ),
      ],
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
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 2),
                Text(
                  'Calculate heading to locked target automatically',
                  style: TextStyle(fontSize: 12),
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
}
