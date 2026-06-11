import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../utils/joystick_handler.dart';

class SettingMenu extends StatelessWidget {
  final VoidCallback onClose;

  const SettingMenu({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF141419),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white30,
                  size: 18,
                ),
                tooltip: "Back to Status",
                onPressed: onClose,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),

              const Text(
                "SETTINGS",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDisplaySettingManu(context),
                _buildDisplayControlManu(context),
                _buildMenuPlaceholder("KONFIGURASI SISTEM"),
                _buildMenuPlaceholder("PARAMETER TAKTIS"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuPlaceholder(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A20),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
              fontFamily: 'Courier',
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white30, size: 16),
        ],
      ),
    );
  }

  Widget _buildDisplaySettingManu(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A20),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white10),
        ),
        child: ExpansionTile(
          title: const Text(
            "DISPLAY SETTING",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontFamily: 'Courier',
              fontWeight: FontWeight.bold,
            ),
          ),
          childrenPadding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
          ),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 8),
            const Text(
              "SPEED UNIT",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 10,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder(
              valueListenable: AppData.selectedSpeedUnit,
              builder: (context, currentSpeed, _) {
                return Row(
                  children: [
                    _buildSegmentButton(
                      label: "METRIC (m/s)",
                      isSelected: currentSpeed == SpeedUnit.metric,
                      onTap: () =>
                          AppData.selectedSpeedUnit.value = SpeedUnit.metric,
                    ),
                    const SizedBox(width: 8),
                    _buildSegmentButton(
                      label: "NAVAL (knots)",
                      isSelected: currentSpeed == SpeedUnit.naval,
                      onTap: () =>
                          AppData.selectedSpeedUnit.value = SpeedUnit.naval,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            const Text(
              "POSITION FORMAT",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 10,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<PositionUnit>(
              valueListenable: AppData.selectedPosUnit,
              builder: (context, currentPos, _) {
                return Row(
                  children: [
                    _buildSegmentButton(
                      label: "LAT / LON DEC",
                      isSelected: currentPos == PositionUnit.latlon,
                      onTap: () =>
                          AppData.selectedPosUnit.value = PositionUnit.latlon,
                    ),
                    const SizedBox(width: 8),
                    _buildSegmentButton(
                      label: "UTM COORDINATE",
                      isSelected: currentPos == PositionUnit.utm,
                      onTap: () =>
                          AppData.selectedPosUnit.value = PositionUnit.utm,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayControlManu(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A20),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white10),
        ),
        child: ExpansionTile(
          title: const Text(
            "CONTROL SETTING",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontFamily: 'Courier',
              fontWeight: FontWeight.bold,
            ),
          ),
          childrenPadding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
          ),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 8),
            const Text(
              "Joystick Port",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 10,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Material(
              color: Colors.transparent,
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(canvasColor: const Color(0xFF1A1A20)),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF141419),
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Courier',
                  ),
                  dropdownColor: const Color(0xFF1A1A20),
                  value:
                      AppData.selectedPort.isNotEmpty &&
                          AppData.availablePorts.contains(AppData.selectedPort)
                      ? AppData.selectedPort
                      : null,
                  hint: const Text(
                    "Pilih Port COM",
                    style: TextStyle(color: Colors.white24, fontSize: 12),
                  ),
                  isExpanded: true,
                  items: AppData.availablePorts.map((String port) {
                    return DropdownMenuItem<String>(
                      value: port,
                      child: Text(
                        port,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? portBaru) {
                    if (portBaru != null) {
                      // setState(() {
                      AppData.selectedPort = portBaru;
                      // });
                      JoystickHandler.disconnectJoystick();
                      debugPrint(
                        "User mengubah joystick ke port: ${AppData.selectedPort}",
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(2),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF00FFCC).withAlpha(30)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: isSelected ? const Color(0xFF00FFCC) : Colors.white12,
              width: 1.0,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF00FFCC) : Colors.white60,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontFamily: 'Courier',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
