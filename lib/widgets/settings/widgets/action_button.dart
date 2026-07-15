import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color color;
  final VoidCallback? onTap;

  const ActionButton({
    super.key,
    required this.text,
    this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = onTap == null ? Colors.white38 : color;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 24,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color, width: 0.9),
          color: buttonColor.withAlpha(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: buttonColor),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(
                color: buttonColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
