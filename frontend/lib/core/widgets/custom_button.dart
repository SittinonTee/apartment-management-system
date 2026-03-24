import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String? text; // ข้อความที่จะแสดงบนปุ่ม (จำเป็นต้องใส่)
  final VoidCallback
  onPressed; // ฟังก์ชันที่จะถูกเรียกเมื่อปุ่มถูกกด (จำเป็นต้องใส่)
  final bool isPrimary; // กำหนดปุ่มเป็นสีหลักหรือไม่ (default: true)
  final bool isOutlined; // กำหนดปุ่มเป็นสีข้อความ (default: false)
  final Widget? icon; // ไอคอนที่จะแสดงบนปุ่ม (default: null)
  final double? width; // เพิ่มให้ปรับความกว้างได้
  final double? height; // เพิ่มให้ปรับความสูงได้
  final TextStyle? textStyle; // เพิ่มแต่ง Font/Style
  final BorderRadius? borderRadius; // เพิ่มให้ปรับขอบปุ่มได้
  final EdgeInsetsGeometry? padding; // เพิ่มให้ปรับ Padding ได้

  const CustomButton({
    super.key,
    this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.isOutlined = false,
    this.icon,
    this.width,
    this.height,
    this.textStyle,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: icon ?? const SizedBox.shrink(),
          label: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(text ?? '', style: textStyle),
          ),
          style: OutlinedButton.styleFrom(
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: icon == null
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPrimary
                    ? AppColors.primary
                    : AppColors.surface,
                foregroundColor: isPrimary
                    ? AppColors.textInverse
                    : AppColors.textPrimary,
                padding:
                    padding ??
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: borderRadius ?? BorderRadius.circular(12),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(text ?? '', style: textStyle),
              ),
            )
          : ElevatedButton.icon(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPrimary
                    ? AppColors.primary
                    : AppColors.surface,
                foregroundColor: isPrimary
                    ? AppColors.textInverse
                    : AppColors.textPrimary,
                padding:
                    padding ??
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: borderRadius ?? BorderRadius.circular(12),
                ),
              ),
              icon: icon!,
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(text ?? '', style: textStyle),
              ),
            ),
    );
  }
}
