import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/services/auth_service.dart';
import 'package:provider/provider.dart';

class UserGreeting extends StatelessWidget {
  final String userName; // ชื่อผู้ใช้
  final String roomNumber; // เลขห้อง

  const UserGreeting({
    super.key,
    required this.userName,
    required this.roomNumber,
  });

  @override
  Widget build(BuildContext context) {
    // final authService = context.watch<AuthService>();
    // final displayWeight = authService.userName.isEmpty
    //     ? userName
    //     : authService.userName;
    // final displayWeight = userName;
    // final displayRoomNumber = roomNumber;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'สวัสดี,',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              // displayWeight.isEmpty ? 'ผู้ใช้งาน' : displayWeight,
              userName,
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.meeting_room,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'ห้อง $roomNumber',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
