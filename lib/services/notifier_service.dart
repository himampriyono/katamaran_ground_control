import 'package:flutter/material.dart';

class NotifierService {
  static final ValueNotifier<int> connectionTrigger = ValueNotifier<int>(0);
  static final ValueNotifier<int> attitudeTrigger = ValueNotifier<int>(0);
  static final ValueNotifier<int> positionTrigger = ValueNotifier<int>(0);
  static final ValueNotifier<int> statusTrigger = ValueNotifier<int>(0);
  static final ValueNotifier<int> vfrTrigger = ValueNotifier<int>(0);
  static final ValueNotifier<int> homeTrigger = ValueNotifier<int>(0);
  static final ValueNotifier<int> gpsTrigger = ValueNotifier<int>(0);
  static final ValueNotifier<int> rcTrigger = ValueNotifier<int>(0);
  static final ValueNotifier<int> pwmTrigger = ValueNotifier<int>(0);
  static final ValueNotifier<int> parameterTrigger = ValueNotifier<int>(0);
  static final ValueNotifier<int> missionTrigger = ValueNotifier<int>(0);

  static void triggerConnectionUpdate() => connectionTrigger.value++;
  static void triggerAttitudeUpdate() => attitudeTrigger.value++;
  static void triggerPositionUpdate() => positionTrigger.value++;
  static void triggerStatusUpdate() => statusTrigger.value++;
  static void triggerVfrUpdate() => vfrTrigger.value++;
  static void triggerHomeUpdate() => homeTrigger.value++;
  static void triggerGpsUpdate() => gpsTrigger.value++;
  static void triggerRcUpdate() => rcTrigger.value++;
  static void triggerPwmUpdate() => pwmTrigger.value++;
  static void triggerParameterUpdate() => parameterTrigger.value++;
  static void triggerMissionUpdate() => missionTrigger.value++;
}
