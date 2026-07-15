import 'package:flutter/material.dart';

class SettingsTextField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? hintText;
  final ValueChanged<String>? onChanged;

  const SettingsTextField({
    super.key,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.hintText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 30,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 13,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 13,
            color: Colors.white38,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          filled: true,
          fillColor: const Color(0xFF252525),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(
              color: Colors.white24,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(
              color: Colors.cyan,
            ),
          ),
        ),
      ),
    );
  }
}