import 'package:flutter/material.dart';

class CameraWindow extends StatelessWidget {
  final Widget child;

  const CameraWindow({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}