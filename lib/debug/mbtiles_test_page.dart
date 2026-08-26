import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/mbtiles_service.dart';
import 'dart:math';

class MbTilesTestPage extends StatefulWidget {
  const MbTilesTestPage({super.key});

  @override
  State<MbTilesTestPage> createState() => _MbTilesTestPageState();
}

class _MbTilesTestPageState extends State<MbTilesTestPage> {
  final MbTilesService _mbtiles = MbTilesService();

  Uint8List? _imageBytes;
  String _status = "Press the button to load a tile.";

  Point<int> latLonToTile(double lat, double lon, int zoom) {
    final n = pow(2.0, zoom);

    final x = ((lon + 180.0) / 360.0 * n).floor();

    final latRad = lat * pi / 180.0;

    final y = ((1.0 - log(tan(latRad) + 1 / cos(latRad)) / pi) / 2.0 * n)
        .floor();

    return Point(x, y);
  }

  Future<void> _loadTile() async {
    try {
      await _mbtiles.open(r"C:\Map\asia_indonesia.mbtiles");

      final bytes = _mbtiles.getTile(
        z: 13,
        x: 6206,
        y: 4361, // XYZ coordinate
      );

      final tile = latLonToTile(-2.5436285, 116.893255, 13);

      debugPrint(tile.toString());

      setState(() {
        _imageBytes = bytes;

        if (bytes == null) {
          _status = "Tile not found.";
        } else {
          _status = "Tile loaded successfully (${bytes.length} bytes).";
        }
      });
    } catch (e) {
      setState(() {
        _status = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _mbtiles.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MBTiles Test")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _loadTile,
              child: const Text("Load Tile"),
            ),

            const SizedBox(height: 20),

            Text(_status),

            const SizedBox(height: 20),

            if (_imageBytes != null)
              Container(
                width: 256,
                height: 256,
                decoration: BoxDecoration(border: Border.all()),
                child: Image.memory(_imageBytes!, fit: BoxFit.contain),
              ),
          ],
        ),
      ),
    );
  }
}
