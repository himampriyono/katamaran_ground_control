import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;
import '../services/mavlink_service.dart';
import '../data/mavlink_data.dart';
import '../services/notifier_service.dart';

class MapArea extends StatefulWidget {
  const MapArea({super.key});

  @override
  State<MapArea> createState() => _MapAreaState();
}

class _MapAreaState extends State<MapArea> {
  final MapController _mapController = MapController();

  bool _isAutoCenter = true;
  bool _isMapReady = false;
  double _currentZoom = 16;

  @override
  void initState() {
    super.initState();
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
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: defaultLocation,
                  initialZoom: 16.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
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
                      final zoomVal = (cameraData.zoom as num?)?.toDouble();
                      if (zoomVal != null) {
                        _currentZoom = zoomVal;
                      }
                    } catch (e) {}
                    if (hasGesture && _isAutoCenter) {
                      setState(() {
                        _isAutoCenter = false;
                      });
                    }
                  },
                ),
                children: [
                  TileLayer(
                    // urlTemplate:
                    //     'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    urlTemplate:
                        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                    userAgentPackageName: 'com.ship_gcs.app',
                  ),
                  _buildHomeMarkerLayer(),
                  _buildShipMarkerLayer(),
                ],
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: _isAutoCenter
                      ? const Color(0xFF00FFCC)
                      : const Color(0xFF2A2A30),
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
                    color: _isAutoCenter ? Colors.black : Colors.white54,
                  ),
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
}
