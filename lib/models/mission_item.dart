import 'package:dart_mavlink/dialects/common.dart';
import 'package:flutter/material.dart';

class MissionItem {
  final int sequence;
  final MavCmd command;
  final double latitude;
  final double longitude;
  final double altitude;

  const MissionItem({
    required this.sequence,
    required this.command,
    required this.latitude,
    required this.longitude,
    required this.altitude,
  });
}
