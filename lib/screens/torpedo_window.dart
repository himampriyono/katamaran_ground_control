import 'package:flutter/material.dart';

import '../data/mavlink_data.dart';

class TorpedoWindow extends StatefulWidget {
  const TorpedoWindow({super.key});

  @override
  State<TorpedoWindow> createState() => _TorpedoWindowState();
}

class _TorpedoWindowState extends State<TorpedoWindow> {
  late final TextEditingController _headingController;
  late final TextEditingController _depthController;
  late final TextEditingController _powerController;
  late final TextEditingController _startDelayController;
  late final TextEditingController _durationController;

  @override
  void initState() {
    super.initState();

    final mission = MavlinkData.torpedo;

    _headingController = TextEditingController(
      text: _formatNumber(mission.heading),
    );

    _depthController = TextEditingController(
      text: _formatNumber(mission.depth),
    );

    _powerController = TextEditingController(
      text: _formatNumber(mission.power),
    );

    _startDelayController = TextEditingController(
      text: _formatNumber(mission.startDelay),
    );

    _durationController = TextEditingController(
      text: _formatNumber(mission.duration),
    );
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toString();
  }

  @override
  void dispose() {
    _headingController.dispose();
    _depthController.dispose();
    _powerController.dispose();
    _startDelayController.dispose();
    _durationController.dispose();

    super.dispose();
  }

  void _saveMission() {
    final heading = double.tryParse(_headingController.text.trim());
    final depth = double.tryParse(_depthController.text.trim());
    final power = double.tryParse(_powerController.text.trim());
    final startDelay = double.tryParse(_startDelayController.text.trim());
    final duration = double.tryParse(_durationController.text.trim());

    if (heading == null ||
        depth == null ||
        power == null ||
        startDelay == null ||
        duration == null) {
      _showError("Semua nilai harus berupa angka.");
      return;
    }

    MavlinkData.torpedo.heading = heading;
    MavlinkData.torpedo.depth = depth;
    MavlinkData.torpedo.power = power;
    MavlinkData.torpedo.startDelay = startDelay;
    MavlinkData.torpedo.duration = duration;

    debugPrint(
      "[TORPEDO] Mission data updated | "
      "Heading=$heading | "
      "Depth=$depth | "
      "Power=$power | "
      "StartDelay=$startDelay | "
      "Duration=$duration",
    );

    Navigator.of(context).pop();
  }

  void _resetMission() {
    setState(() {
      _headingController.text = "0";
      _depthController.text = "0";
      _powerController.text = "1500";
      _startDelayController.text = "0";
      _durationController.text = "-1";
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF18181E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.white12),
      ),
      child: SizedBox(
        width: 460,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.navigation, size: 20, color: Colors.white70),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "TORPEDO MISSION",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: "Close",
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              const Text(
                "Mission ini digunakan bersama oleh seluruh torpedo. "
                "Torpedo ID ditentukan saat switch joystick ditoggle.",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              _buildNumberField(
                controller: _headingController,
                label: "Heading",
                suffix: "deg",
              ),

              const SizedBox(height: 12),

              _buildNumberField(
                controller: _depthController,
                label: "Depth",
                suffix: "m",
              ),

              const SizedBox(height: 12),

              _buildNumberField(
                controller: _powerController,
                label: "Power",
                suffix: "PWM",
              ),

              const SizedBox(height: 12),

              _buildNumberField(
                controller: _startDelayController,
                label: "Launch Start Delay",
                suffix: "s",
              ),

              const SizedBox(height: 12),

              _buildNumberField(
                controller: _durationController,
                label: "Launch Duration",
                suffix: "s",
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetMission,
                      child: const Text("RESET"),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveMission,
                      child: const Text("SAVE"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      style: const TextStyle(fontSize: 14, color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        filled: true,
        fillColor: const Color(0xFF222229),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Colors.white54),
        ),
      ),
    );
  }
}
