import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class RepairDetailRow extends StatelessWidget {
  final String label;
  final Widget value;
  final bool showDivider;

  const RepairDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 110,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Expanded(child: value),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 24, color: Color(0xFFF2F2F2)),
      ],
    );
  }
}
