import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/widgets/section_card.dart';
import 'package:frontend/core/widgets/status_badge.dart';
import 'package:frontend/features/admin/dashboard/presentation/data/get_users.dart';
import 'package:go_router/go_router.dart';

class UserInfomationPage extends StatelessWidget {
  final UserTemplate user;

  const UserInfomationPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                children: [
                  _buildSectionCard(
                    context,
                    title: 'ข้อมูลพื้นฐานและช่องทางติดต่อ',
                    icon: Icons.person_outline_rounded,
                    child: _buildContactInfo(context),
                  ),
                  if (user.role == 'TENANT') ...[
                    const SizedBox(height: 20),
                    _buildSectionCard(
                      context,
                      title: 'รายละเอียดสัญญาเช่า',
                      icon: Icons.description_outlined,
                      child: _buildContractInfo(context),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.textPrimary,
          size: 20,
        ),
      ),
      title: const Text(
        'ข้อมูลผู้ใช้งาน',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return SectionCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: AppColors.divider, height: 1),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${user.firstname} ${user.lastname}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.role == 'TENANT' ? 'ผู้เช่าพักอาศัย' : 'ผู้ดูแลระบบ',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Divider(color: AppColors.divider, height: 1),
        ),
        if (user.roomNumber != null) ...[
          _buildInfoRow(
            'หมายเลขห้อง - ชั้น',
            'ห้อง ${user.roomNumber} - ชั้น ${user.floor ?? "-"}',
            Icons.meeting_room_outlined,
          ),
          const SizedBox(height: 16),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 12),
                Text(
                  'สถานะการใช้งาน',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            _buildStatusBadge(user.userStatus, true),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Divider(color: AppColors.divider, height: 1),
        ),
        _buildInfoRow('เบอร์โทรศัพท์', user.phone, Icons.phone_android_rounded),
        const SizedBox(height: 16),
        _buildInfoRow(
          'อีเมล',
          user.email.isEmpty ? '-' : user.email,
          Icons.email_outlined,
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          'ติดต่อฉุกเฉิน',
          (user.emergencyPhone == null || user.emergencyPhone!.isEmpty)
              ? '-'
              : user.emergencyPhone!,
          Icons.emergency_outlined,
        ),
      ],
    );
  }

  Widget _buildContractInfo(BuildContext context) {
    return Column(
      children: [
        _buildInfoRow(
          'เลขที่สัญญา',
          '#${user.contractNo ?? "-"}',
          Icons.description_outlined,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildRateItem('ค่าเช่า/เดือน', user.rateRoom, Icons.home_work_outlined),
            _buildRateItem('ค่าน้ำ/หน่วย', user.rateWater, Icons.water_drop_outlined),
            _buildRateItem('ค่าไฟ/หน่วย', user.rateElectric, Icons.bolt_rounded),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(color: AppColors.divider, height: 1),
        const SizedBox(height: 20),
        _buildInfoRow(
          'วันที่เริ่มสัญญา',
          _formatThaiDate(user.startDate),
          Icons.calendar_today_rounded,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          'วันที่สิ้นสุดสัญญา',
          _formatThaiDate(user.endDate),
          Icons.event_busy_rounded,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'เงินประกันสัญญา',
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${user.deposit?.toStringAsFixed(0)} บาท',
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
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

  Widget _buildRateItem(String label, int? rate, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppColors.primary),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          '${rate?.toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const Text(
          'บาท',
          style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status, bool isAccount) {
    final statusUpper = status.toUpperCase();
    String text;
    BadgeStatus badgeStatus;

    if (statusUpper == 'ACTIVE') {
      text = 'เข้าสู่ระบบแล้ว';
      badgeStatus = BadgeStatus.completed;
    } else if (statusUpper == 'INACTIVE') {
      text = isAccount ? 'ยังไม่เข้าสู่ระบบ' : 'รอเปิดสัญญา';
      badgeStatus = BadgeStatus.pending;
    } else if (statusUpper == 'BANNED' || statusUpper == 'EXPIRED') {
      text = statusUpper == 'BANNED' ? 'ถูกระงับบัญชี' : 'หมดอายุแล้ว';
      badgeStatus = BadgeStatus.urgent;
    } else {
      text = status.isEmpty ? 'ไม่ระบุ' : status;
      badgeStatus = BadgeStatus.info;
    }

    return StatusBadge(text: text, status: badgeStatus);
  }

  String _formatThaiDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == 'null') return '-';
    try {
      final date = DateTime.parse(dateStr);
      const months = [
        'ม.ค.',
        'ก.พ.',
        'มี.ค.',
        'เม.ย.',
        'พ.ค.',
        'มิ.ย.',
        'ก.ค.',
        'ส.ค.',
        'ก.ย.',
        'ต.ค.',
        'พ.ย.',
        'ธ.ค.',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year + 543}';
    } catch (_) {
      return dateStr;
    }
  }
}
