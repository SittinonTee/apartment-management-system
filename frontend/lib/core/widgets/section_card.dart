import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';

class SectionCard extends StatelessWidget {
  final Widget child; // ลูกส่วน
  final EdgeInsetsGeometry padding; // ระยะขอบ
  final VoidCallback? onTap; // ฟังก์ชันที่จะถูกเรียกเมื่อคลิก
  final bool shadow;

  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.shadow = true,
    this.onTap,
  });

  static const setShadow = BoxShadow(
    color: Color.fromARGB(20, 0, 0, 0),
    blurRadius: 16,
    spreadRadius: 0,
    offset: Offset(0, 4),
  );

  @override
  Widget build(BuildContext context) {
    final cardContent = Padding(padding: padding, child: child);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: shadow ? [setShadow] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(16),
                child: cardContent,
              )
            : cardContent,
      ),
    );
  }
}
