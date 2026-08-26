import 'dart:math' as math;
import 'package:dart_mavlink/dialects/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

import '../../data/app_data.dart';
import '../../data/mavlink_data.dart';
import '../../services/map_service.dart';
import '../../services/mbtiles_tile_provider.dart';
import '../../services/notifier_service.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key, this.onMapTap, this.onMarkerDrag});

  final void Function(LatLng point)? onMapTap;
  final void Function(int index, LatLng point)? onMarkerDrag;

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final MapController _mapController = MapController();
  final _mapService = MapService.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: MapService.instance.mapCenter,
        initialZoom: MapService.instance.mapZoom,
        onTap: (tapPosition, point) {
          widget.onMapTap?.call(point);
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
                );
              case MapType.satelliteOffline:
                return Stack(
                  children: [
                    TileLayer(
                      tileProvider: MbTilesTileProvider(mbtiles: mbtiles),
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
                    'API_KEY': 'AIzaSyBQR-OKksBdgps4rrp15DEp-RjTYMYsXOs',
                  },
                  userAgentPackageName: 'com.mygcs.app',
                  maxNativeZoom: 20,
                  maxZoom: 22,
                );
            }
          },
        ),
        _buildMissionPolylineLayer(),
        _buildMissionMarker(),
        _buildHomeMarkerLayer(),
        _buildShipMarkerLayer(),
      ],
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
                  mission.frame == mavFrameGlobalTerrainAlt
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
}
