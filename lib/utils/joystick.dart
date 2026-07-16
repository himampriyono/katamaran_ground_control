import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import '../data/app_data.dart';
import '../widgets/snackbar.dart';

class Joystick {
  Joystick._();

  static SerialPort? _port;
  static SerialPortReader? _reader;
  static StreamSubscription<Uint8List>? _subscription;
  static String _validPort = "";
  static bool _disconnecting = false;

  static Completer<bool>? _verifyCompleter;

  static const int header1 = 0x48; // H
  static const int header2 = 0x4D; // M
  static const int headerSize = 3;
  static final List<int> _buffer = [];

  static Timer? _recoverTimer;
  static int _recoverAttempt = 0;

  static List<String> scanPort() {
    final availablePort = SerialPort.availablePorts;
    AppData.availablePorts = availablePort;
    return availablePort;
  }

  static List<String> scanUsbPort() {
    return SerialPort.availablePorts.where((portName) {
      final port = SerialPort(portName);
      return port.transport == SerialPortTransport.usb;
    }).toList();
  }

  static Future<bool> connect(String portName, {int baudRate = 115200}) async {
    _port = SerialPort(portName);
    if (_port!.transport != SerialPortTransport.usb) {
      // debugPrint("$portName bukan USB");
      return false;
    }
    if (!_port!.openReadWrite()) {
      debugPrint("Cant open $portName");
      return false;
    }
    final config = _port!.config;
    config.baudRate = baudRate;
    config.bits = 8;
    config.stopBits = 1;
    config.parity = SerialPortParity.none;
    _port!.config = config;

    _reader = SerialPortReader(_port!);
    _subscription = _reader!.stream.listen(
      (data) {
        _buffer.addAll(data);
        while (true) {
          if (_buffer.length < 3) {
            return;
          }

          if (_buffer[0] != header1 || _buffer[1] != header2) {
            _buffer.removeAt(0);
            continue;
          }

          final payloadLength = _buffer[2];
          final packetLength = 3 + payloadLength;

          if (_buffer.length < packetLength) {
            return;
          }

          final packet = Uint8List.fromList(_buffer.sublist(0, packetLength));

          _buffer.removeRange(0, packetLength);

          const int channelCount = 16;
          const int channelBytes = channelCount * 2;
          final channels = <int>[];

          for (int i = 3; i < 3 + channelBytes; i += 2) {
            final value = packet[i] | (packet[i + 1] << 8);
            channels.add(value);
          }

          bool valid = true;

          for (final value in channels) {
            if (value < 800 || value > 2200) {
              valid = false;
              break;
            }
          }

          if (!valid) {
            continue;
          }

          final calibrationState = packet[3 + channelBytes];

          if (AppData.joystickStatus.value != JoystickStatus.connected) {
            AppData.joystickStatus.value = JoystickStatus.connected;
            Snackbar.show("Joystick is Connected!");

            stopRecoverJoystick();
          }
          if (AppData.selectedPort.value == "-") {
            AppData.selectedPort.value = portName;
          }
          AppData.joystickChannels.value = channels;
          AppData.joystickCalibrationStatus.value = calibrationState == 1
              ? JoystickCalibrationStatus.calibrating
              : JoystickCalibrationStatus.normal;

          if (AppData.joystickCalibrationStatus.value ==
              JoystickCalibrationStatus.calibrating) {
            final minValues = List<int>.from(
              AppData.joystickCalibrationMin.value,
            );
            final maxValues = List<int>.from(
              AppData.joystickCalibrationMax.value,
            );

            for (int i = 0; i < 16; i++) {
              if (channels[i] < minValues[i]) {
                minValues[i] = channels[i];
              }

              if (channels[i] > maxValues[i]) {
                maxValues[i] = channels[i];
              }
            }

            AppData.joystickCalibrationMin.value = minValues;
            AppData.joystickCalibrationMax.value = maxValues;
          }
        }
      },
      onError: (error) async {
        debugPrint("Joystick Error: $error");
        await disconnect();

        startRecoverJoystick();
      },
      onDone: () {
        debugPrint("Joystick Disconnected");
      },
      cancelOnError: true,
    );
    return true;
  }

