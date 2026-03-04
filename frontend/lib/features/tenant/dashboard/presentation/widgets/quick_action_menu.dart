import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class QuickActionMenu extends StatelessWidget {
  final VoidCallback onContractPressed; // ฟังก์ชันที่จะถูกเรียกเมื่อคลิก
  final VoidCallback onBillsPressed; // ฟังก์ชันที่จะถูกเรียกเมื่อคลิก
  final VoidCallback onPackagePressed; // ฟังก์ชันที่จะถูกเรียกเมื่อคลิก
  final VoidCallback onRepairPressed; // ฟังก์ชันที่จะถูกเรียกเมื่อคลิก

  const QuickActionMenu({
    super.key,
    required this.onContractPressed,
    required this.onBillsPressed,
    required this.onPackagePressed,
    required this.onRepairPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('เมนูลัด', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionItem(
              context,
              icon: Icons.description_outlined,
              label: 'สัญญาเช่า',
              onTap: onContractPressed,
            ),
            _buildActionItem(
              context,
              icon: Icons.receipt_long_outlined,
              label: 'บิลค่าเช่า',
              onTap: onBillsPressed,
            ),
            _buildActionItem(
              context,
              icon: Icons.inventory_2_outlined,
              label: 'รับพัสดุ',
              onTap: onPackagePressed,
            ),
            _buildActionItem(
              context,
              icon: Icons.build_outlined,
              label: 'ยื่นเรื่องซ่อม',
              onTap: onRepairPressed,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, size: 28, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
