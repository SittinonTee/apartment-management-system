import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/widgets/status_badge.dart';

class ContractListCard extends StatelessWidget {
  final String title;
  final String roomInfo;
  final String dateRange;
  final String rentPrice;
  final BadgeStatus status;
  final String statusText;
  final double? progressPercent;
  final VoidCallback? onTap;

  const ContractListCard({
    super.key,
    required this.title,
    required this.roomInfo,
    required this.dateRange,
    required this.rentPrice,
    required this.status,
    required this.statusText,
    this.progressPercent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // รับ onTap มาจากหน้าที่เรียกใช้งาน
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border, // ขอบเข้มขึ้นอีกสเต็ป (รหัสเดียวกับ AppColors.border)
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08), // เข้มขึ้นจาก 0.04 เป็น 0.08 เพื่อให้เงาชัดขึ้น
              blurRadius: 16, // กระจายเงาให้กว้างนุ่มๆ
              spreadRadius: 1, // ขยายขอบเขตของเงาออกมาอีกนิดให้เด้งออกจากพื้นหลัง
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Section
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1), // เปลี่ยนไปใช้สี Success อมเขียวตาม Theme
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: AppColors.success, // เขียว Success
                  ),
                ),
                const SizedBox(width: 16),
                // Text Data Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.textPrimary, // สีดำตัวหนังสือหลัก
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    roomInfo,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary, // สีเทารองสวยๆ
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StatusBadge(text: statusText, status: status),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                dateRange,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          if (rentPrice != '0 บาท/เดือน') ...[
                            const SizedBox(width: 8),
                            Text(
                              rentPrice,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Progress Bar Section
            if (progressPercent != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'เช่าอาศัยเป็นเวลา',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(progressPercent! * 100).toInt()}%',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progressPercent,
                  minHeight: 6,
                  backgroundColor: AppColors.border.withValues(alpha: 0.5), // หลอดใสๆ สีเทาหม่น
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary, // หลอดสีฟ้าอมเขียว (Primary Color)
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
