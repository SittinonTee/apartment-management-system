import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/utils/formatter.dart';
import 'package:frontend/features/admin/repairs/presentation/admin_repairs_widgets/admin_repairs_info_card.dart';

class AdminRepairsSummary extends StatelessWidget {
  final int problemCount;
  final int inprogress;
  final int prepareMaterials;
  final int completed;

  const AdminRepairsSummary({
    super.key,
    required this.problemCount,
    required this.inprogress,
    required this.prepareMaterials,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      RepairsItem(
        label: 'ปัญหา',
        value: problemCount,
        color: Colors.red,
        icon: Icons.report_problem,
      ),
      RepairsItem(
        label: 'กำลังดำเนินการ',
        value: inprogress,
        color: Colors.orange,
        icon: Icons.settings,
      ),
      RepairsItem(
        label: 'กำลังเตรียมวัสดุ',
        value: prepareMaterials,
        color: Colors.yellow,
        icon: Icons.construction,
      ),
      RepairsItem(
        label: 'เสร็จสิ้น',
        value: completed,
        color: Colors.green,
        icon: Icons.check_circle,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: item.color, size: 18),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Formatter.formatNumber(item.value),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      item.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class RepairsItem {
  final IconData icon;
  final Color color;
  final int value;
  final String label;

  const RepairsItem({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });
}
