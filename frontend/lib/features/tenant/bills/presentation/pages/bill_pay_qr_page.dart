import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/services/upload_service.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../data/bill_service.dart';

class BillPayQrPage extends StatefulWidget {
  final Map<String, dynamic> billData;

  const BillPayQrPage({super.key, required this.billData});

  @override
  State<BillPayQrPage> createState() => _BillPayQrPageState();
}

class _BillPayQrPageState extends State<BillPayQrPage> {
  PlatformFile? _selectedFile;
  bool _isUploading = false;

  void _showStatusDialog({
    required String title,
    required String message,
    required bool isSuccess,
    VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onConfirm != null) onConfirm();
            },
            child: const Text('ตกลง', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
      );

      if (result != null) {
        final file = result.files.first;
        
        // เช็คขนาดไฟล์หน้าบ้าน (5MB)
        if (file.size > 5 * 1024 * 1024) {
          if (mounted) {
            _showStatusDialog(
              title: 'ไฟล์ใหญ่เกินไป',
              message: 'ขนาดไฟล์ต้องไม่เกิน 5MB',
              isSuccess: false,
            );
          }
          return;
        }

        setState(() {
          _selectedFile = file;
        });
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
  }

  Future<void> _confirmPayment() async {
    if (_selectedFile == null) {
      _showStatusDialog(
        title: 'ข้อมูลไม่ครบ',
        message: 'กรุณาอัปโหลดสลิปเพื่อยืนยันการชำระเงิน',
        isSuccess: false,
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final billId = int.tryParse(widget.billData['bills_id']?.toString() ?? '0') ?? 0;
      
      // อัปโหลดไฟล์ขึ้น Firebase ผ่าน Backend
      final slipUrl = await UploadService().uploadFile(_selectedFile!, folder: 'slips');
      
      if (slipUrl == null) {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
          _showStatusDialog(
            title: 'อัปโหลดล้มเหลว',
            message: 'ไม่สามารถอัปโหลดไฟล์ได้ กรุณาตรวจสอบประเภทไฟล์และลองใหม่อีกครั้ง',
            isSuccess: false,
          );
        }
        return;
      }

      // ค่อยนำ URL ที่ได้มา บันทึกกระบวนการจ่ายเงิน
      final success = await BillService().processPayment(billId, slipUrl);

      if (mounted) {
        if (success) {
          _showStatusDialog(
            title: 'สำเร็จ',
            message: 'บันทึกการชำระเงินเรียบร้อยแล้ว ระบบจะนำคุณกลับสู่หน้าหลัก',
            isSuccess: true,
            onConfirm: () => Navigator.of(context).pop(true),
          );
        } else {
          setState(() {
            _isUploading = false;
          });
          _showStatusDialog(
            title: 'ผิดพลาด',
            message: 'เกิดข้อผิดพลาดในการบันทึกข้อมูลสัญญาสู่ฐานข้อมูล',
            isSuccess: false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        _showStatusDialog(
          title: 'เกิดข้อผิดพลาด',
          message: e.toString(),
          isSuccess: false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(widget.billData['grand_total']?.toString() ?? '0') ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ชำระเงิน', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('ยอดที่ต้องชำระ', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} บาท',
              style: const TextStyle(color: AppColors.primary, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            // QR Code Placeholder
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Image.network(
                    'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=PROMPTPAY_PAYMENT_LINK_MOCK',
                    height: 200,
                    width: 200,
                  ),
                  const SizedBox(height: 12),
                  const Text('Scan QR เพื่อชำระเงิน', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Upload Section
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    if (_selectedFile == null) ...[
                      const Icon(Icons.cloud_upload_outlined, size: 48, color: AppColors.primary),
                      const SizedBox(height: 12),
                      const Text(
                        'แตะเพื่ออัปโหลดสลิป (JPG, PNG, PDF)',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      const Text(
                        'ขนาดไฟล์ไม่เกิน 5MB',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ] else ...[
                      // แสดง Preview ถ้าเป็นรูปภาพ
                      if (_selectedFile!.extension?.toLowerCase() != 'pdf')
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: kIsWeb
                              ? Image.memory(
                                  _selectedFile!.bytes!,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                )
                              : Image.file(
                                  File(_selectedFile!.path!),
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                ),
                        )
                      else
                        // แสดงไอคอนถ้าเป็น PDF
                        Column(
                          children: [
                            const Icon(Icons.picture_as_pdf, size: 64, color: Colors.red),
                            const SizedBox(height: 8),
                            Text(
                              _selectedFile!.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      const SizedBox(height: 12),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 20),
                          SizedBox(width: 8),
                          Text('เลือกไฟล์เรียบร้อย', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            _isUploading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : CustomButton(
                    text: 'ยืนยันการชำระเงิน',
                    onPressed: _confirmPayment,
                  ),
          ],
        ),
      ),
    );
  }
}
