import 'package:flutter/material.dart';
import '../../../services/settings_service.dart';

class JoystickReverseWindow extends StatefulWidget {
  const JoystickReverseWindow({super.key});

  @override
  State<JoystickReverseWindow> createState() => _JoystickReverseWindowState();
}

class _JoystickReverseWindowState extends State<JoystickReverseWindow> {
  int _reverseMask = 0;

  @override
  void initState() {
    super.initState();

    _reverseMask = SettingsService.joystickReverseMask;
  }

  // ===============================================================
  // CHANNEL STATE
  // ===============================================================

  bool _isReversed(int channel) {
    if (channel < 1 || channel > 16) {
      return false;
    }

    final bit = 1 << (channel - 1);

    return (_reverseMask & bit) != 0;
  }

  // ===============================================================
  // SET CHANNEL STATE
  // ===============================================================

  Future<void> _setReversed(int channel, bool reversed) async {
    if (channel < 1 || channel > 16) {
      return;
    }

    final bit = 1 << (channel - 1);

    int newMask;

    if (reversed) {
      newMask = _reverseMask | bit;
    } else {
      newMask = _reverseMask & ~bit;
    }

    // Update UI state immediately.
    setState(() {
      _reverseMask = newMask;
    });

    // Persist the complete mask.
    await SettingsService.setJoystickReverseMask(newMask);
  }

  // ===============================================================
  // RESET ALL
  // ===============================================================

  Future<void> _resetAll() async {
    setState(() {
      _reverseMask = 0;
    });

    await SettingsService.setJoystickReverseMask(0);
  }

  // ===============================================================
  // COUNT
  // ===============================================================

  int _countReversedChannels() {
    int count = 0;

    for (int i = 0; i < 16; i++) {
      if ((_reverseMask & (1 << i)) != 0) {
        count++;
      }
    }

    return count;
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    final reversedCount = _countReversedChannels();

    return Center(
      child: Material(
        color: Colors.transparent,
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
              _buildHeader(context),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Column(
                    children: [
                      _buildSummary(reversedCount: reversedCount),

                      const SizedBox(height: 14),

                      Expanded(child: _buildChannelArea()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // HEADER
  // ===============================================================

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A2A),
        border: Border(bottom: BorderSide(color: Colors.white24)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.cyan.withAlpha(20),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.cyan.withAlpha(80)),
            ),
            child: const Icon(Icons.swap_vert, size: 18, color: Colors.cyan),
          ),

          const SizedBox(width: 10),

          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Joystick Channel Reverse",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 2),
                Text(
                  "Configure input direction for each channel",
                  style: TextStyle(fontSize: 9, color: Colors.white38),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.close, size: 18, color: Colors.red),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // SUMMARY
  // ===============================================================

  Widget _buildSummary({required int reversedCount}) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF292929),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: reversedCount > 0
                  ? Colors.cyan.withAlpha(20)
                  : Colors.white.withAlpha(5),
              shape: BoxShape.circle,
              border: Border.all(
                color: reversedCount > 0
                    ? Colors.cyan.withAlpha(70)
                    : Colors.white10,
              ),
            ),
            child: Center(
              child: Text(
                "$reversedCount",
                style: TextStyle(
                  color: reversedCount > 0 ? Colors.cyan : Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "REVERSED CHANNELS",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 9,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "Selected channels invert their input direction.",
                  style: TextStyle(color: Colors.white30, fontSize: 9),
                ),
              ],
            ),
          ),

          TextButton(
            onPressed: _resetAll,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              "RESET ALL",
              style: TextStyle(
                color: Colors.orangeAccent,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // CHANNEL AREA
  // ===============================================================

  Widget _buildChannelArea() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: 8,
            itemBuilder: (context, index) {
              final channel = index + 1;

              return _buildChannelTile(
                key: ValueKey(channel),
                channel: channel,
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 8);
            },
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: 8,
            itemBuilder: (context, index) {
              final channel = index + 9;

              return _buildChannelTile(
                key: ValueKey(channel),
                channel: channel,
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 8);
            },
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // CHANNEL TILE
  // ===============================================================

  Widget _buildChannelTile({required Key key, required int channel}) {
    final reversed = _isReversed(channel);

    return Container(
      key: key,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: reversed ? Colors.cyan.withAlpha(18) : const Color(0xFF292929),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: reversed ? Colors.cyan.withAlpha(100) : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 24,
            decoration: BoxDecoration(
              color: reversed
                  ? Colors.cyan.withAlpha(20)
                  : Colors.white.withAlpha(8),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Center(
              child: Text(
                "$channel",
                style: TextStyle(
                  color: reversed ? Colors.cyan : Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "CH$channel",
                  style: TextStyle(
                    color: reversed ? Colors.cyan : Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  reversed ? "REVERSE" : "NORMAL",
                  style: TextStyle(
                    color: reversed
                        ? Colors.cyan.withAlpha(180)
                        : Colors.white30,
                    fontSize: 8,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),

          Switch(
            value: reversed,
            activeColor: Colors.cyan,
            onChanged: (value) {
              _setReversed(channel, value);
            },
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // CUSTOM TOGGLE
  // ===============================================================

  Widget _buildToggle({required bool active}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 38,
      height: 22,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: active ? Colors.cyan.withAlpha(45) : Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? Colors.cyan.withAlpha(130) : Colors.white12,
        ),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 120),
        alignment: active ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: active ? Colors.cyan : Colors.white38,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
