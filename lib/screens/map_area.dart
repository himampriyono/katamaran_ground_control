import 'package:dart_mavlink/dialects/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'dart:math' as math;
import '../data/app_data.dart';
import '../services/mavlink_service.dart';
import '../data/mavlink_data.dart';
import '../services/mbtiles_tile_provider.dart';
import '../services/notifier_service.dart';
import '../services/map_service.dart';
import '../services/settings_service.dart';
import '../utils/app_utils.dart';

class MapArea extends StatefulWidget {
  const MapArea({super.key});

  @override
  State<MapArea> createState() => _MapAreaState();
}

class _MapAreaState extends State<MapArea> {
  final MapController _mapController = MapController();
  final _mapService = MapService.instance;

  bool _isAutoCenter = true;
  bool _isMapReady = false;
  double _currentZoom = 16;
  double _currentRotation = 0;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _mapService.initialize();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    NotifierService.positionTrigger.removeListener(_updateCameraPosition);
    _mapController.dispose();
    super.dispose();
  }

  /// Fungsi Kamera: Menggerakkan kamera peta mengikuti pergerakan posisi kapal
  void _updateCameraPosition() {
    if (!_isAutoCenter || !_isMapReady) return;

    final pos = MavlinkData.lastGlobalPositionInt;
    if (pos != null) {
      final lat = pos.lat / 1e7;
      final lon = pos.lon / 1e7;
      final currentPosition = LatLng(lat, lon);

      try {
        _mapController.move(currentPosition, _currentZoom);
      } catch (e) {
        debugPrint("Abaikan: Peta sedang dalam proses layout. $e");
      }
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    if (AppData.gotoAction == GotoMenuAction.none) return;

    setState(() {
      MavlinkData.gotoTarget = point;
      AppData.gotoAction = GotoMenuAction.goHere;
    });

    MavlinkService.sendGoto(
      latitude: MavlinkData.gotoTarget!.latitude,
      longitude: MavlinkData.gotoTarget!.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultLocation = const LatLng(-7.7703, 110.3778);

    return Expanded(
      flex: 3,
      child: Container(
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFF18181C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF00FFCC).withAlpha(50),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(100),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              _mapService.isInitialized
                  ? FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: defaultLocation,
                        initialZoom: 12.0,
                        maxZoom: 20,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all,
                        ),
                        onTap: _onMapTap,
                        onSecondaryTap: _onRightClick,
                        onLongPress: _onRightClick,
                        onMapReady: () {
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (mounted) {
                              _isMapReady = true;
                              NotifierService.positionTrigger.addListener(
                                _updateCameraPosition,
                              );
                              _updateCameraPosition();
                            }
                          });
                        },
                        onPositionChanged: (cameraData, hasGesture) {
                          try {
                            final zoomVal = (cameraData.zoom as num?)
                                ?.toDouble();
                            if (zoomVal != null) {
                              _currentZoom = zoomVal;
                            }

                            final rotationVal = (cameraData.rotation as num?)
                                ?.toDouble();
                            if (rotationVal != null) {
                              setState(() {
                                _currentRotation = rotationVal;
                              });
                            }
                          } catch (e) {}
                          if (hasGesture && _isAutoCenter) {
                            setState(() {
                              _isAutoCenter = false;
                            });
                          }
                          MapService.instance.updateCamera(
                            center: cameraData.center,
                            zoom: cameraData.zoom,
                          );
                        },
                      ),
                      children: [
                        ValueListenableBuilder(
                          valueListenable: AppData.selectedMapType,
                          builder: (context, mapType, child) {
                            switch (mapType) {
                              case MapType.vectorOffline:
                                return VectorTileLayer(
                                  tileProviders: _mapService.tileProviders,
                                  theme: _mapService.theme,
                                  maximumZoom: 22,
                                  maximumTileSubstitutionDifference: 3,
                                  // memoryTileCacheMaxSize: 0,
                                  // memoryTileDataCacheMaxSize: 0,
                                );
                              case MapType.satelliteOffline:
                                return Stack(
                                  children: [
                                    TileLayer(
                                      tileProvider: MbTilesTileProvider(
                                        mbtiles: mbtiles,
                                      ),
                                      minZoom: 2,
                                      maxZoom: 22,
                                      minNativeZoom: 2,
                                      maxNativeZoom: 13,
                                    ),
                                  ],
                                );
                              case MapType.googleMap:
                                return TileLayer(
                                  urlTemplate:
                                      "https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}",
                                  subdomains: ['mt0', 'mt1', 'mt2', 'mt3'],
                                  additionalOptions: {
                                    'API_KEY':
                                        'AIzaSyBQR-OKksBdgps4rrp15DEp-RjTYMYsXOs',
                                  },
                                  userAgentPackageName: 'com.mygcs.app',
                                  maxNativeZoom: 20,
                                  maxZoom: 22,
                                );
                            }
                          },
                        ),
                        ValueListenableBuilder(
                          valueListenable: AppData.showMissionOnMainMap,
                          builder: (context, showMission, _) {
                            if (!showMission) {
                              return SizedBox();
                            }
                            return Stack(
                              children: [
                                _buildMissionPolylineLayer(),
                                _buildMissionMarker(),
                              ],
                            );
                          },
                        ),
                        _buildObjectMarkerLayer(),
                        _buildGotoLineLayer(),
                        _buildGotoDistanceLayer(),
                        _buildGotoMarkerLayer(),
                        _buildHomeMarkerLayer(),
                        _buildShipMarkerLayer(),
                      ],
                    )
                  : const Center(child: CircularProgressIndicator()),
              Positioned(
                bottom: 16,
                right: 16,
                child: Row(
                  children: [
                    _buildGotoButton(),
                    SizedBox(width: 8),
                    FloatingActionButton(
                      heroTag: "reset_rotation",
                      mini: true,
                      backgroundColor: const Color(0xFF2A2A30),
                      onPressed: () {
                        _mapController.rotate(0);
                        setState(() {
                          _currentRotation = 0;
                        });
                      },
                      child: Transform.rotate(
                        angle: (_currentRotation - 45) * pi / 180,
                        child: Icon(
                          Icons.explore,
                          color: _currentRotation.abs() < 1
                              ? Colors.blue
                              : Colors.white54,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      mini: true,
                      backgroundColor: const Color(0xFF2A2A30),
                      onPressed: () {
                        setState(() {
                          _isAutoCenter = !_isAutoCenter;
                        });
                        if (_isAutoCenter) {
                          _updateCameraPosition();
                        }
                      },
                      child: Icon(
                        Icons.my_location,
                        color: _isAutoCenter ? Colors.blue : Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShipMarkerLayer() {
    return ValueListenableBuilder<int>(
      valueListenable: NotifierService.positionTrigger,
      builder: (context, _, child) {
        final pos = MavlinkData.lastGlobalPositionInt;

        if (pos == null) return const SizedBox.shrink();

        final currentPosition = LatLng(pos.lat / 1e7, pos.lon / 1e7);
        double headingRad = 0.0;

        if (pos.hdg != 65535) {
          headingRad = (pos.hdg / 100) * (math.pi / 180);
        } else if (MavlinkData.lastAttitude != null) {
          headingRad = MavlinkData.lastAttitude!.yaw;
        }

        return MarkerLayer(
          markers: [
            Marker(
              point: currentPosition,
              width: 48,
              height: 48,
              alignment: Alignment.center,
              child: Transform.rotate(
                angle: headingRad,
                child: Image.asset('assets/arrow.png', width: 48, height: 48),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHomeMarkerLayer() {
    return ValueListenableBuilder<int>(
      valueListenable: NotifierService.homeTrigger,
      builder: (context, _, child) {
        final home = MavlinkData.lastHomePosition;

        if (home == null) return const SizedBox.shrink();

        final homePosition = LatLng(home.latitude / 1e7, home.longitude / 1e7);

        return MarkerLayer(
          markers: [
            Marker(
              point: homePosition,
              width: 32,
              height: 32,
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.home,
                    color: Colors.red,
                    size: 32,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMissionMarker() {
    return ValueListenableBuilder<int>(
      valueListenable: NotifierService.missionTrigger,
      builder: (context, _, child) {
        final missions = MavlinkData.missionItems;

        return MarkerLayer(
          markers: missions
              .asMap()
              .entries
              .where((entry) {
                final mission = entry.value;

                return true;
              })
              .map((entry) {
                final index = entry.key;
                final mission = entry.value;

                return Marker(
                  point: LatLng(mission.x, mission.y),
                  width: 32,
                  height: 32,
                  child: _buildMissionMarkerIcon(mission.seq),
                );
              })
              .toList(),
        );
      },
    );
  }

  Widget _buildMissionMarkerIcon(int seq) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.orange,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Text(
        "$seq",
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMissionPolylineLayer() {
    return ValueListenableBuilder(
      valueListenable: NotifierService.missionTrigger,
      builder: (context, _, child) {
        final points = MavlinkData.missionItems
            .where(
              (mission) =>
                  mission.frame == mavFrameGlobal ||
                  mission.frame == mavFrameGlobalRelativeAlt ||
                  mission.frame == mavFrameGlobalTerrainAlt,
              //|| mission.seq > 0,
            )
            .map((mission) => LatLng(mission.x, mission.y))
            .toList();

        if (points.length < 2) {
          return const SizedBox.shrink();
        }

        return PolylineLayer(
          polylines: [
            Polyline(
              points: points,
              strokeWidth: 3,
              color: Colors.orangeAccent,
            ),
          ],
        );
      },
    );
  }

  Widget _buildGotoButton() {
    return InkWell(
      onTap: () async {
        if (AppData.gotoAction == GotoMenuAction.none) {
          final confirmed = await _showGotoDialog();

          if (confirmed) {
            setState(() {
              AppData.gotoAction = GotoMenuAction.goHere;
              MavlinkData.gotoTarget = null;
            });
          }
        } else {
          final hold = 4;

          if (MavlinkData.lastHeartbeat!.customMode != hold) {
            MavlinkService.setMode(hold);
          }
          setState(() {
            AppData.gotoAction = GotoMenuAction.none;
            MavlinkData.gotoTarget = null;
            // MavlinkData.circleTarget = null;
          });
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 100,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A30),
          border: Border.all(
            color: (AppData.gotoAction != GotoMenuAction.none)
                ? Colors.purpleAccent
                : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          "Goto Mode",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: (AppData.gotoAction != GotoMenuAction.none)
                ? Colors.purpleAccent
                : Colors.white54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildGotoMarkerLayer() {
    if (MavlinkData.gotoTarget == null) {
      return const SizedBox.shrink();
    }

    return Transform.translate(
      offset: const Offset(0, -14),
      child: MarkerLayer(
        markers: [
          Marker(
            point: MavlinkData.gotoTarget!,
            width: 32,
            height: 32,
            child: const Icon(Icons.location_on, color: Colors.red, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectMarkerLayer() {
    return ValueListenableBuilder(
      valueListenable: AppData.objectCoord,
      builder: (context, objectPos, _) {
        if (!MavlinkData.isObjectValid) {
          return const SizedBox.shrink();
        }

        return Transform.translate(
          offset: const Offset(0, -16),
          child: MarkerLayer(
            markers: [
              Marker(
                point: objectPos,
                width: 32,
                height: 32,
                child: const Icon(
                  Icons.my_location,
                  color: Colors.orange,
                  size: 24,
                  shadows: [
                    Shadow(color: Colors.black, blurRadius: 4)
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGotoLineLayer() {
    return ValueListenableBuilder<int>(
      valueListenable: NotifierService.positionTrigger,
      builder: (context, _, child) {
        final pos = MavlinkData.lastGlobalPositionInt;

        if (pos == null || MavlinkData.gotoTarget == null) {
          return const SizedBox.shrink();
        }

        return PolylineLayer(
          polylines: [
            Polyline(
              points: [
                LatLng(pos.lat / 1e7, pos.lon / 1e7),
                MavlinkData.gotoTarget!,
              ],
              strokeWidth: 2,
              color: Colors.purpleAccent,
            ),
          ],
        );
      },
    );
  }

  Widget _buildGotoDistanceLayer() {
    return ValueListenableBuilder<int>(
      valueListenable: NotifierService.positionTrigger,
      builder: (context, _, child) {
        final pos = MavlinkData.lastGlobalPositionInt;

        if (pos == null || MavlinkData.gotoTarget == null) {
          return const SizedBox.shrink();
        }

        final ship = LatLng(pos.lat / 1e7, pos.lon / 1e7);

        final middle = LatLng(
          (ship.latitude + MavlinkData.gotoTarget!.latitude) / 2,
          (ship.longitude + MavlinkData.gotoTarget!.longitude) / 2,
        );

        const distance = Distance();
        final distanceMeters = distance(ship, MavlinkData.gotoTarget!);

        if (distanceMeters < 7) {
          return const SizedBox();
        }

        return MarkerLayer(
          markers: [
            Marker(
              point: middle,
              width: 60,
              height: 20,
              alignment: Alignment.center,
              child: Transform.translate(
                offset: const Offset(0, -12),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black87.withAlpha(150),
                    borderRadius: BorderRadius.circular(6),
                    // border: Border.all(color: Colors.cyan, width: 1),
                  ),
                  child: Text(
                    _formatDistance(distanceMeters),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDistance(double meter) {
    if (meter < 1000) {
      return "${meter.toStringAsFixed(0)} m";
    }

    return "${(meter / 1000).toStringAsFixed(2)} km";
  }

  Future<bool> _showGotoDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Row(
            children: [
              Icon(Icons.navigation, color: Color(0xFF00FFCC)),
              SizedBox(width: 8),
              Text("Go-To Confirmation"),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("The vehicle will navigate to the selected target."),
              SizedBox(height: 12),
              Text("• The mode will be changed to GUIDED if necessary."),
              Text("• The current mission will be interrupted."),
              Text("• Turn off the Goto Mode to stop the Go-To operation."),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.navigation),
              label: const Text("Start"),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  Future<GotoMenuAction?> showGotoMenu({
    required BuildContext context,
    required Offset globalPosition,
  }) async {
    return await showMenu<GotoMenuAction>(
      context: context,
      position: RelativeRect.fromLTRB(
        globalPosition.dx,
        globalPosition.dy,
        globalPosition.dx,
        globalPosition.dy,
      ),
      items: const [
        PopupMenuItem(
          value: GotoMenuAction.goHere,
          child: Row(
            children: [
              Icon(Icons.navigation, size: 18),
              SizedBox(width: 8),
              Text("Go Here"),
            ],
          ),
        ),
        PopupMenuItem(
          value: GotoMenuAction.circleHere,
          child: Row(
            children: [
              Icon(Icons.rotate_right, size: 18),
              SizedBox(width: 8),
              Text("Circle Here"),
            ],
          ),
        ),
      ],
    );
  }

  void _onRightClick(TapPosition tapPosition, LatLng point) async {
    if ((AppData.gotoAction == GotoMenuAction.none)) return;

    final action = await showGotoMenu(
      context: context,
      globalPosition: tapPosition.global,
    );

    if (action == null) {
      return;
    } else if (action == GotoMenuAction.goHere) {
      setState(() {
        MavlinkData.gotoTarget = point;
        AppData.gotoAction = GotoMenuAction.goHere;
      });

      MavlinkService.sendGoto(
        latitude: MavlinkData.gotoTarget!.latitude,
        longitude: MavlinkData.gotoTarget!.longitude,
      );
    } else if (action == GotoMenuAction.circleHere) {
      setState(() {
        MavlinkData.gotoTarget = point;
        AppData.gotoAction = GotoMenuAction.circleHere;
      });

      MavlinkService.sendGoto(
        latitude: MavlinkData.gotoTarget!.latitude,
        longitude: MavlinkData.gotoTarget!.longitude,
      );
    }
  }
}
