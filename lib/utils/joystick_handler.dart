import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../widgets/snackbar.dart';

class JoystickHandler {
  static SerialPort? _activePort;
  static SerialPortReader? _portReader;
  static StreamSubscription<Uint8List>? _streamSubscription;
  static String _bufferData = "";
  static String? _lastConnectedPort;
  static Function(String)? _lastStatusCallback;

  static Timer? _reconnectTimer;
  static bool _isConnecting = false;
  static int _lastBaudRate = 115200;

  static List<String> scanAvailablePorts() {
    AppData.availablePorts = SerialPort.availablePorts;
    return AppData.availablePorts;
  }

  static bool connectJoystick(
    String portName,
    int baudRate,
    Function(String) onStatusChanged,
  ) {
    try {
      disconnectJoystick();

      _activePort = SerialPort(portName);
      if (!_activePort!.openReadWrite()) {
        debugPrint("Joystick open port $portName");
        return false;
      }

      _activePort!.config.baudRate = baudRate;
      _activePort!.config.bits = 8;
      _activePort!.config.stopBits = 1;
      _activePort!.config.parity = SerialPortParity.none;

      _portReader = SerialPortReader(_activePort!);
      _streamSubscription = _portReader!.stream.listen(
        (Uint8List data) {
          String teksMasuk = utf8.decode(data, allowMalformed: true);
          _bufferData += teksMasuk;

          if (_bufferData.contains('\n')) {
            List<String> barisData = _bufferData.split('\n');
            String dataLengkap = barisData[barisData.length - 2].trim();
            _bufferData = barisData.last;

            List<String> dataChannel = dataLengkap.split(',');
            for (int i = 0; i < dataChannel.length; i++) {
              if (i < AppData.joystickData.length) {
                int? nilai = int.tryParse(dataChannel[i]);
                if (nilai != null) {
                  if (!AppData.joystickStatus.value) {
                    AppData.joystickStatus.value = true;
                  }
                  AppData.joystickData[i] = nilai;
                }
              }
            }
          } else {
            // if (AppData.joystickStatus.value) {
            //   AppData.joystickStatus.value = false;
            // }
          }
        },
        onError: (error) {
          debugPrint("Terputus: $error");
          if (AppData.joystickStatus.value) {
            AppData.joystickStatus.value = false;
          }
          AppData.selectedPort = "";
          Future.microtask(() => disconnectJoystick());
          Snackbar.show("Joystick Disconnected!", isWarning: true);
        },
      );

      debugPrint("Terhubung ke $portName");
      Snackbar.show("Joystick controller detected on port: $portName");
      return true;
    } catch (e) {
      debugPrint("Error: $e");
      disconnectJoystick();
      return false;
    }
  }

  static void startAutoReconnectJoystick({
    required String targetPort,
    required int baudRate,
    required Function(String) onStatusChanged,
  }) {
    _lastConnectedPort = targetPort;
    _lastBaudRate = baudRate;
    _lastStatusCallback = onStatusChanged;

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {

      if (_activePort != null) return;
      if (_isConnecting) return;
      scanAvailablePorts();

      if (AppData.selectedPort.isNotEmpty) {
        if (AppData.availablePorts.contains(AppData.selectedPort)) {
          _isConnecting = true;
          connectJoystick(AppData.selectedPort, _lastBaudRate, onStatusChanged);
          _isConnecting = false;
        }
        return;
      }

      if (AppData.availablePorts.isEmpty) {
        // onStatusChanged("Waiting for joystick");
        return;
      }

      for (String portName in AppData.availablePorts) {
        onStatusChanged("Checking $portName...");

        bool isTarget = await _checkIfJoystick(portName, _lastBaudRate);
        if (isTarget) {
          AppData.selectedPort = portName;
          _isConnecting = true;
          connectJoystick(portName, _lastBaudRate, onStatusChanged);
          _isConnecting = false;
          break;
        }
      }
    });
  }

  static Future<bool> _checkIfJoystick(String portName, int baudRate) async {
    SerialPort? testPort;
    StreamSubscription? testSub;
    Completer<bool> completer = Completer();
    String testBuffer = "";

    try {
      testPort = SerialPort(portName);
      if (!testPort.openReadWrite()) return false;

      testPort.config.baudRate = baudRate;
      final reader = SerialPortReader(testPort);

      Timer(Duration(milliseconds: 1000), () {
        if (!completer.isCompleted) {
          testSub?.cancel();
          try {
            testPort?.close();
          } catch (_) {}
          completer.complete(false);
        }
      });

      testSub = reader.stream.listen(
        (Uint8List data) {
          testBuffer += utf8.decode(data, allowMalformed: true);
          if (testBuffer.contains('\n')) {
            List<String> lines = testBuffer.split('\n');
            String targetLine = lines.length > 1
                ? lines[lines.length - 2].trim()
                : lines[0].trim();

            List<String> tokens = targetLine.split(',');
            if (tokens.length >= 16) {
              testSub?.cancel();
              try {
                testPort?.close();
              } catch (_) {}
              if (!completer.isCompleted) completer.complete(true);
            }
          }
        },
        onError: (_) {
          testSub?.cancel();
          try {
            testPort?.close();
          } catch (_) {}
          if (!completer.isCompleted) completer.complete(false);
        },
      );
      return await completer.future;
    } catch (e) {
      testSub?.cancel();
      try {
        testPort?.close();
      } catch (e) {}
      return false;
    }
  }

  static void disconnectJoystick() {
    _streamSubscription?.cancel();
    _streamSubscription = null;

    try {
      _portReader?.close();
    } catch (_) {}
    _portReader = null;

    if (_activePort != null) {
      try {
        if (_activePort!.isOpen) {
          _activePort!.close();
        }
      } catch (_) {}
      _activePort = null;
    }

    _bufferData = "";
  }

  static void stopAutoReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    disconnectJoystick();
  }
}