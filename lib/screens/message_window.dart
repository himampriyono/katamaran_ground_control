import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dart_mavlink/dialects/common.dart';
import '../data/mavlink_data.dart';

class MessageWindow extends StatelessWidget {
  const MessageWindow({super.key});

  static String _decodeText(dynamic message) {
    final List<int> bytes = List<int>.from(
      message.text
          .map((byte) => (byte as int) & 0xFF)
          .takeWhile((byte) => byte != 0),
    );

    return utf8.decode(bytes, allowMalformed: true).trim();
  }

  static Color _severityColor(int severity) {
    if (severity <= mavSeverityError) {
      return Colors.redAccent;
    } else if (severity == mavSeverityWarning) {
      return Colors.yellowAccent;
    }

    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF141419),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: Colors.white.withAlpha(35)),
      ),
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
          child: _MessageWindowContent(),
        ),
      ),
    );
  }
}

class _MessageWindowContent extends StatelessWidget {
  const _MessageWindowContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // HEADER
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A20),
            border: Border(
              bottom: BorderSide(color: Colors.white.withAlpha(25)),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.article_outlined,
                color: Colors.orangeAccent,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MAVLink Messages',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    // const SizedBox(height: 4),
                    // AnimatedBuilder(
                    //   animation: MavlinkData.statusTextMessages,
                    //   builder: (context, child) {
                    //     final messages = MavlinkData.statusTextMessages.value;

                    //     return Text(
                    //       '${messages.length} STORED MESSAGES  •  LIVE FEED',
                    //       style: const TextStyle(
                    //         color: Colors.white38,
                    //         fontSize: 10,
                    //         letterSpacing: 1,
                    //       ),
                    //     );
                    //   },
                    // ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.red),
              ),
            ],
          ),
        ),

        // MESSAGE LIST
        Expanded(
          child: AnimatedBuilder(
            animation: MavlinkData.statusTextMessages,
            builder: (context, child) {
              final messages = MavlinkData.statusTextMessages.value;

              if (messages.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        color: Colors.white24,
                        size: 42,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No messages received',
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final dynamic message = messages[messages.length - 1 - index];

                  final int severity = message.severity;
                  final Color color = MessageWindow._severityColor(severity);
                  final String text = MessageWindow._decodeText(message);

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 6,
                    ),
                    child: SelectableText(
                      text,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        height: 1.5,
                        fontFamily: 'Courier',
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // FOOTER
        // Container(
        //   width: double.infinity,
        //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        //   decoration: BoxDecoration(
        //     border: Border(top: BorderSide(color: Colors.white.withAlpha(25))),
        //   ),
        //   child: const Text(
        //     'MAVLink STATUSTEXT',
        //     style: TextStyle(
        //       color: Colors.white30,
        //       fontSize: 10,
        //       letterSpacing: 1.5,
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
