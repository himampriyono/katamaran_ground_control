import 'package:flutter/material.dart';

class PwmOutputTile extends StatelessWidget {
  final int output;
  final int value;

  const PwmOutputTile({super.key, required this.output, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(
              "Out ${output.toString().padLeft(2, '0')}",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final x = ((value.clamp(1000, 2000) - 1000) / 1000) * width;

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
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Positioned(
                      left: x - 4,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
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
              style: TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
