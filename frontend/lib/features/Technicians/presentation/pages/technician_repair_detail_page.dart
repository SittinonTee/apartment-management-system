import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/widgets/section_card.dart';
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
                    const SizedBox(height: 16),
                    _buildMechanicSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBottomAction(context),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันอัปเดตสถานะทั่วไป
  Future<void> _updateStatus(String status, {String? remark}) async {
    setState(() => _isLoading = true);
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/technicians/status',
        data: {
          'repairId': widget.repair.id,
          'status': status,
          'remark': remark ?? '',
        },
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'อัปเดตสถานะเป็น ${status == 'PENDING' ? 'เตรียมอุปกรณ์' : status} เรียบร้อยแล้ว',
            ),
            backgroundColor: Colors.green,
          ),
        );
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
      if (mounted) setState(() => _isLoading = false);
    }
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
            content: Text('รับงานสำเร็จแล้ว! ตรวจสอบที่หน้า "รายการงาน"'),
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
          if (widget.repair.status != 'REPORTED' &&
              widget.repair.mechanicName != null)
            RepairDetailRow(
              label: 'ช่างรับผิดชอบ :',
              value: Text(
                widget.repair.mechanicName!,
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

  // --- ข้อมูลช่างผู้รับงาน ---
  Widget _buildMechanicSection() {
    return SectionCard(
      padding: const EdgeInsets.all(20),
      child: RepairDetailRow(
        label: 'ช่างผู้รับงาน :',
        value: Text(
          widget.repair.mechanicName ?? 'รอมอบหมาย',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        showDivider: false,
      ),
    );
  }

  // --- ปุ่มกดยืนยันด้านล่าง ---
  Widget _buildBottomAction(BuildContext context) {
    if (widget.repair.status == 'COMPLETED' ||
        widget.repair.status == 'CANCELLED') {
      return const SizedBox.shrink();
    }

    if (widget.repair.status == 'REPORTED') {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: ElevatedButton(
          onPressed: _isLoading ? null : () => _showAcceptJobDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'ยืนยันการรับงาน',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      );
    }

    // กรณีสถานะ ASSIGNED, PENDING
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // ปุ่มเตรียมอุปกรณ์ (Orange)
              Expanded(
                child: ElevatedButton(
                  onPressed: (_isLoading || widget.repair.status == 'PENDING') ? null : () => _updateStatus('PENDING'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2994A), // Orange
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'เตรียมอุปกรณ์',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // ปุ่มยกเลิก (Red)
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : () => _updateStatus('CANCELLED'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEB5757), // Red
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'ยกเลิก',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ปุ่มเสร็จสิ้น (Green)
          ElevatedButton(
            onPressed: _isLoading ? null : () => _updateStatus('COMPLETED'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27AE60), // Green
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'เสร็จสิ้น',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
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
