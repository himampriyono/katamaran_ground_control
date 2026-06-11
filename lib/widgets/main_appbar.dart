import 'package:flutter/material.dart';
import '../data/mavlink_data.dart';

import '../data/app_data.dart';
import '../services/notifier_service.dart';

class MainAppbar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF101014),
      elevation: 0,
      title: Row(
        children: [
          const Icon(
            Icons.directions_boat_filled,
            color: Colors.white70,
            size: 22,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${(AppData.appName).toUpperCase()}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
              ),
              Text(
                "UDP PORT : ${MavlinkData.currentPort}",
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blueGrey[400],
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        AppBarIndicator(
          listenableStatus: AppData.joystickStatus,
          icon: Icons.sports_esports,
          tooltipMessage: "Joystick Controller Status",
        ),
        ValueListenableBuilder<int>(
          valueListenable: NotifierService.connectionTrigger,
          builder: (context, triggerValue, child) {
            return Tooltip(
              message: "Packet Received Per Second",
              child: Text(
                "${MavlinkData.packetsPerSecond} PPS",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontFamily: 'Courier',
                ),
              ),
            );
          },
        ),
        ValueListenableBuilder<int>(
          valueListenable: NotifierService.connectionTrigger,
          builder: (context, triggerValue, child) {
            final isConnected = MavlinkData.isMavlinkConnected;

            final Color neonColor = isConnected
                ? const Color(0xFF00FFCC)
                : const Color(0xFFFF0055);

            final Color bgColor = neonColor.withAlpha(20);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCirc,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border(
                    left: BorderSide(color: neonColor, width: 2.0),
                    right: BorderSide(
                      color: neonColor.withAlpha(100),
                      width: 1.0,
                    ),
                    top: BorderSide(color: neonColor.withAlpha(50), width: 1.0),
                    bottom: BorderSide(
                      color: neonColor.withAlpha(50),
                      width: 1.0,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: neonColor.withAlpha(30),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isConnected ? "CONNECTED" : "DISCONNECTED",
                      style: TextStyle(
                        color: neonColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            color: neonColor.withAlpha(150),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withAlpha(0),
                Colors.white.withAlpha(50),
                Colors.white.withAlpha(0),
              ],
            ),
          ),
          height: 1,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class AppBarIndicator extends StatelessWidget {
  final ValueNotifier<bool> listenableStatus;
  final IconData icon;
  final String tooltipMessage;

  const AppBarIndicator({
    super.key,
    required this.listenableStatus,
    required this.icon,
    required this.tooltipMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: listenableStatus,
      builder: (context, isActive, _) {
        return Tooltip(
          message: tooltipMessage,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(
              icon,
              color: isActive ? Colors.green : Colors.red,
              size: 18,
            ),
          ),
        );
      },
    );
  }
}
