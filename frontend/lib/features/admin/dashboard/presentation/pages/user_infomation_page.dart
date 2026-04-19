import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/widgets/section_card.dart';
import 'package:frontend/core/widgets/status_badge.dart';
import 'package:frontend/features/admin/dashboard/presentation/data/get_users.dart';
import 'package:frontend/core/utils/formatter.dart';
import 'package:frontend/features/admin/dashboard/presentation/data/admin_service_api.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';

class UserInfomationPage extends StatefulWidget {
  final UserTemplate user;

  const UserInfomationPage({super.key, required this.user});

  @override
  State<UserInfomationPage> createState() => _UserInfomationPageState();
}

class _UserInfomationPageState extends State<UserInfomationPage> {
  bool _isTerminating = false;

  Future<void> _showTerminateContractDialog() async {
    PlatformFile? selectedFile;
    String? fileError;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text(
              'ยืนยันการยกเลิกสัญญา',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('โปรดอัพโหลดเอกสารการยกเลิกสัญญา (PDF)'),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf'],
                          withData: true,
                        );

                    if (result != null) {
                      final file = result.files.first;
                      if (file.extension?.toLowerCase() != 'pdf') {
                        setDialogState(() {
                          fileError = 'กรุณาเลือกไฟล์ PDF เท่านั้น';
                          selectedFile = null;
                        });
                      } else if (file.size > 5 * 1024 * 1024) {
                        setDialogState(() {
                          fileError = 'ขนาดไฟล์ต้องไม่เกิน 5MB';
                          selectedFile = null;
                        });
                      } else {
                        setDialogState(() {
                          selectedFile = file;
                          fileError = null;
                        });
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selectedFile != null
                            ? AppColors.primary
                            : (fileError != null
                                  ? Colors.red
                                  : AppColors.border),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: selectedFile != null
                          ? AppColors.primary.withValues(alpha: 0.05)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selectedFile != null
                              ? Icons.description
                              : Icons.upload_file,
                          color: selectedFile != null
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            selectedFile?.name ?? 'คลิกเพื่อเลือกไฟล์ PDF',
                            style: TextStyle(
                              fontSize: 13,
                              color: selectedFile != null
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        if (selectedFile != null)
                          IconButton(
                            onPressed: () {
                              setDialogState(() {
                                selectedFile = null;
                              });
                            },
                            icon: const Icon(Icons.close, color: Colors.red),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                  ),
                ),
                if (fileError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4),
                    child: Text(
                      fileError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 12),
                const Text(
                  '* เมื่อยืนยันแล้ว สถานะห้องจะเปลี่ยนเป็นว่าง และบัญชีผู้เช่าจะถูกระงับทันที',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'ยกเลิก',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: selectedFile == null
                    ? null
                    : () async {
                        Navigator.pop(context); // ปิด dialog
                        await _processTermination(selectedFile!);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: const Text('ยืนยันยกเลิกสัญญา'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _processTermination(PlatformFile file) async {
    if (widget.user.contractId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ไม่พบเลขที่สัญญา')));
      return;
    }

    setState(() => _isTerminating = true);

    final response = await AdminServiceApi().terminateContract(
      widget.user.contractId!,
      file,
    );

    if (!mounted) return;
    setState(() => _isTerminating = false);

    if (response['status'] == 'success') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ยกเลิกสัญญาสำเร็จ')));
      context.pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'เกิดข้อผิดพลาด')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return Stack(
      children: [
        Scaffold(
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
        ),
        if (_isTerminating)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
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
          '${widget.user.firstname} ${widget.user.lastname}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.user.role == 'TENANT' ? 'ผู้เช่าพักอาศัย' : 'ผู้ดูแลระบบ',
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
        if (widget.user.roomNumber != null) ...[
          _buildInfoRow(
            'หมายเลขห้อง - ชั้น',
            'ห้อง ${widget.user.roomNumber} - ชั้น ${widget.user.floor ?? "-"}',
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
            _buildStatusBadge(widget.user.userStatus, true),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Divider(color: AppColors.divider, height: 1),
        ),
        _buildInfoRow(
          'เบอร์โทรศัพท์',
          widget.user.phone,
          Icons.phone_android_rounded,
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          'อีเมล',
          widget.user.email.isEmpty ? '-' : widget.user.email,
          Icons.email_outlined,
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          'ติดต่อฉุกเฉิน',
          (widget.user.emergencyPhone == null ||
                  widget.user.emergencyPhone!.isEmpty)
              ? '-'
              : widget.user.emergencyPhone!,
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
          '#${widget.user.contractNo ?? "-"}',
          Icons.description_outlined,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildRateItem(
              'ค่าเช่า/เดือน',
              widget.user.rateRoom,
              Icons.home_work_outlined,
            ),
            _buildRateItem(
              'ค่าน้ำ/หน่วย',
              widget.user.rateWater,
              Icons.water_drop_outlined,
            ),
            _buildRateItem(
              'ค่าไฟ/หน่วย',
              widget.user.rateElectric,
              Icons.bolt_rounded,
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(color: AppColors.divider, height: 1),
        const SizedBox(height: 20),
        _buildInfoRow(
          'วันที่เริ่มสัญญา',
          _formatThaiDate(widget.user.startDate),
          Icons.calendar_today_rounded,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          'วันที่สิ้นสุดสัญญา',
          _formatThaiDate(widget.user.endDate),
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
                '${Formatter.formatNumber(widget.user.deposit)} บาท',
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (widget.user.contractStatus.toUpperCase() == 'ACTIVE') ...[
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showTerminateContractDialog,
              icon: const Icon(Icons.cancel_outlined),
              label: const Text(
                'ยกเลิกสัญญาเช่า',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red.shade700,
                elevation: 0,
                side: BorderSide(color: Colors.red.shade100),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
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
          Formatter.formatNumber(rate),
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
