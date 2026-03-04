import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  final Widget child; // ลูกส่วน
  final EdgeInsetsGeometry padding; // ระยะขอบ
  final VoidCallback? onTap; // ฟังก์ชันที่จะถูกเรียกเมื่อคลิก

  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Padding(padding: padding, child: child),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: card,
      );
    }

    return card;
  }
}
