import 'dart:math' as math;

import 'package:dart_mavlink/types.dart';

class AppUtils {
  static (String zone, double easting, double northing) latLonToUtm(
    double lat,
    double lon,
  ) {
    double latRad = lat * math.pi / 180;
    double lonRad = lon * math.pi / 180;

    int zoneNum = ((lon + 180) / 6).floor() + 1;
    double lonOrigin = ((zoneNum - 1) * 6 - 180 + 3) * math.pi / 180;
    String letter =
        'CDEFGHJKLMNPQRSTUVWXX'[((lat + 80) / 8).clamp(0, 20).floor()];

    double a = 6378137.0, f = 1 / 298.257223563, k0 = 0.9996;
    double e2 = 2 * f - f * f, ep2 = e2 / (1 - e2);

    double n = a / math.sqrt(1 - e2 * math.sin(latRad) * math.sin(latRad));
    double t = math.tan(latRad) * math.tan(latRad);
    double c = ep2 * math.cos(latRad) * math.cos(latRad);
    double al = math.cos(latRad) * (lonRad - lonOrigin);

    double m =
        a *
        ((1 - e2 / 4 - 3 * e2 * e2 / 64 - 5 * e2 * e2 / 256) * latRad -
            (3 * e2 / 8 + 3 * e2 * e2 / 32 + 45 * e2 * e2 * e2 / 1024) *
                math.sin(2 * latRad) +
            (15 * e2 * e2 / 256 + 45 * e2 * e2 * e2 / 1024) *
                math.sin(4 * latRad) -
            (35 * e2 * e2 / 3072) * math.sin(6 * latRad));

    double easting =
        k0 *
            n *
            (al +
                (1 - t + c) * math.pow(al, 3) / 6 +
                (5 - 18 * t + t * t + 72 * c - 58 * ep2) *
                    math.pow(al, 5) /
                    120) +
        500000;
    double northing =
        k0 *
        (m +
            n *
                math.tan(latRad) *
                (al * al / 2 +
                    (5 - t + 9 * c + 4 * c * c) * math.pow(al, 4) / 24 +
                    (61 - 58 * t + t * t + 600 * c - 330 * ep2) *
                        math.pow(al, 6) /
                        720));

    if (lat < 0) northing += 10000000;

    return ("$zoneNum$letter", easting, northing);
  }

  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // Radius bumi dalam satuan meter

    // Konversi derajat ke radian
    double dLat = (lat2 - lat1) * math.pi / 180.0;
    double dLon = (lon2 - lon1) * math.pi / 180.0;

    double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180.0) *
            math.cos(lat2 * math.pi / 180.0) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c; // Hasil dalam satuan meter
  }

  static String charListToString(List<char> chars) {
    final buffer = StringBuffer();

    for (final c in chars) {
      if (c == 0) {
        break;
      }

      buffer.writeCharCode(c);
    }

    return buffer.toString();
  }

  static List<char> stringToCharList(String text) {
    final bytes = text.codeUnits;
    final result = List<char>.filled(16, 0);

    for (int i = 0; i < bytes.length && i < 16; i++) {
      result[i] = bytes[i];
    }

    return result;
  }

  static double calculateBearing(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    double dLon = (lon2 - lon1) * math.pi / 180.0;
    double lat1Rad = lat1 * math.pi / 180.0;
    double lat2Rad = lat2 * math.pi / 180.0;

    double y = math.sin(dLon) * math.cos(lat2Rad);
    double x =
        math.cos(lat1Rad) * math.sin(lat2Rad) -
        math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(dLon);

    double rad = math.atan2(y, x);
    double deg = rad * (180.0 / math.pi);

    return (deg + 360) % 360;
  }
}
