import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';

class ParcelCard extends StatelessWidget {
  final String date;
  final String name;
  final String room;
  final String status;

  final bool shadow;

  const ParcelCard({
    super.key,
    required this.date,
    required this.name,
    required this.room,
    required this.status,
    this.shadow = true,
  });

  static const setShadow = BoxShadow(
    color: Color.fromARGB(20, 0, 0, 0),
    blurRadius: 16,
    offset: Offset(0, 4),
  );

  @override
  Widget build(BuildContext context) {
    Color getStatusColor() {
      if (status == "สำเร็จ") return AppColors.success;
      if (status == "ตกค้าง") return AppColors.error;
      return AppColors.warning; // รอรับ
    }

    IconData getStatusIcon() {
      if (status == "สำเร็จ") return Icons.check_circle;
      if (status == "ตกค้าง") return Icons.warning_rounded;
      return Icons.inventory_2;
    }

    final statusColor = getStatusColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface, // ใช้สีจาก AppColors
        borderRadius: BorderRadius.circular(16),
        boxShadow: shadow ? [setShadow] : null,
      ),
      child: Row(
        children: [
          // ===== ICON =====
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(getStatusIcon(), color: statusColor),
          ),

          const SizedBox(width: 12),

          // ===== TEXT =====
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "ชื่อเจ้าของพัสดุ: $name",
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  "ห้อง $room",
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // ===== STATUS + ARROW =====
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 12),
                ),
              ),
              const SizedBox(height: 6),
              const Icon(Icons.chevron_right, color: AppColors.textHint),
            ],
          ),
        ],
      ),
    );
  }
}
