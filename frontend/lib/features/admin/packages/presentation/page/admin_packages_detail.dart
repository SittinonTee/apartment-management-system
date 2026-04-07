import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';

import 'package:frontend/features/admin/packages/data/admin_packages_provider.dart';

class AdminPackagesDetail extends StatelessWidget {
  final int id; // รับไอดีพัสดุมาเพื่อกดยืนยันรับ
  final String date;
  final String name;
  final String room;
  final String status;
  final String receivedBy;

  const AdminPackagesDetail({
    super.key,
    required this.id,
    required this.date,
    required this.name,
    required this.room,
    required this.status,
    required this.receivedBy,
  });

  @override
  Widget build(BuildContext context) {
    bool isPickedUp = status == "สำเร็จ" || status == "PICKED_UP";

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ===== HEADER =====
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const CircleAvatar(
                      backgroundColor: AppColors.background,
                      child: Icon(Icons.close, color: Colors.black),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    "จัดการพัสดุ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                ],
              ),

              const SizedBox(height: 20),

              // ===== รูปพัสดุ =====
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Image.asset(
                  "assets/images/box.png", // ใส่รูปของคุณ
                  height: 150,
                ),
              ),

              const SizedBox(height: 20),

              // ===== CARD INFO =====
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "ข้อมูลพัสดุ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isPickedUp
                                ? Colors.green.shade100
                                : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: isPickedUp
                                  ? Colors.green
                                  : Colors.orange.shade900,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: AppColors.divider, height: 1),
                    ),
                    _buildInfoRow(
                      'รับพัสดุเมื่อ',
                      date,
                      Icons.calendar_today_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'ชื่อผู้รับ',
                      name,
                      Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'ส่งมอบโดย',
                      receivedBy,
                      Icons.admin_panel_settings_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'พัสดุสำหรับห้อง',
                      room,
                      Icons.meeting_room_outlined,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ===== BUTTON =====
              if (!isPickedUp)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () async {
                      // กดรับพัสดุ ยืนยันผ่าน API
                      final success = await AdminPackagesProvider()
                          .pickupParcel(id);
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('รับพัสดุเรียบร้อยแล้ว'),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("กดเพื่อรับพัสดุ"),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.textSecondary.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
