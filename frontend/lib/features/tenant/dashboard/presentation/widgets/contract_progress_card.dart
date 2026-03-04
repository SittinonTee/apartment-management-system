import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/section_card.dart';

class ContractProgressCard extends StatelessWidget {
  final double progressPercent; // ความคืบหน้าของสัญญาเช่า
  final String timeRemaining; // เหลือเวลาอีก

  const ContractProgressCard({
    super.key,
    required this.progressPercent,
    required this.timeRemaining,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ความคืบหน้าสัญญาเช่า',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '${(progressPercent * 100).toInt()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressPercent,
              minHeight: 10,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'เหลือเวลาอีก $timeRemaining',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
