import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'mbtiles_service.dart';

class MbTilesTileProvider extends TileProvider {
  MbTilesTileProvider({required this.mbtiles});

  final MbTilesService mbtiles;

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return MbTileImageProvider(mbtiles: mbtiles, coordinates: coordinates);
  }
}

class MbTileImageProvider extends ImageProvider<MbTileImageProvider> {
  const MbTileImageProvider({required this.mbtiles, required this.coordinates});

  final MbTilesService mbtiles;
  final TileCoordinates coordinates;

  @override
  Future<MbTileImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture(this);
  }

  @override
  ImageStreamCompleter loadImage(
    MbTileImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(decode),
      scale: 1.0,
    );
  }

  Future<Codec> _loadAsync(ImageDecoderCallback decode) async {
    final Uint8List? bytes = mbtiles.getTile(
      z: coordinates.z.toInt(),
      x: coordinates.x.toInt(),
      y: coordinates.y.toInt(),
    );

    // debugPrint(
    //   "Request: z=${coordinates.z}, x=${coordinates.x}, y=${coordinates.y}",
    // );

    if (bytes == null) {
      // debugPrint(
      //   "NOT FOUND: "
      //   "${coordinates.z}/${coordinates.x}/${coordinates.y}",
      // );

      throw Exception(
        "Tile not found: "
        "${coordinates.z}/${coordinates.x}/${coordinates.y}",
      );
    }

    final buffer = await ImmutableBuffer.fromUint8List(bytes);

    return decode(buffer);
  }

  @override
  bool operator ==(Object other) =>
      other is MbTileImageProvider && other.coordinates == coordinates;

  @override
  int get hashCode => coordinates.hashCode;
}
