import 'package:flutter/material.dart';

class MainWindow extends StatelessWidget {
  final Widget child;

  const MainWindow({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}