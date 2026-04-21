import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/admin/dashboard/presentation/data/get_users.dart';

class UsersInfoCard extends StatelessWidget {
  final UserTemplate user;
  final VoidCallback? onTap;

  const UsersInfoCard({super.key, required this.user, this.onTap});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      height: 100,
      shadow: false,
      borderColor: AppColors.border,
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${user.firstname} ${user.lastname}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Row(
                      children: [
                        if (user.contractStatus.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: user.contractStatus == 'ACTIVE'
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              user.contractStatus,
                              style: TextStyle(
                                fontSize: 10,
                                color: user.contractStatus == 'ACTIVE'
                                    ? Colors.green
                                    : Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9AAFAF),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFFC8D8D8)),
                  ],
                ),
                Text(
                  "ห้อง ${user.roomNumber} - ชั้น ${user.floor}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFB0B0B0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final double? width;
  final double? height;
  final Color color;
  final double borderRadius;
  final Color borderColor;
  final double borderSize;
  final bool shadow;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
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
    this.onTap,
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
