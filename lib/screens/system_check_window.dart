import 'package:flutter/material.dart';
import 'dart:async';
import '../data/app_data.dart';
import '../data/mavlink_data.dart';
import '../services/mavlink_server_service.dart';

class SystemCheckWindow extends StatelessWidget {
  const SystemCheckWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1100,
          maxHeight: 750,
          minWidth: 520,
          minHeight: 360,
        ),
        child: const SizedBox(
          width: 700,
          height: 600,
          child: _SystemCheckContent(),
        ),
      ),
    );
  }
}

class _SystemCheckContent extends StatefulWidget {
  const _SystemCheckContent();

  @override
  State<_SystemCheckContent> createState() => _SystemCheckContentState();
}

class _SystemCheckContentState extends State<_SystemCheckContent> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateData();
      MavlinkServerService.instance.requestCamStatus();
    });
  }

  void _updateData() {
    if (!mounted) return;

    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SYSTEM CHECK',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, size: 16, color: Colors.red),
              ),
            ],
          ),
        ),
        const Divider(thickness: 0.5, height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              const Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      'CHECK LIST',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'ACTUAL DATA',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 75,
                    child: Center(
                      child: Text(
                        'STATUS',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(thickness: 0.5),
              ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(scrollbars: false),
                child: Column(
                  spacing: 12,
                  children: [
                    _systemCheckItem(
                      'MAVlink Connection',
                      MavlinkData.isMavlinkConnected
                          ? 'Connected'
                          : 'Disconnected',
                      MavlinkData.isMavlinkConnected,
                    ),
                    _systemCheckItem(
                      'front Camera',
                      AppData.camFrontReady ? 'Connected' : 'Disconnected',
                      AppData.camFrontReady,
                    ),
                    _systemCheckItem(
                      'Left Camera',
                      AppData.camLeftReady ? 'Connected' : 'Disconnected',
                      AppData.camLeftReady,
                    ),
                    _systemCheckItem(
                      'Rear Camera',
                      AppData.camRearReady ? 'Connected' : 'Disconnected',
                      AppData.camRearReady,
                    ),
                    _systemCheckItem(
                      'Right Camera',
                      AppData.camRightReady ? 'Connected' : 'Disconnected',
                      AppData.camRightReady,
                    ),
                    _systemCheckItem(
                      'Joystick Connection',
                      AppData.joystickStatus.value == JoystickStatus.connected
                          ? 'Connected'
                          : 'Disconnected',
                      AppData.joystickStatus.value == JoystickStatus.connected,
                    ),
                    _systemCheckItem(
                      'Engine 1',
                      "${MavlinkData.boatEngineTelemetry.value.motor1Rpm!.toStringAsFixed(0)} RPM",
                      (MavlinkData.boatEngineTelemetry.value.motor1Rpm!) > 0,
                    ),
                    _systemCheckItem(
                      'Engine 2',
                      "${MavlinkData.boatEngineTelemetry.value.motor2Rpm!.toStringAsFixed(0)} RPM",
                      (MavlinkData.boatEngineTelemetry.value.motor2Rpm!) > 0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _systemCheckItem(String varName, Object? value, bool isPassed) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      border: Border.all(
        color: isPassed ? Colors.green : Colors.red,
        width: 0.5,
      ),
    ),
    child: Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(varName, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value?.toString() ?? '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(
          width: 75,
          child: Center(
            child: Text(
              isPassed ? 'PASS' : 'FAIL',
              style: TextStyle(
                color: isPassed ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
