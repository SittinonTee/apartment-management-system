import 'package:flutter/material.dart';
import '../../../../core/widgets/section_card.dart';
import '../../data/repair_model.dart';
import 'status_badge.dart';

class TechnicianRepairCard extends StatelessWidget {
  final RepairRequest repair;
  final VoidCallback? onTap;

  const TechnicianRepairCard({super.key, required this.repair, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SectionCard(
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon แสดงประเภทงาน
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: repair.statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                repair.typeIcon,
                color: repair.typeIconColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // รายละเอียดงาน
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    repair.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    repair.categoryName ?? 'อื่นๆ',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ลงวันที่ : ${repair.date.day} พ.ค. ${repair.date.year + 543}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // ป้ายสถานะและไอคอนลูกศร
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusBadge(
                  status: repair.statusEnum,
                  text: repair.statusText,
                  bgColor: repair.statusColor,
                  textColor: repair.statusTextColor,
                ),
                const SizedBox(height: 12),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
