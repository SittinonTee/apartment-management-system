import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../data/repair_model.dart';

class TechnicianRepairHistoryDetailPage extends StatefulWidget {
  final RepairRequest repair;

  const TechnicianRepairHistoryDetailPage({super.key, required this.repair});

  @override
  State<TechnicianRepairHistoryDetailPage> createState() =>
      _TechnicianRepairHistoryDetailPageState();
}

class _TechnicianRepairHistoryDetailPageState
    extends State<TechnicianRepairHistoryDetailPage> {
  bool _isLoading = false;
  final Dio _dio = Dio();
  final TextEditingController _remarkController = TextEditingController();
  String? _remarkError;

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

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

  // ฟังก์ชันยกเลิกงานไปหลังบ้าน
  Future<void> _handleCancelJob() async {
    setState(() => _isLoading = true);

    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/technicians/status',
        data: {
          'repairId': widget.repair.id,
          'status': 'CANCELLED',
          'remark': _remarkController.text,
        },
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        // ปิด Popup ยืนยันยกเลิก
        Navigator.pop(context);

        // แสดงข้อความสำเร็จ
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ยกเลิกงานสำเร็จแล้ว!'),
            backgroundColor: Colors.green,
          ),
        );

        // กลับไปหน้า History
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

  // ฟังก์ชันเสร็จสิ้นงานไปหลังบ้าน
  Future<void> _handleCompleteJob() async {
    setState(() => _isLoading = true);

    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/technicians/status',
        data: {
          'repairId': widget.repair.id,
          'status': 'COMPLETED',
          'remark': _remarkController.text,
        },
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        // ปิด Popup ยืนยัน
        Navigator.pop(context);

        // แสดงข้อความสำเร็จ
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เสร็จสิ้นงานสำเร็จแล้ว!'),
            backgroundColor: Colors.green,
          ),
        );

        // กลับไปหน้า History
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

  // ฟังก์ชันเตรียมอุปกรณ์
  Future<void> _handlePrepareJob() async {
    setState(() => _isLoading = true);

    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/technicians/status',
        data: {'repairId': widget.repair.id, 'status': 'PENDING'},
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        Navigator.pop(context); // ปิด Popup
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('กำลังเตรียมอุปกรณ์'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // กลับไปหน้า History พร้อมรีเฟรช
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
          Expanded(
            child: Text(
              'รายละเอียดการแจ้งซ่อม',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 48), // Spacer to balance the close button
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
    final isPending = widget.repair.status == 'PENDING';

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isPending
                        ? null
                        : () => _showPrepareDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPending
                          ? AppColors.textHint
                          : AppColors.warning,
                      disabledBackgroundColor: isPending
                          ? AppColors.textHint
                          : AppColors.warning.withValues(alpha: 0.5),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'เตรียมอุปกรณ์',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _showCancelJobDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'ยกเลิก',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => _showCompleteJobDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'เสร็จสิ้น',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- แสดง Popup ยืนยันการเสร็จสิ้น ---
  void _showCompleteJobDialog(BuildContext context) {
    _remarkController.clear();
    _remarkError = null;
    showDialog(
      context: context,
      barrierDismissible: !_isLoading,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'ยืนยันการเสร็จสิ้น',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
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
                  const Text(
                    'คุณแน่ใจหรือไม่ว่าต้องการเสร็จสิ้นงานนี้?',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _remarkController,
                    onChanged: (value) {
                      if (_remarkError != null) {
                        setDialogState(() => _remarkError = null);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'รายละเอียดการเสร็จสิ้นงาน',
                      errorText: _remarkError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
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
                            'ไม่ใช่',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  if (_remarkController.text.trim().isEmpty) {
                                    setDialogState(() {
                                      _remarkError =
                                          'กรุณากรอกรายละเอียดการเสร็จสิ้นงาน';
                                    });
                                  } else {
                                    _handleCompleteJob();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            disabledBackgroundColor: AppColors.success
                                .withValues(alpha: 0.5),
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

  // --- แสดง Popup เตรียมอุปกรณ์ ---
  void _showPrepareDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: !_isLoading,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'ตรวจสอบงานเรียบร้อยแล้ว',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
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
                  const Text(
                    'คุณแน่ใจหรือไม่ว่าตรวจสอบงานเรียบร้อยแล้ว เข้าสู่ขั้นตอนการเตรียมอุปกรณ์?',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 32),
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
                            'ไม่ใช่',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () => _handlePrepareJob(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.warning,
                            disabledBackgroundColor: AppColors.warning
                                .withValues(alpha: 0.5),
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

  // --- แสดง Popup ยืนยันยกเลิก ---
  void _showCancelJobDialog(BuildContext context) {
    _remarkController.clear();
    _remarkError = null;
    showDialog(
      context: context,
      barrierDismissible: !_isLoading,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
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
                        'ยืนยันการยกเลิก',
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

                  const Text(
                    'คุณแน่ใจหรือไม่ว่าต้องการยกเลิกการรับงานนี้?',
                    style: TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 16),
                  TextField(
                    controller: _remarkController,
                    onChanged: (value) {
                      if (_remarkError != null) {
                        setDialogState(() => _remarkError = null);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'สาเหตุที่ยกเลิกการรับงาน',
                      errorText: _remarkError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

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
                            'ไม่ใช่',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  if (_remarkController.text.trim().isEmpty) {
                                    setDialogState(() {
                                      _remarkError =
                                          'กรุณากรอกสาเหตุที่ยกเลิกการรับงาน';
                                    });
                                  } else {
                                    _handleCancelJob();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            disabledBackgroundColor: Colors.redAccent
                                .withValues(alpha: 0.5),
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
                                  'ยกเลิกงาน',
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
