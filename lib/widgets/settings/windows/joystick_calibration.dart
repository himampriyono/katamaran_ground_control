import 'package:flutter/material.dart';

import '../../../data/app_data.dart';
import '../../../utils/joystick.dart';
import '../widgets/action_button.dart';
import '../widgets/channel_monitor_tile.dart';

class JoystickCalibration extends StatelessWidget {
  const JoystickCalibration({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 760,
        height: 500,
        decoration: BoxDecoration(
          color: const Color(0xFF202020),
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF2A2A2A),
                border: Border(bottom: BorderSide(color: Colors.white24)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tune, size: 18),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Joystick Calibration Window",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  ValueListenableBuilder(
                    valueListenable: AppData.joystickCalibrationStatus,
                    builder: (context, status, _) {
                      final calibrating =
                          status == JoystickCalibrationStatus.calibrating;

                      return Row(
                        children: [
                          SizedBox(width: 24),
                          Icon(
                            Icons.circle,
                            size: 10,
                            color: calibrating ? Colors.orange : Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            calibrating ? "Calibrating" : "Ready",
                            style: TextStyle(
                              color: calibrating ? Colors.orange : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close, color: Colors.red, size: 18),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ValueListenableBuilder(
                  valueListenable: AppData.joystickChannels,
                  builder: (context, channels, _) {
                    final channels = AppData.joystickChannels.value;
                    final minValues = AppData.joystickCalibrationMin.value;
                    final maxValues = AppData.joystickCalibrationMax.value;
                    final isCalibrating =
                        AppData.joystickCalibrationStatus.value ==
                        JoystickCalibrationStatus.calibrating;
                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: List.generate(8, (index) {
                              final value = index < channels.length
                                  ? channels[index]
                                  : 1500;

                              return Expanded(
                                child: ChannelMonitorTile(
                                  channel: index + 1,
                                  value: value,
                                  minValue: isCalibrating
                                      ? minValues[index]
                                      : null,
                                  maxValue: isCalibrating
                                      ? maxValues[index]
                                      : null,
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            children: List.generate(8, (index) {
                              final channelIndex = index + 8;

                              final value = channelIndex < channels.length
                                  ? channels[channelIndex]
                                  : 1500;

                              return Expanded(
                                child: ChannelMonitorTile(
                                  channel: channelIndex + 1,
                                  value: value,
                                  minValue: isCalibrating
                                      ? minValues[channelIndex]
                                      : null,
                                  maxValue: isCalibrating
                                      ? maxValues[channelIndex]
                                      : null,
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            Container(
              height: 60,
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white24)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // const Spacer(),
                  ValueListenableBuilder(
                    valueListenable: AppData.joystickCalibrationStatus,
                    builder: (context, status, _) {
                      final calibrating =
                          status == JoystickCalibrationStatus.calibrating;

                      return GestureDetector(
                        onTap: () {
                          if (!calibrating) {
                            Joystick.startCalibration();
                          } else {
                            Joystick.stopCalibration();
                          }
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            height: 34,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: (calibrating ? Colors.orange : Colors.cyan)
                                  .withAlpha(20),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: calibrating
                                    ? Colors.orange
                                    : Colors.cyan,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  calibrating ? Icons.save : Icons.tune,
                                  size: 16,
                                  color: calibrating
                                      ? Colors.orange
                                      : Colors.cyan,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  calibrating
                                      ? "Save Calibration"
                                      : "Start Calibration",
                                  style: TextStyle(
                                    color: calibrating
                                        ? Colors.orange
                                        : Colors.cyan,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
