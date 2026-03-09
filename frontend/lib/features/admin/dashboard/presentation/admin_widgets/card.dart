import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';

class CustomCard extends StatelessWidget {
  final double? width;
  final double? height;
  final Color color;
  final double borderRadius;
  final Color borderColor;
  final double borderSize;
  final bool shadow;
  final EdgeInsetsGeometry padding;
  final Widget? child;

  const CustomCard({
    super.key,
    this.width = double.infinity,
    this.height = 150,
    this.color = Colors.white,
    this.borderRadius = 12,
    this.borderColor = AppColors.surface,
    this.borderSize = 1.5,
    this.shadow = true,
    this.padding = const EdgeInsets.all(12),
    this.child,
  });

  static const setShadow = BoxShadow(
    color: Color.fromARGB(20, 0, 0, 0),
    blurRadius: 12,
    spreadRadius: 0,
    offset: Offset(0, 4),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderSize),
        boxShadow: shadow ? [setShadow] : [],
      ),
      child: child,
    );
  }
}
