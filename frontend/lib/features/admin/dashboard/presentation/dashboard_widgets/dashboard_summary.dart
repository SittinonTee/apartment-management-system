import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/utils/formatter.dart';
import 'package:frontend/features/admin/dashboard/presentation/dashboard_widgets/users_info_card.dart';

class DashboardSummary extends StatelessWidget {
  final int totalTenants;
  final int vacantRooms;
  final int totalAdmins;

  const DashboardSummary({
    super.key,
    required this.totalTenants,
    required this.vacantRooms,
    required this.totalAdmins,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _SummaryItem(
        icon: Icons.people_outline,
        color: AppColors.primary,
        value: totalTenants,
        label: 'ผู้เช่า',
      ),
      _SummaryItem(
        icon: Icons.meeting_room_outlined,
        color: AppColors.success,
        value: vacantRooms,
        label: 'ห้องว่าง',
      ),
      _SummaryItem(
        icon: Icons.admin_panel_settings_outlined,
        color: AppColors.info,
        value: totalAdmins,
        label: 'แอดมิน',
      ),
    ];

    return CustomCard(
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

class _SummaryItem {
  final IconData icon;
  final Color color;
  final int value;
  final String label;

  const _SummaryItem({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });
}
