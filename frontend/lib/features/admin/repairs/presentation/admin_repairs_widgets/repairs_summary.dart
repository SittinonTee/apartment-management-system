import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/utils/formatter.dart';
import 'package:frontend/features/admin/repairs/presentation/admin_repairs_widgets/admin_repairs_info_card.dart';

class RepairsSummary extends StatelessWidget {
  final int countProblem;
  final int countInProgress;
  final int countMaterial;
  final int countCompleted;

  const RepairsSummary({
    super.key,
    required this.countProblem,
    required this.countInProgress,
    required this.countMaterial,
    required this.countCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _SummaryItem(
        color: AppColors.error,
        value: countProblem,
        label: 'ปัญหา',
      ),
      _SummaryItem(
        color: AppColors.warning,
        value: countInProgress,
        label: 'ดำเนิน..',
      ),
      _SummaryItem(
        color: AppColors.info,
        value: countMaterial,
        label: 'จัดซื้อ',
      ),
      _SummaryItem(
        color: AppColors.success,
        value: countCompleted,
        label: 'สำเร็จ',
      ),
    ];

    return AdminRepairsInfoCard(
      height: 72,
      shadow: false,
      borderColor: AppColors.border,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: List.generate(items.length * 2 - 1, (index) {
          // odd indices = divider
          if (index.isOdd) {
            return Container(width: 1, height: 32, color: AppColors.divider);
          }
          final item = items[index ~/ 2];
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  Formatter.formatNumber(item.value),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: item.color,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _SummaryItem {
  final Color color;
  final int value;
  final String label;

  const _SummaryItem({
    required this.color,
    required this.value,
    required this.label,
  });
}
