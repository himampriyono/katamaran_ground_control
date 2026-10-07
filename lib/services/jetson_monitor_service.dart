import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../data/app_data.dart';

class JetsonMonitorService {
  static Socket? _socket;
  static StreamSubscription<String>? _subscription;

  static String? _jetsonIp;

  static bool _connecting = false;

  static double? cpuTemp;
  static double? gpuTemp;
  static double? junctionTemp;

  static void connect(String ip) {
    _jetsonIp = ip;

    if (_connecting || _socket != null) {
      return;
    }

    _connect();
  }

  static Future<void> _connect() async {
    if (_jetsonIp == null) return;
    if (_connecting) return;

    _connecting = true;

    try {
      debugPrint('[JETSON] Connecting to $_jetsonIp:5005...');

      final socket = await Socket.connect(
        _jetsonIp!,
        5005,
        timeout: const Duration(seconds: 5),
      );

      _socket = socket;

      debugPrint('[JETSON] Connected to $_jetsonIp:5005');

      _connecting = false;

      _subscription = socket
          .map((data) => utf8.decode(data))
          .transform(const LineSplitter())
          .listen(
            _handleLine,
            onError: (error) {
              debugPrint('[JETSON] Socket error: $error');

              _handleDisconnect();
            },
            onDone: () {
              debugPrint('[JETSON] Connection closed');

              _handleDisconnect();
            },
            cancelOnError: false,
          );
    } catch (e) {
      _connecting = false;

      debugPrint('[JETSON] Connection failed: $e');

      _scheduleReconnect();
    }
  }

  static void _handleLine(String line) {
    if (line.trim().isEmpty) return;

    try {
      final data = jsonDecode(line);

      if (data is! Map) {
        debugPrint('[JETSON] Invalid data: $line');
        return;
      }

      cpuTemp = (data['cpu_temp'] as num?)?.toDouble();
      gpuTemp = (data['gpu_temp'] as num?)?.toDouble();
      junctionTemp = (data['junction_temp'] as num?)?.toDouble();

      // debugPrint(
      //   '[JETSON] '
      //   'CPU=${cpuTemp?.toStringAsFixed(1)}°C '
      //   'GPU=${gpuTemp?.toStringAsFixed(1)}°C '
      //   'Junction=${junctionTemp?.toStringAsFixed(1)}°C',
      // );
      AppData.jetsonTelemetry.value = JetsonTelemetry(
        connected: true,
        cpuTemp: (data['cpu_temp'] as num?)?.toDouble() ?? 0,
        gpuTemp: (data['gpu_temp'] as num?)?.toDouble() ?? 0,
        junctionTemp: (data['junction_temp'] as num?)?.toDouble() ?? 0,
      );
    } catch (e) {
      debugPrint('[JETSON] JSON parse error: $e');
      debugPrint('[JETSON] Raw: $line');
    }
  }

  static void _handleDisconnect() {
    _subscription?.cancel();
    _subscription = null;

    _socket?.destroy();
    _socket = null;

    _scheduleReconnect();
  }

  static void _scheduleReconnect() {
    if (_jetsonIp == null) return;

    Future.delayed(const Duration(seconds: 3), () {
      if (_socket == null && !_connecting) {
        _connect();
      }
    });
  }

  static Future<void> disconnect() async {
    _jetsonIp = null;

    await _subscription?.cancel();
    _subscription = null;

    _socket?.destroy();
    _socket = null;

    _connecting = false;

    debugPrint('[JETSON] Disconnected');
  }
}
