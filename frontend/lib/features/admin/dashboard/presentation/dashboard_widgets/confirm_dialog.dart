import 'dart:math';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/utils/formatter.dart';
import 'package:frontend/core/widgets/custom_button.dart';
import 'package:intl/intl.dart';

class ConfirmDialog extends StatefulWidget {
  final Map<String, dynamic> personalInfo;
  final Map<String, dynamic> contractInfo;
  final Function(Map<String, dynamic> generatedData) onConfirm;
  final VoidCallback onCancel;

  const ConfirmDialog({
    super.key,
    required this.personalInfo,
    required this.contractInfo,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  // ใช้ค่าเริ่มต้นแทน late เพื่อกัน LateInitializationError
  String _inviteCode = '';
  String _contractNo = '';
  String _idKeycard = '';

  // ตัวส่ง backend (yyyy-MM-dd)
  String _formattedStartDate = '';
  String _formattedEndDate = '';

  // ตัวโชว์ (dd/MM/yyyy)
  String _displayStartDate = '-';
  String _displayEndDate = '-';

  @override
  void initState() {
    super.initState();
    _generateData();
  }

  void _generateData() {
    // 1. Generate Invite Code (6 chars uppercase)
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    _inviteCode = String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );

    // 2. Generate Contract No (Year + 3 digits)
    final year = DateTime.now().year;
    final randomDigits = 100 + rnd.nextInt(900); // 100-999
    _contractNo = '$year$randomDigits';

    // 3. Format dates
    final start = widget.contractInfo['start_date'];
    final end = widget.contractInfo['end_date'];

    _formattedStartDate = _formatDate(start, 'yyyy-MM-dd');
    _formattedEndDate = _formatDate(end, 'yyyy-MM-dd');

    // แสดงผลบนหน้าจอเป็น พ.ศ.
    _displayStartDate = _formatDateBE(start, 'dd/MM/yyyy');
    _displayEndDate = _formatDateBE(end, 'dd/MM/yyyy');

    // 4 ID_keycard
    final randomPart = String.fromCharCodes(
      Iterable.generate(3, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
    _idKeycard = 'KC-$year-$randomPart';
  }

  String _formatDate(dynamic date, String pattern) {
    if (date == null) return '-';
    try {
      DateTime dt;
      if (date is DateTime) {
        dt = date;
      } else {
        dt = DateTime.parse(date.toString());
      }
      return DateFormat(pattern).format(dt);
    } catch (e) {
      return date.toString();
    }
  }

  String _formatDateBE(dynamic date, String pattern) {
    if (date == null) return '-';
    try {
      DateTime dt;
      if (date is DateTime) {
        dt = date;
      } else {
        dt = DateTime.parse(date.toString());
      }
      // แปลงปีเป็น พ.ศ.
      final dtBE = DateTime(
        dt.year + 543,
        dt.month,
        dt.day,
        dt.hour,
        dt.minute,
        dt.second,
      );
      return DateFormat(pattern).format(dtBE);
    } catch (e) {
      return date.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    // key : value ใช้ map ออกมาตอนเข้า _buildInfoTable
    final Map<String, String> displayPersonalInfo = {
      'ชื่อ-นามสกุล':
          '${widget.personalInfo['firstname']} ${widget.personalInfo['lastname']}',
      'เบอร์โทรศัพท์': widget.personalInfo['phone'],
      'รหัสเชิญ': _inviteCode,
      'รหัสคีย์การ์ด': _idKeycard,
      'ติดต่อฉุกเฉิน': widget.personalInfo['emergency_phone'] != ""
          ? widget.personalInfo['emergency_phone']
          : '-',
    };

    // key : value ใช้ map ออกมาตอนเข้า _buildInfoTable
    final Map<String, String> displayContractInfo = {
      'เลขที่สัญญา': _contractNo,
      'ห้องพัก': widget.contractInfo['room_name'],
      'วันที่เริ่มสัญญา': _displayStartDate,
      'วันที่สิ้นสุด': _displayEndDate,
      'เงินประกัน':
          '${Formatter.formatNumber(widget.contractInfo['deposit'])} บาท',
    };

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 24,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.assignment_turned_in,
                      color: Colors.white,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'ยืนยันการสร้างสัญญา',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'โปรดตรวจสอบรายละเอียดให้ถูกต้องก่อนดำเนินการต่อ',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildSectionHeader(
                      context,
                      'ข้อมูลผู้เช่า',
                      Icons.person_outline,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoTable(displayPersonalInfo),

                    const SizedBox(height: 24),

                    _buildSectionHeader(
                      context,
                      'รายละเอียดสัญญาเช่า',
                      Icons.description_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoTable(displayContractInfo),

                    const SizedBox(height: 32),

                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'ย้อนกลับ',
                            isOutlined: true,
                            onPressed: widget.onCancel,
                            height: 52,
                            textStyle: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomButton(
                            text: 'ยืนยันข้อมูล',
                            onPressed: () {
                              widget.onConfirm({
                                'invite_code': _inviteCode,
                                'contract_no': _contractNo,
                                'id_keycard': _idKeycard,
                                'start_date': _formattedStartDate,
                                'end_date': _formattedEndDate,
                              });
                            },
                            height: 52,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTable(Map<String, String> info) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: info.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
