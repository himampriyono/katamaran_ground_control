import 'package:flutter/material.dart';
import '../../../utils/joystick.dart';
import '../widgets/action_button.dart';
import '../widgets/channel_monitor_tile.dart';
import '../../../data/app_data.dart';

class JoystickMonitorWindow extends StatelessWidget {
  const JoystickMonitorWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 760,
        height: 500,
        decoration: BoxDecoration(
          color: const Color(0xFF202020),
          border: Border.all(color: Colors.white24),
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
                  Icon(Icons.gamepad, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Joystick Channel Monitor",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close, size: 18, color: Colors.red),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ValueListenableBuilder<List<int>>(
                  valueListenable: AppData.joystickChannels,
                  builder: (context, channels, _) {
                    return Row(
                      children: [
                        // Kolom kiri (CH1 - CH8)
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
                                ),
                              );
                            }),
                          ),
                        ),

                        const SizedBox(width: 20),

                        // Kolom kanan (CH9 - CH16)
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
          ],
        ),
      ),
    );
  }
}
