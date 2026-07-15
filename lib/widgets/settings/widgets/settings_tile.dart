import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget{
  final String title;
  final Widget trailing;

  const SettingsTile({
    super.key,
    required this.title,
    required this.trailing
  });

  @override
  Widget build(BuildContext context){
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          SizedBox(width: 24),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15
              ),
            ),
          ),
          trailing,
          SizedBox(height: 4),
        ],
      ),
    );
  }
}