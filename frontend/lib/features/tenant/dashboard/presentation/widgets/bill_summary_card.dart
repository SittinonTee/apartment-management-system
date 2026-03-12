import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';

import '../../../../../core/widgets/section_card.dart';
import '../../../../../core/widgets/status_badge.dart';

class BillSummaryCard extends StatelessWidget {
  final double amount; // จำนวนเงิน
  final String month; // เดือน
  final BadgeStatus status; // สถานะ
  final String statusText; // ข้อความสถานะ
  final VoidCallback onPayPressed; // ฟังก์ชันที่จะถูกเรียกเมื่อคลิก

  const BillSummaryCard({
    super.key,
    required this.amount,
    required this.month,
    required this.status,
    required this.statusText,
    required this.onPayPressed,
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
                'บิลค่าเช่ารอชำระ',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              StatusBadge(text: statusText, status: status),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'ประจำเดือน $month',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                NumberFormat.decimalPattern().format(amount),
                style: Theme.of(
                  context,
                ).textTheme.displayMedium?.copyWith(color: AppColors.primary),
              ),

              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'บาท',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPayPressed,
              child: const Text('ชำระเงิน'),
            ),
          ),
        ],
      ),
    );
  }
}
