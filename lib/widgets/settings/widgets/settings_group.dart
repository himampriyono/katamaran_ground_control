import 'package:flutter/material.dart';

class SettingsGroup extends StatelessWidget{
  final String title;
  final Widget child;

  const SettingsGroup({
    super.key,
    required this.title,
    required this.child
  });

  @override
  Widget build(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600
          ),
        ),
        const SizedBox(height: 12),
        child,
        const SizedBox(height: 24)
      ],
    );
  }
}