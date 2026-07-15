import 'package:flutter/material.dart';
import '../../../data/mavlink_data.dart';
import '../../snackbar.dart';
import '../widgets/action_button.dart';
import '../../../data/app_data.dart';
import '../widgets/setting_page_header.dart';
import '../widgets/settings_group.dart';
import '../widgets/settings_text_field.dart';
import '../widgets/settings_tile.dart';
import '../widgets/segment_button.dart';
import '../../../services/notifier_service.dart';
import '../../../services/settings_service.dart';
import '../../../services/mavlink_service.dart';

final mavlinkService = MavlinkService();

class GeneralPage extends StatefulWidget {
  const GeneralPage({super.key});

  @override
  State<GeneralPage> createState() => _GeneralPageState();
}

class _GeneralPageState extends State<GeneralPage> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _ipController.text = SettingsService.vesselIp;
    _portController.text = SettingsService.udpPort.toString();
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SettingPageHeader(
            title: "General",
            subtitle: "Configure general aplication references.",
          ),
          const SizedBox(height: 4),
          SettingsGroup(
            title: "Network",
            child: Column(
              children: [
                // SettingsTile(
                //   title: "Connection",
                //   trailing: ValueListenableBuilder(
                //     valueListenable: NotifierService.connectionTrigger,
                //     builder: (context, connected, _) {
                //       final isConnected = MavlinkData.isMavlinkConnected;
                //       return ActionButton(
                //         text: isConnected ? "Disconnect" : "Connect",
                //         color: isConnected ? Colors.red : Colors.green,
                //         onTap: () {
                //           isConnected
                //               ? mavlinkService.disconnect()
                //               : mavlinkService.connect(
                //                   host: SettingsService.vesselIp,
                //                   port: SettingsService.udpPort,
                //                 );
                //         },
                //       );
                //     },
                //   ),
                // ),
                SettingsTile(
                  title: "IP",
                  trailing: SettingsTextField(controller: _ipController),
                ),
                SettingsTile(
                  title: "Port",
                  trailing: SettingsTextField(controller: _portController),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ActionButton(
                        text: "Save",
                        // icon: Icons.save,
                        color: Colors.orange,
                        onTap: () async {
                          final ip = _ipController.text.trim();
                          final port =
                              int.tryParse(_portController.text) ?? 14550;

                          await SettingsService.setVesselIp(ip);
                          await SettingsService.setUdpPort(port);

                          _ipController.text = ip;
                          _portController.text = port.toString();

                          Snackbar.show("Network settings saved.");
                          mavlinkService.disconnect();
                          mavlinkService.connect(
                            host: SettingsService.vesselIp,
                            port: SettingsService.udpPort,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SettingsGroup(
            title: "Display",
            child: Column(
              children: [
                SettingsTile(
                  title: "Speed Unit",
                  trailing: SizedBox(
                    width: 180,
                    child: ValueListenableBuilder(
                      valueListenable: AppData.selectedSpeedUnit,
                      builder: (context, value, child) {
                        return Row(
                          children: [
                            Expanded(
                              child: SegmentButton(
                                title: "Metric",
                                isSelected: value == SpeedUnit.metric,
                                onTap: () {
                                  AppData.selectedSpeedUnit.value =
                                      SpeedUnit.metric;
                                  SettingsService.setSpeedUnit(
                                    SpeedUnit.metric,
                                  );
                                  NotifierService.triggerAttitudeUpdate();
                                },
                              ),
                            ),
                            Expanded(
                              child: SegmentButton(
                                title: "Naval",
                                isSelected: value == SpeedUnit.naval,
                                onTap: () {
                                  AppData.selectedSpeedUnit.value =
                                      SpeedUnit.naval;
                                  SettingsService.setSpeedUnit(SpeedUnit.naval);
                                  NotifierService.triggerAttitudeUpdate();
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                SettingsTile(
                  title: "Position Unit",
                  trailing: SizedBox(
                    width: 180,
                    child: ValueListenableBuilder(
                      valueListenable: AppData.selectedPosUnit,
                      builder: (context, value, child) {
                        return Row(
                          children: [
                            Expanded(
                              child: SegmentButton(
                                title: "LatLon",
                                isSelected: value == PositionUnit.latlon,
                                onTap: () {
                                  AppData.selectedPosUnit.value =
                                      PositionUnit.latlon;
                                  SettingsService.setPositionUnit(
                                    PositionUnit.latlon,
                                  );
                                  NotifierService.triggerAttitudeUpdate();
                                },
                              ),
                            ),
                            Expanded(
                              child: SegmentButton(
                                title: "UTM",
                                isSelected: value == PositionUnit.utm,
                                onTap: () {
                                  AppData.selectedPosUnit.value =
                                      PositionUnit.utm;
                                  SettingsService.setPositionUnit(
                                    PositionUnit.utm,
                                  );
                                  NotifierService.triggerAttitudeUpdate();
                                },
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
        ],
      ),
    );
  }
}
