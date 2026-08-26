import 'dart:typed_data';
import 'package:sqlite3/sqlite3.dart';

class MbTilesService {
  Database? _db;

  bool get isOpen => _db != null;

  Future<void> open(String path) async {
    close();
    _db = sqlite3.open(path);
  }

  void close() {
    _db?.dispose();
    _db = null;
  }

  Uint8List? getTile({required int x, required int y, required int z}) {
    if (_db == null) return null;

    final tmsY = (1 << z) - 1 - y;

    final ResultSet result = _db!.select(
      '''
      SELECT tile_data
      FROM tiles
      WHERE zoom_level = ?
        AND tile_column = ?
        AND tile_row = ?
      LIMIT 1
      ''',
      [z, x, tmsY],
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first['tile_data'] as Uint8List;
  }
}
