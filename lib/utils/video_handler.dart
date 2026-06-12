import 'package:flutter/material.dart';
// import 'package:media_kit/media_kit.dart';
// import 'package:media_kit_video/media_kit_video.dart';

enum VideoStatus {
  disconnected,
  connecting,
  connected,
  error,
}

class VideoHandler {
  // late final Player player;
  // late final VideoController controller;

  final ValueNotifier<VideoStatus> status =
      ValueNotifier(VideoStatus.disconnected);

  String currentSource = "";

  VideoHandler() {
    debugPrint("Creating Player");

    // player = Player();

    debugPrint("Creating VideoController");

    // controller = VideoController(player);

    debugPrint("VideoHandler ready");
  }

  Future<void> play(String source) async {
    try {
      currentSource = source;

      status.value = VideoStatus.connecting;

      // await player.open(Media(source));

      status.value = VideoStatus.connected;
    } catch (e) {
      debugPrint("Video error: $e");

      status.value = VideoStatus.error;
    }
  }

  Future<void> stop() async {
    // await player.stop();

    status.value = VideoStatus.disconnected;
  }

  Future<void> dispose() async {
    // await player.dispose();
    status.dispose();
  }
}