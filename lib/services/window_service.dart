import 'package:flutter/services.dart';

class WindowService {
  static int cameraWindowId = -1;

  static Future<void> registerHandler(
    Future<dynamic> Function(
      MethodCall call,
      int fromWindowId,
    ) handler,
  ) async {
    // .setMethodHandler(handler);
  }
}