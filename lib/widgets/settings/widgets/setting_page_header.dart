import 'package:flutter/material.dart';

class SettingPageHeader extends StatelessWidget{
  final String title;
  final String subtitle;

  const SettingPageHeader({
    super.key,
    required this.title,
    required this.subtitle
  });

  @override
  Widget build(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withAlpha(130)
          ),
        ),
        Divider(
          color: Colors.white.withAlpha(20),
          thickness: 1,
        )
      ],
    );
  }
}