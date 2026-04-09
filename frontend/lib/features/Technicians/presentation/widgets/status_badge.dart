import 'package:flutter/material.dart';
import '../../data/repair_model.dart';

class StatusBadge extends StatelessWidget {
  final RepairStatus status;
  final String text;
  final Color bgColor;
  final Color textColor;

  const StatusBadge({
    super.key,
    required this.status,
    required this.text,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