  static Future<String?> checkPort(String portName, {baudRate = 115200}) async {
    _verifyCompleter = Completer<bool>();
    // _validPort = "";
    // AppData.selectedPort.value = "";
    final port = SerialPort(portName);
    if (port.transport != SerialPortTransport.usb) {
      // debugPrint("$portName bukan USB");
      return null;
    }

    if (!port.openReadWrite()) {
      debugPrint("Cant open $portName");
      return null;
    }

    final config = port.config;
    config.baudRate = baudRate;
    config.bits = 8;
    config.stopBits = 1;
    config.parity = SerialPortParity.none;
    port.config = config;

    final reader = SerialPortReader(port);
    final List<int> buff = [];
    StreamSubscription<Uint8List>? sub;

    sub = reader.stream.listen((data) {
      buff.addAll(data);
      while (true) {
        if (buff.length < 3) {
          return;
        }

        if (buff[0] != header1 || buff[1] != header2) {
          buff.removeAt(0);
          continue;
        }

        final payloadLength = buff[2];
        final packetLength = 3 + payloadLength;

        if (buff.length < packetLength) {
          return;
        }

        debugPrint("dapat js");
        buff.removeRange(0, packetLength);

        if (!_verifyCompleter!.isCompleted) {
          debugPrint("Joystick Found");
          // _validPort = portName;
          // AppData.selectedPort.value = portName;
          _verifyCompleter!.complete(true);
          return;
        }
      }
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!_verifyCompleter!.isCompleted) {
        debugPrint("Verification timeout");
        _verifyCompleter!.complete(false);
      }
    });

    final result = await _verifyCompleter!.future;

    await sub.cancel();

    port.close();
    port.dispose();
    buff.clear();

    if (result) {
      return portName;
    } else {
      return null;
    }
  }

  static Future<void> disconnect() async {
    if (_disconnecting) {
      return;
    }

    _disconnecting = true;
    debugPrint("Cancel subscription");
    await _subscription?.cancel();
    _subscription = null;
    _reader = null;

    if (_port != null) {
      if (_port!.isOpen) {
        debugPrint("Close port");
        _port!.close();
      }
      debugPrint("Dispose port");
      _port!.dispose();
      _port = null;
    }

    _buffer.clear();
    debugPrint("Joystick disconnected");
    _disconnecting = false;
    if (AppData.joystickStatus.value != JoystickStatus.disconnected) {
      AppData.joystickStatus.value = JoystickStatus.disconnected;
    }
    AppData.selectedPort.value = "-";
    Snackbar.show("Joystick Disconnected!", isWarning: true);
  }

  static Future<bool> startAutoConnectJoystick() async {
    if (_port != null && _port!.isOpen) {
      await disconnect();
    }

    debugPrint("Scanning available port...");
    AppData.joystickStatus.value = JoystickStatus.connecting;
    Snackbar.show("Joystick is Connecting...");

    final ports = scanPort();
    debugPrint("${ports.length} Port(s) Found");

    for (final port in ports) {
      final validPort = await checkPort(port);
      debugPrint("$port: $validPort");

      if (validPort == null) {
        continue;
      }

      final connected = await connect(port);

      if (connected) {
        AppData.selectedPort.value = port;
        return true;
      }
    }
    debugPrint("port joystick: $_validPort");

    debugPrint("No Joystick Detected");
    return false;
  }

  static Future<void> startRecoverJoystick() async {
    if (_recoverTimer != null) {
      return;
    }

    debugPrint("Start joystick recovery");

    _recoverAttempt = 0;

    _recoverTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      // await startAutoConnectJoystick();
      _recoverAttempt++;
      debugPrint("Joystick recover attempt: $_recoverAttempt/18");

      final success = await startAutoConnectJoystick();

      if (success) {
        debugPrint("Joystick recovered");

        timer.cancel();
        _recoverTimer = null;
        return;
      }

      if (_recoverAttempt >= 18) {
        debugPrint("Joystick recovery timeout");
        disconnect();

        timer.cancel();
        _recoverTimer = null;
      }
    });
  }

  static void stopRecoverJoystick() {
    _recoverTimer?.cancel();
    _recoverTimer = null;
    _recoverAttempt = 0;
  }

  static bool sendCommand(String command) {
    if (_port == null || !_port!.isOpen) {
      return false;
    }

    final data = Uint8List.fromList("$command\n".codeUnits);

    return _port!.write(data) == data.length;
  }

  static bool startCalibration() {
    AppData.joystickCalibrationMin.value = List.filled(16, 2000);
    AppData.joystickCalibrationMax.value = List.filled(16, 1000);

    return sendCommand("841");
  }

  static bool stopCalibration() {
    return sendCommand("842");
  }
}
