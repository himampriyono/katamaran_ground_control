import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../data/app_data.dart';
import '../data/mavlink_data.dart';
import '../utils/app_utils.dart';

class MavlinkServerService {
  static final MavlinkServerService instance = MavlinkServerService._internal();
  factory MavlinkServerService() => instance;
  MavlinkServerService._internal();

  HttpServer? _server;
  final Set<WebSocketChannel> _connectedClients = {};

  // 1. Jalankan Server Lokal
  Future<void> startServer() async {
    if (_server != null) return;

    // webSocketHandler sudah berupa Handler secara langsung
    var handler = webSocketHandler((
      WebSocketChannel channel,
      String? subProtocol,
    ) {
      debugPrint("Aplikasi klien (Kamera) terhubung!");
      _connectedClients.add(channel);

      channel.stream.listen(
        (message) {
          _handleClientMessage(message);
        },
        onDone: () {
          debugPrint("Aplikasi klien terputus.");
          _connectedClients.remove(channel);
        },
        onError: (error) {
          debugPrint("Error WebSocket Klien: $error");
          _connectedClients.remove(channel);
        },
      );
    });

    try {
      // Jalankan server di localhost dengan port 8080
      _server = await io.serve(handler, '127.0.0.1', 8080);
      debugPrint("MAVLink WebSocket Server berjalan di ws://127.0.0.1:8080");
    } catch (e) {
      debugPrint("Gagal menjalankan server MAVLink: $e");
    }
  }

  // 2. Broadcast data posisi kapal ke semua klien (Aplikasi Kamera)
  void broadcastVesselState(double lat, double lon, double heading) {
    if (_connectedClients.isEmpty) return;

    final payload = jsonEncode({
      'type': 'VESSEL_STATE',
      'lat': lat,
      'lon': lon,
      'heading': heading,
    });

    for (var client in _connectedClients) {
      client.sink.add(payload);
    }
  }

  // 3. Tangani pesan dari aplikasi kamera
  void _handleClientMessage(String message) {
    try {
      final data = jsonDecode(message);
      if (data['type'] == 'TARGET_COORDINATE') {
        double targetLat = data['lat'];
        double targetLon = data['lon'];
        bool isValid = data['isValid'];
        // print(
        //   "🎯 Menerima Koordinat Target dari App Kamera: $isValid, $targetLat, $targetLon",
        // );

        if (MavlinkData.isObjectValid != isValid) {
          MavlinkData.isObjectValid = isValid;
        }

        AppData.objectCoord.value = LatLng(targetLat, targetLon);

        if (isValid) {
          final pos = MavlinkData.lastGlobalPositionInt;
          if (pos != null) {
            double currentLat = pos.lat / 1e7;
            double currentLon = pos.lon / 1e7;

            double heading = AppUtils.calculateBearing(
              currentLat,
              currentLon,
              targetLat,
              targetLon,
            );

            AppData.headingToTarget.value = heading;
          }
        } else {
          AppData.headingToTarget.value = 0.0;
        }
      }
    } catch (e) {
      debugPrint("⚠️ Gagal parsing pesan klien: $e");
    }
  }

  // 4. Matikan server dengan aman
  Future<void> stopServer() async {
    // Salin daftar klien ke list baru agar iterasi dan penutupan tidak konflik
    final clientsToClose = _connectedClients.toList();
    _connectedClients.clear();

    for (var client in clientsToClose) {
      try {
        await client.sink.close();
      } catch (e) {
        // Abaikan jika sudah tertutup
      }
    }

    await _server?.close();
    _server = null;
    debugPrint("⏹️ MAVLink WebSocket Server dihentikan.");
  }
}
