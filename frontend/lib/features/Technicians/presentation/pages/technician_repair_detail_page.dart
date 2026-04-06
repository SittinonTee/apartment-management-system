import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../data/repair_model.dart';

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
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildInfoCard(context),
                    const SizedBox(height: 16),
                    _buildImageCard(context),
                    const SizedBox(height: 16),
                    _buildTenantCard(context),
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

  // ฟังก์ชันส่งข้อมูลรับงานไปหลังบ้าน
  Future<void> _handleAcceptJob(DateTime scheduledDate) async {
    setState(() => _isLoading = true);

    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/technicians/accept',
        data: {
          'repairId': widget.repair.id,
          'technicianId': 1, // Mock technician ID สำหรับทดสอบ
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

  // ส่วนหัว: ปุ่มปิด และหัวข้อ
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
                side: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
            ),
          ),
          const Text(
            'รายละเอียดการแจ้งซ่อม',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 48), // Spacer
        ],
      ),
    );
  }

  // กล่องข้อมูลงาน (สถานะ, เลขห้อง, รายละเอียด, วันที่)
  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF03A9F4).withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            'สถานะ :',
            Row(
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
          const Divider(height: 24, color: Color(0xFFF2F2F2)),
          _buildDetailRow(
            'ห้อง :',
            Text(
              '${widget.repair.roomNumber ?? '-'} ชั้น ${widget.repair.roomFloor ?? '-'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 24, color: Color(0xFFF2F2F2)),
          _buildDetailRow(
            'รายละเอียด :',
            Text(
              widget.repair.description.isEmpty
                  ? '-'
                  : widget.repair.description,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          const Divider(height: 24, color: Color(0xFFF2F2F2)),
          _buildDetailRow(
            'วันที่แจ้ง :',
            Text(
              '${widget.repair.date.day} พ.ค. 69 | 14:30 น.', // Mock เวลาตาม Figma
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  // กล่องรูปภาพประกอบ
  Widget _buildImageCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
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
          widget.repair.repairsImageUrl != null &&
                  widget.repair.repairsImageUrl!.isNotEmpty
              ? Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(widget.repair.repairsImageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      style: BorderStyle.solid,
                    ),
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

  // กล่องข้อมูลผู้เช่า
  Widget _buildTenantCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            'ผู้เช่า :',
            Text(
              '${widget.repair.tenantName ?? '-'} (${widget.repair.tenantPhone ?? '-'})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 24, color: Color(0xFFF2F2F2)),
          _buildDetailRow(
            'วันที่สะดวก :',
            Text(
              widget.repair.preferredTime ?? 'ไม่ระบุ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ปุ่มแอคชั่นด้านล่าง
  Widget _buildBottomAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () => _showAcceptJobDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5AB6A9),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'ยืนยันการรับงาน',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // --- แสดง Popup รายละเอียดการซ่อม ---
  void _showAcceptJobDialog(BuildContext context) {
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      barrierDismissible: !_isLoading,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Helper: แปลงวันที่เป็นไทย (วว ด.ด. ปปปป)
          String formatThaiDate(DateTime date) {
            final months = [
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
          }

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header และปุ่มปิด
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'รายละเอียดการซ่อม',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!_isLoading)
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ข้อมูลงาน
                  _buildPopupRow('ต้องการให้ :', widget.repair.title),
                  _buildPopupRow(
                    'ประเภท :',
                    widget.repair.categoryName ?? 'อื่นๆ',
                  ),
                  _buildPopupRow(
                    'ห้อง :',
                    '${widget.repair.roomNumber ?? '-'}  ชั้น: ${widget.repair.roomFloor ?? '-'}',
                  ),
                  _buildPopupRow('อาคาร :', 'A'), // Mock ตาม Figma
                  _buildPopupRow(
                    'สะดวกที่ :',
                    widget.repair.preferredTime ?? 'ไม่ระบุ',
                  ),
                  const SizedBox(height: 24),

                  // การเลือกวันที่
                  const Text(
                    'เลือกวันที่ที่จะเข้ามาทำงาน',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _isLoading
                        ? null
                        : () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(), // ห้ามเลือกย้อนหลัง
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Color(0xFF5AB6A9),
                                      onPrimary: Colors.white,
                                      onSurface: Colors.black,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setDialogState(() => selectedDate = picked);
                            }
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatThaiDate(selectedDate),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Icon(
                            Icons.calendar_month_outlined,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ปุ่มแอคชั่น
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Color(0xFFE0E0E0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'ยกเลิก',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () => _handleAcceptJob(selectedDate),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5AB6A9),
                            disabledBackgroundColor: const Color(
                              0xFF5AB6A9,
                            ).withValues(alpha: 0.5),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
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
                                  'ยืนยัน',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPopupRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, Widget value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(child: value),
      ],
    );
  }
}
