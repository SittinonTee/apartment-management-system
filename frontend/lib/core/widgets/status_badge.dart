import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

enum BadgeStatus { pending, completed, urgent, info }

class StatusBadge extends StatelessWidget {
  final String text; // ข้อความที่จะแสดงบนปุ่ม (จำเป็นต้องใส่)
  final BadgeStatus status; // สถานะของปุ่ม (จำเป็นต้องใส่)

  const StatusBadge({super.key, required this.text, required this.status});

  Color _getBackgroundColor() {
    switch (status) {
      case BadgeStatus.pending: // สถานะ "รอ"
        return AppColors.warning.withValues(alpha: 0.15);
      case BadgeStatus.completed: // สถานะ "เสร็จสิ้น"
        return AppColors.success.withValues(alpha: 0.15);
      case BadgeStatus.urgent: // สถานะ "ด่วน"
        return AppColors.error.withValues(alpha: 0.15);
      case BadgeStatus.info: // สถานะ "ข้อมูล"
        return AppColors.info.withValues(alpha: 0.15);
    }
  }

  Color _getTextColor() {
    switch (status) {
      case BadgeStatus.pending: // สถานะ "รอ"
        return AppColors.warning;
      case BadgeStatus.completed: // สถานะ "เสร็จสิ้น"
        return AppColors.success;
      case BadgeStatus.urgent: // สถานะ "ด่วน"
        return AppColors.error;
      case BadgeStatus.info: // สถานะ "ข้อมูล"
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: AppTypography.textTheme.bodySmall?.copyWith(
          color: _getTextColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
