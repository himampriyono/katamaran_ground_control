import 'package:flutter/material.dart';

class NotifierService {
  static final ValueNotifier<int> connectionTrigger = ValueNotifier<int>(0);
  static final ValueNotifier<int> attitudeTrigger = ValueNotifier<int>(0);
  static final ValueNotifier<int> positionTrigger = ValueNotifier<int>(0);
  static final ValueNotifier<int> statusTrigger = ValueNotifier<int>(0);
  static final ValueNotifier<int> vfrTrigger = ValueNotifier<int>(0);
  static final ValueNotifier<int> homeTrigger = ValueNotifier<int>(0);

  static void triggerConnectionUpdate() => connectionTrigger.value++;
  static void triggerAttitudeUpdate() => attitudeTrigger.value++;
  static void triggerPositionUpdate() => positionTrigger.value++;
  static void triggerStatusUpdate() => statusTrigger.value++;
  static void triggerVfrUpdate() => vfrTrigger.value++;
  static void triggerHomeUpdate() => homeTrigger.value++;
}