import 'package:flutter/material.dart';

class ChannelMonitorTile extends StatelessWidget {
  final int channel;
  final int value;
  final int? minValue;
  final int? maxValue;

  const ChannelMonitorTile({
    super.key,
    required this.channel,
    required this.value,
    this.minValue,
    this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: Text(
              "CH${channel.toString().padLeft(2, '0')}",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),

          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final x = ((value.clamp(1000, 2000) - 1000) / 1000) * width;

                final double? minX = minValue != null
                    ? ((minValue!.clamp(1000, 2000) - 1000) / 1000) * width
                    : null;

                final double? maxX = maxValue != null
                    ? ((maxValue!.clamp(1000, 2000) - 1000) / 1000) * width
                    : null;

                return Stack(
                  alignment: Alignment.centerLeft,

                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Container(
                      width: x,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.cyan,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Positioned(
                      left: x - 4,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    if (minX != null)
                      Positioned(
                        left: minX - 1,
                        child: Container(
                          width: 4,
                          height: 10,
                          color: Colors.red,
                        ),
                      ),

                    if (maxX != null)
                      Positioned(
                        left: maxX - 1,
                        child: Container(
                          width: 4,
                          height: 10,
                          color: Colors.red,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          SizedBox(
            width: 42,
            child: Text(
              "$value",
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
