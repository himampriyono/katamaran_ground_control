import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:mbtiles/mbtiles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart' hide Theme;
import 'package:vector_map_tiles_mbtiles/vector_map_tiles_mbtiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart';

import 'mbtiles_service.dart';

final mbtiles = MbTilesService();

class MapService {
  static final MapService instance = MapService._();

  MapService._();

  static const String _styleAsset = 'assets/map_style/style.json';
  static const String _defaultVectorMbtiles = 'C:/Map/indonesia.mbtiles';
  static const String _defaultSatelliteMbtiles =
      'C:/Map/asia_indonesia.mbtiles';

  String _vectorMbtilesPath = '';
  String _satelliteMbtilesPath = '';

  bool _initialized = false;

  LatLng _mapCenter = const LatLng(-6.2, 106.8);
  double _mapZoom = 12.0;

  MbTiles? _mbtiles;
  MbTilesVectorTileProvider? _tileProvider;
  Theme? _theme;
  TileProviders? _tileProviders;

  bool get isInitialized => _initialized;

  String get vectorMbtilesPath => _vectorMbtilesPath;
  String get satelliteMbtilesPath => _satelliteMbtilesPath;

  bool get hasVectorMbtiles => File(_vectorMbtilesPath).existsSync();
  bool get hasSatelliteMbtiles => File(_satelliteMbtilesPath).existsSync();

  LatLng get mapCenter => _mapCenter;
  double get mapZoom => _mapZoom;

  Theme get theme {
    if (!_initialized || _theme == null) {
      throw StateError('MapService has not been initialized.');
    }

    return _theme!;
  }

  TileProviders get tileProviders {
    if (!_initialized || _tileProviders == null) {
      throw StateError('MapService has not been initialized.');
    }

    return _tileProviders!;
  }

  Future<void> loadMapSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _vectorMbtilesPath =
        prefs.getString('vector_mbtiles_path') ?? _defaultVectorMbtiles;

    _satelliteMbtilesPath =
        prefs.getString('satellite_mbtiles_path') ?? _defaultSatelliteMbtiles;
  }

  Future<void> setVectorMbtilesPath(String path) async {
    _vectorMbtilesPath = path;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vector_mbtiles_path', path);
  }

  Future<void> setSatelliteMbtilesPath(String path) async {
    _satelliteMbtilesPath = path;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('satellite_mbtiles_path', path);
  }

  Future<void> initialize() async {
    if (_initialized) return;

    await loadMapSettings();

    if (!hasVectorMbtiles) {
      throw Exception('Vector MBTiles not found.');
    }

    if (!hasSatelliteMbtiles) {
      throw Exception('Satellite MBTiles not found.');
    }

    _mbtiles = MbTiles(mbtilesPath: File(vectorMbtilesPath).absolute.path);

    _tileProvider = MbTilesVectorTileProvider(mbtiles: _mbtiles!);

    _tileProviders = TileProviders({'openmaptiles': _tileProvider!});

    final styleJson = await rootBundle.loadString(_styleAsset);
    final styleMap = jsonDecode(styleJson) as Map<String, dynamic>;

    _theme = ThemeReader().read(styleMap);

    await mbtiles.open(satelliteMbtilesPath);

    _initialized = true;
  }

  Future<void> reload() async {
    await dispose();
    await initialize();
  }

  Future<void> dispose() async {
    _initialized = false;

    _mbtiles = null;
    _tileProvider = null;
    _tileProviders = null;
    _theme = null;
  }

  void updateCamera({required LatLng center, required double zoom}) {
    _mapCenter = center;
    _mapZoom = zoom;
  }
}
