import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text; // ข้อความที่จะแสดงบนปุ่ม (จำเป็นต้องใส่)
  final VoidCallback
  onPressed; // ฟังก์ชันที่จะถูกเรียกเมื่อปุ่มถูกกด (จำเป็นต้องใส่)
  final bool isPrimary; // กำหนดปุ่มเป็นสีหลักหรือไม่ (default: true)
  final bool isOutlined; // กำหนดปุ่มเป็นสีข้อความ (default: false)
  final Widget? icon; // ไอคอนที่จะแสดงบนปุ่ม (default: null)

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.isOutlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: icon ?? const SizedBox.shrink(),
          label: Text(text),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppColors.primary : AppColors.surface,
          foregroundColor: isPrimary
              ? AppColors.textInverse
              : AppColors.textPrimary,
        ),
        icon: icon ?? const SizedBox.shrink(),
        label: Text(text),
      ),
    );
  }
}
