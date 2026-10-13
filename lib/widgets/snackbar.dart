import 'package:flutter/material.dart';

class Snackbar {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void show(String pesan, {bool isWarning = false}) {
    messengerKey.currentState?.clearSnackBars();

    final Color colorAccent = isWarning
        ? const Color(0xFFFF3333)
        : const Color.fromARGB(255, 8, 153, 8);
    final IconData statusIcon = isWarning
        ? Icons.report_problem_rounded
        : Icons.info;
    final String labelTipe = isWarning ? "SYSTEM WARNING" : "SYSTEM INFO";

    messengerKey.currentState?.showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(left: 20, bottom: 20, right: 450),
        duration: const Duration(seconds: 3),
        content: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(
              220,
              37,
              37,
              37,
            ),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white10, width: 1),
            boxShadow: [
              BoxShadow(
                color: colorAccent.withAlpha(
                  20,
                ),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Row(
              children: [
                Container(width: 4, height: 48, color: colorAccent),
                const SizedBox(width: 14),

                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: colorAccent.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    statusIcon,
                    color: colorAccent,
                    size: 16,
                    shadows: [
                      Shadow(color: Colors.black.withAlpha(100), blurRadius: 2),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          labelTipe,
                          style: TextStyle(
                            color: colorAccent.withAlpha(180),
                            fontFamily: 'Courier',
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withAlpha(200),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          pesan,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Courier',
                            fontSize: 12,
                            letterSpacing: 0.3,
                            shadows: [
                              Shadow(
                                color: Colors.black.withAlpha(200),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white30,
                    size: 14,
                  ),
                  onPressed: () {
                    messengerKey.currentState?.hideCurrentSnackBar();
                  },
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.only(right: 12, left: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
