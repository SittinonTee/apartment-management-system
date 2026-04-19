import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/services/auth_service.dart';
import 'package:provider/provider.dart';
import '../../data/repair_model.dart';
import '../widgets/repair_detail_row.dart';
import '../widgets/accept_job_dialog.dart';

class TechnicianRepairDetailPage extends StatefulWidget {
  final RepairRequest repair;

  const TechnicianRepairDetailPage({super.key, required this.repair});

  @override
  State<TechnicianRepairDetailPage> createState() =>
      _TechnicianRepairDetailPageState();
}

class _TechnicianRepairDetailPageState
    extends State<TechnicianRepairDetailPage> {
  bool _isLoading = false;
  final Dio _dio = Dio();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    _buildInfoSection(),
                    const SizedBox(height: 16),
                    _buildImageSection(),
                    const SizedBox(height: 16),
                    _buildTenantSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            if (widget.repair.status == 'REPORTED') _buildBottomAction(context),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันส่งข้อมูลรับงานไปหลังบ้าน
  Future<void> _handleAcceptJob(DateTime scheduledDate) async {
    final technicianId = context.read<AuthService>().userId ?? 1;
    setState(() => _isLoading = true);

    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/technicians/accept',
        data: {
          'repairId': widget.repair.id,
          'technicianId': technicianId,
          'scheduledAt': scheduledDate.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        // ปิด Popup นัดหมาย
        Navigator.pop(context);

        // แสดงข้อความสำเร็จ
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('รับงานสำเร็จแล้ว! ตรวจสอบที่หน้า "รับงานแล้ว"'),
            backgroundColor: Colors.green,
          ),
        );

        // กลับไปหน้า List งาน
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircleButton(Icons.close, () => Navigator.pop(context)),
          const Text(
            'รายละเอียดการแจ้งซ่อม',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
          side: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
    );
  }

  // --- ข้อมูลสถานะและห้อง ---
  Widget _buildInfoSection() {
    return SectionCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          RepairDetailRow(
            label: 'สถานะ :',
            value: Row(
              children: [
                Icon(
                  Icons.radio_button_checked,
                  size: 14,
                  color: widget.repair.statusTextColor,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.repair.statusText,
                  style: TextStyle(
                    color: widget.repair.statusTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          RepairDetailRow(
            label: 'ห้อง :',
            value: Text(
              '${widget.repair.roomNumber ?? '-'} ชั้น ${widget.repair.roomFloor ?? '-'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          RepairDetailRow(
            label: 'รายละเอียด :',
            value: Text(
              widget.repair.description.isEmpty
                  ? '-'
                  : widget.repair.description,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          RepairDetailRow(
            label: 'วันที่แจ้ง :',
            value: const Text(
              '19 พ.ค. 69 | 14:30 น.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  // --- กล่องรูปภาพประกอบ ---
  Widget _buildImageSection() {
    final hasImage =
        widget.repair.repairsImageUrl != null &&
        widget.repair.repairsImageUrl!.isNotEmpty;

    return SectionCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'รูปภาพประกอบ :',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (hasImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                widget.repair.repairsImageUrl!,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.grey,
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ไม่มีรูปภาพประกอบ',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // --- ข้อมูลผู้เช่า ---
  Widget _buildTenantSection() {
    return SectionCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          RepairDetailRow(
            label: 'ผู้เช่า :',
            value: Text(
              '${widget.repair.tenantName ?? '-'} (${widget.repair.tenantPhone ?? '-'})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          RepairDetailRow(
            label: 'วันที่สะดวก :',
            value: Text(
              widget.repair.preferredTime ?? 'ไม่ระบุ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  // --- ปุ่มกดยืนยันด้านล่าง ---
  Widget _buildBottomAction(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: CustomButton(
        text: 'ยืนยันการรับงาน',
        height: 56,
        onPressed: () => _showAcceptJobDialog(context),
      ),
    );
  }

  void _showAcceptJobDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: !_isLoading,
      builder: (context) => AcceptJobDialog(
        repair: widget.repair,
        isLoading: _isLoading,
        onConfirm: _handleAcceptJob,
      ),
    );
  }
}
