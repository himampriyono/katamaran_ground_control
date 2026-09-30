import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/notifier_service.dart';
import '../data/app_data.dart';
import '../services/mavlink_service.dart';
import '../data/mavlink_data.dart';
import '../utils/app_utils.dart';

class MainSidePanel extends StatelessWidget {
  const MainSidePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Color(0xFF141419),
        border: Border(left: BorderSide(color: Colors.white12, width: 1.0)),
      ),
      child: Stack(
        children: [
          ListView(
            children: [
              _buildPanelMainHeader(context, "COMMAND & STATUS"),
              const SizedBox(height: 16),

              _buildArmingWidget(),
              const SizedBox(height: 12),

              _buildModeWidget(),
              const SizedBox(height: 12),

              _buildArtificialHorizon(),
              const SizedBox(height: 12),

              _buildBasicDataWidget(),
              const SizedBox(height: 8),

              _buildEngineTelemetryWidget(),
              const SizedBox(height: 8),

              _buildPanelHeader("TORPEDO SYSTEMS"),
              const SizedBox(height: 12),
              _buildTorpedoStatusWidget(),
              const SizedBox(height: 12),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArmingWidget() {
    return ValueListenableBuilder<int>(
      valueListenable: NotifierService.connectionTrigger,
      builder: (context, _, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: MavlinkData.isArmed
                ? Colors.green.withAlpha(20)
                : Colors.red.withAlpha(20),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: MavlinkData.isArmed ? Colors.green : Colors.red,
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: (MavlinkData.isArmed ? Colors.green : Colors.red)
                    .withAlpha(30),
                blurRadius: 10,
              ),
            ],
          ),
          child: Center(
            child: Text(
              MavlinkData.isArmed ? "READY" : "NOT READY",
              style: TextStyle(
                color: MavlinkData.isArmed ? Colors.green : Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 4.0,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPanelHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.0,
      ),
    );
  }

  Widget _buildModeWidget() {
    return ValueListenableBuilder<int>(
      valueListenable: NotifierService.connectionTrigger,
      builder: (context, _, child) {
        final hb = MavlinkData.lastHeartbeat;
        final int modeNum = hb?.customMode ?? 0;

        String modeName = _getModeName(modeNum);

        return Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  child: Text(
                    "MODE",
                    style: TextStyle(color: Colors.white, fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ),
                Row(
                  spacing: 8,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      modeName,
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PopupMenuButton(
                      color: const Color(0xFF1A1A20),
                      elevation: 4,
                      offset: const Offset(0, 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: BorderSide(color: Colors.white, width: 0.5),
                      ),
                      onSelected: (int selectedModeNum) {
                        debugPrint(
                          "change mode to ${_getModeName(selectedModeNum)}",
                        );

                        MavlinkService.setMode(selectedModeNum);
                      },
                      itemBuilder: (BuildContext context) {
                        final List<int> availableModes = [
                          0,
                          4,
                          5,
                          9,
                          10,
                          11,
                          15,
                        ];

                        return availableModes.map((int mode) {
                          return PopupMenuItem<int>(
                            value: mode,
                            height: 32,
                            child: Text(
                              _getModeName(mode),
                              style: TextStyle(
                                color: mode == modeNum
                                    ? Colors.yellow
                                    : Colors.white,
                                fontSize: 11,
                                fontWeight: mode == modeNum
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontFamily: 'Courier',
                              ),
                            ),
                          );
                        }).toList();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          border: Border.all(color: Colors.orange, width: 0.5),
                          color: Colors.orangeAccent.withAlpha(20),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Text(
                          "CHANGE MODE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getModeName(int mode) {
    switch (mode) {
      case 0:
        return "MANUAL";
      case 4:
        return "HOLD";
      case 5:
        return "LOITER";
      case 9:
        return "CIRCLE";
      case 10:
        return "AUTO";
      case 11:
        return "RTL";
      case 15:
        return "GUIDED";
      default:
        return "$mode";
    }
  }

  Widget _buildArtificialHorizon() {
    return ValueListenableBuilder<int>(
      valueListenable: NotifierService.attitudeTrigger,
      builder: (context, _, child) {
        final attitude = MavlinkData.lastAttitude;

        double roll = attitude?.roll ?? 0.0;
        double pitch = attitude?.pitch ?? 0.0;

        double pitchDeg = pitch * (180.0 / math.pi);

        double pitchOffset = pitchDeg * 2.0;

        return Align(
          alignment: Alignment.center,
          child: Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 2),
              color: Colors.black,
            ),
            child: ClipOval(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 400,
                    height: 400,
                    child: Transform.rotate(
                      angle: roll,
                      child: Transform.translate(
                        offset: Offset(0, pitchOffset),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              children: [
                                Expanded(
                                  child: Container(color: Colors.blue[900]),
                                ),
                                Container(height: 1.5, color: Colors.white),
                                Expanded(
                                  child: Container(color: Colors.brown[800]),
                                ),
                              ],
                            ),

                            // Garis-garis Sudut (Pitch Ladder)
                            ..._buildPitchLadder(),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 2. CROSSHAIR TENGAH (STATIS)
                  const Icon(
                    Icons.add,
                    color: Colors.deepOrangeAccent,
                    size: 32,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildPitchLadder() {
    List<Widget> lines = [];

    for (int i = -40; i <= 40; i += 10) {
      if (i == 0) continue;

      double yPosition = i * 2.0;

      double lineWidth = (i.abs() % 20 == 0) ? 40.0 : 20.0;

      lines.add(
        Transform.translate(
          offset: Offset(0, -yPosition),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                i.abs().toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Container(width: lineWidth, height: 1.0, color: Colors.white70),
              const SizedBox(width: 4),
              Text(
                i.abs().toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return lines;
  }

  Widget _buildBasicDataWidget() {
    return ValueListenableBuilder<int>(
      valueListenable: NotifierService.attitudeTrigger,
      builder: (context, _, child) {
        final attitude = MavlinkData.lastAttitude;
        final pos = MavlinkData.lastGlobalPositionInt;
        final home = MavlinkData.lastHomePosition;

        double headingDeg = 0.0;

        if (pos != null && pos.hdg != 65535) {
          headingDeg = pos.hdg / 100.0;
        } else if (attitude != null) {
          headingDeg = attitude.yaw * (180.0 / math.pi);
          if (headingDeg < 0) headingDeg += 360.0;
        }
        final (utmZone, utmX, utmY) = AppUtils.latLonToUtm(
          (MavlinkData.lastGlobalPositionInt?.lat ?? 0) / 1e7,
          (MavlinkData.lastGlobalPositionInt?.lon ?? 0) / 1e7,
        );

        double rawDistToHome = 0.0;
        if (pos != null && home != null) {
          double currentLat = pos.lat / 1e7;
          double currentLon = pos.lon / 1e7;
          double homeLat = home.latitude / 1e7;
          double homeLon = home.longitude / 1e7;

          rawDistToHome = AppUtils.calculateDistance(
            currentLat,
            currentLon,
            homeLat,
            homeLon,
          );
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A20),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white.withAlpha(30)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                spacing: 4,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildDataItem(
                    title: "HEADING",
                    value: "${headingDeg.toStringAsFixed(1)}°",
                  ),
                  _buildDataItem(
                    title: "BATTERY",
                    value:
                        "${((MavlinkData.lastSysStatus?.voltageBattery ?? 0) * 0.001).toStringAsFixed(1)}V",
                  ),
                ],
              ),
              const SizedBox(height: 3),
              _buildDataDivider(),
              const SizedBox(height: 3),
              Row(
                spacing: 4,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildDataItem(
                    title: "SPEED",
                    value: (AppData.selectedSpeedUnit.value == SpeedUnit.metric)
                        ? "${(MavlinkData.lastVfrHud?.groundspeed ?? 0).toStringAsFixed(1)} m/s"
                        : "${((MavlinkData.lastVfrHud?.groundspeed ?? 0) * 1.94384).toStringAsFixed(1)} kn",
                  ),
                  _buildDataItem(
                    title: "HOME",
                    value: (AppData.selectedSpeedUnit.value == SpeedUnit.metric)
                        ? "${rawDistToHome.toStringAsFixed(0)} m"
                        : "${(rawDistToHome / 1852).toStringAsFixed(2)} NM",
                  ),
                ],
              ),
              const SizedBox(height: 3),
              _buildDataDivider(),
              const SizedBox(height: 3),
              Row(
                spacing: 4,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildDataItem(
                    title: "SATELLITE",
                    value:
                        "${(MavlinkData.lastGpsRawInt?.satellitesVisible) ?? 0}",
                  ),
                  _buildDataItem(
                    title: "NEXT WP DIST",
                    value: ((MavlinkData.lastHeartbeat?.customMode ?? 0) != 10)
                        ? "--"
                        : ((MavlinkData.lastMissionCurrent!.seq <
                                  MavlinkData.missionItems.length)
                              ? "${AppUtils.calculateDistance(MavlinkData.lastGlobalPositionInt!.lat / 1e7, MavlinkData.lastGlobalPositionInt!.lon / 1e7, MavlinkData.missionItems[MavlinkData.lastMissionCurrent!.seq - 1].x, MavlinkData.missionItems[MavlinkData.lastMissionCurrent!.seq - 1].y).toStringAsFixed(0)} m"
                              : "--"),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              const Divider(
                thickness: 0.05,
                height: 0.5,
                indent: 12,
                endIndent: 12,
                color: Colors.white,
              ),
              const SizedBox(height: 5),
              Column(
                spacing: 4,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          (AppData.selectedPosUnit.value == PositionUnit.utm)
                              ? "${utmZone}, ${(utmX).toStringAsFixed(2)}, ${(utmY).toStringAsFixed(2)}"
                              : "${(MavlinkData.lastGlobalPositionInt?.lat ?? 0) / 1e7}, ${(MavlinkData.lastGlobalPositionInt?.lon ?? 0) / 1e7}",
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 14,
                            // fontWeight: FontWeight.w900,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "CURRENT POSITION",
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Column(
                spacing: 4,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ValueListenableBuilder(
                          valueListenable: AppData.objectCoord,
                          builder: (context, objPos, _) {
                            final (
                              oUtmZone,
                              oUtmX,
                              oUtmY,
                            ) = AppUtils.latLonToUtm(
                              (AppData.objectCoord.value.latitude),
                              (AppData.objectCoord.value.longitude),
                            );
                            return Text(
                              (!MavlinkData.isObjectValid)
                                  ? "--"
                                  : ((AppData.selectedPosUnit.value ==
                                            PositionUnit.utm)
                                        ? "${oUtmZone}, ${(oUtmX).toStringAsFixed(2)}, ${(oUtmY).toStringAsFixed(2)}"
                                        : "${(AppData.objectCoord.value.latitude).toStringAsFixed(7)}, ${(AppData.objectCoord.value.longitude).toStringAsFixed(7)}"),
                              style: const TextStyle(
                                color: Colors.deepOrange,
                                fontSize: 14,
                                // fontWeight: FontWeight.w900,
                                fontFamily: 'Courier',
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "OBJECT POSITION ESTIMATE",
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      letterSpacing: 2.0,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    spacing: 4,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ValueListenableBuilder<double>(
                        valueListenable: AppData.headingToTarget,
                        builder: (context, headingVal, _) {
                          return _buildDataItem(
                            title: "HEADING TO OBJECT",
                            value: MavlinkData.isObjectValid
                                ? "${headingVal.toStringAsFixed(1)}°"
                                : "--",
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPanelMainHeader(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),

        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white30, size: 18),
          tooltip: "GCS Menu",
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
          onPressed: () {
            AppData.showSettings.value = true;
          },
        ),
      ],
    );
  }

  Widget _buildDataItem({
    required String title,
    required String value,
    Color valueColor = Colors.orange,
    double valueSize = 18,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: valueColor,
              fontSize: valueSize,
              fontFamily: 'Courier',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 9,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataDivider() {
    return const Padding(
      padding: EdgeInsetsGeometry.symmetric(vertical: 4),
      child: Divider(
        thickness: 0.2,
        height: 1,
        indent: 12,
        endIndent: 12,
        color: Colors.white12,
      ),
    );
  }

  Widget _buildTorpedoStatusWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSingleTorpedoIndicator(
          unitNumber: 1,
          notifier: AppData.torpedo1Ready,
        ),
        const SizedBox(width: 4),
        _buildSingleTorpedoIndicator(
          unitNumber: 2,
          notifier: AppData.torpedo2Ready,
        ),
        const SizedBox(width: 4),
        _buildSingleTorpedoIndicator(
          unitNumber: 3,
          notifier: AppData.torpedo3Ready,
        ),
        const SizedBox(width: 4),
        _buildSingleTorpedoIndicator(
          unitNumber: 4,
          notifier: AppData.torpedo4Ready,
        ),
      ],
    );
  }

  Widget _buildSingleTorpedoIndicator({
    required int unitNumber,
    required ValueNotifier<bool> notifier,
  }) {
    return Expanded(
      child: ValueListenableBuilder<bool>(
        valueListenable: notifier,
        builder: (context, isReady, child) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
            decoration: BoxDecoration(
              color: isReady
                  ? Colors.green.withAlpha(20)
                  : Colors.red.withAlpha(20),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isReady ? Colors.green : Colors.red,
                width: 1.0,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "T-$unitNumber",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isReady ? "MOUNTED" : "RELEASED",
                  style: TextStyle(
                    color: isReady ? Colors.green : Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEngineTelemetryWidget() {
    return ValueListenableBuilder<int>(
      valueListenable: NotifierService
          .attitudeTrigger, // Sesuaikan dengan trigger pembaruan data telemetri mesin
      builder: (context, _, child) {
        // Ambil data RPM berdasarkan index motor (0 untuk Motor 1, 1 untuk Motor 2)
        final rpm1Data = MavlinkData.motor1Rpm;
        final rpm2Data = MavlinkData.motor2Rpm;
        final efiData = MavlinkData.efiStatus;

        String rpm1Text = rpm1Data != null ? rpm1Data.toStringAsFixed(0) : "--";
        String rpm2Text = rpm2Data != null ? rpm2Data.toStringAsFixed(0) : "--";

        // Contoh mengambil parameter dari EfiStatus (misal: tegangan injeksi / ignition_voltage)
        String efiVoltText = efiData != null
            ? "${efiData.fuelConsumed.toStringAsFixed(1)}V"
            : "--";

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A20),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white.withAlpha(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "DUAL MOTORS & EFI STATUS",
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 9,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDataItem(
                    title: "RPM 1",
                    value: rpm1Text,
                    valueColor: Colors.cyanAccent,
                    valueSize: 14,
                  ),
                  _buildDataItem(
                    title: "RPM 2",
                    value: rpm2Text,
                    valueColor: Colors.cyanAccent,
                    valueSize: 14,
                  ),
                  _buildDataItem(
                    title: "EFI VOLT",
                    value: efiVoltText,
                    valueColor: Colors.amberAccent,
                    valueSize: 14,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
