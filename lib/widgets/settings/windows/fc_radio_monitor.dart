import 'package:flutter/material.dart';
import '../../../data/mavlink_data.dart';
import '../../../services/notifier_service.dart';
import '../widgets/channel_monitor_tile.dart';

class FcRadioMonitor extends StatelessWidget {
  const FcRadioMonitor({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1B1D22),
      child: SizedBox(
        width: 520,
        height: 570,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Ship Radio Monitor",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close, color: Colors.red, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                "Inspect RC channels received by ship.",
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: NotifierService.rcTrigger,
                  builder: (context, _, _) {
                    return ListView.separated(
                      itemCount: 16,
                      separatorBuilder: (_, _) {
                        return const SizedBox(height: 1);
                      },
                      itemBuilder: (_, index) {
                        return ChannelMonitorTile(
                          channel: index + 1,
                          value: MavlinkData.rcChannels[index],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
