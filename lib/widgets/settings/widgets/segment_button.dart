import 'package:flutter/material.dart';

class SegmentButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const SegmentButton({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // borderRadius: BorderRadius.circular(8),
          border: Border.all(
            width: 0.75,
            color: isSelected
                ? Colors.lightBlueAccent
                : Colors.white24,
          ),
          color: isSelected
          ? Colors.lightBlueAccent.withAlpha(25)
          : Colors.transparent
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }
}
