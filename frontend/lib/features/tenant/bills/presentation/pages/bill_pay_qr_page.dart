import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  XFile? _selectedImage;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _confirmPayment() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาอัปโหลดสลิปเพื่อยืนยันการชำระเงิน')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final billId = int.tryParse(widget.billData['bills_id']?.toString() ?? '0') ?? 0;
    
    // อัปโหลดไฟล์ขึ้น Firebase ผ่าน Backend
    final slipUrl = await UploadService().uploadImage(_selectedImage!, folder: 'slips');
    
    if (slipUrl == null) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('อัปโหลดสลิปไม่สำเร็จ กรุณาลองใหม่')),
        );
      }
      return;
    }

    // ค่อยนำ URL ที่ได้มา บันทึกกระบวนการจ่ายเงิน
    final success = await BillService().processPayment(billId, slipUrl);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกการชำระเงินเรียบร้อยแล้ว')),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เกิดข้อผิดพลาดในการบันทึกข้อมูล')),
        );
        setState(() {
          _isUploading = false;
        });
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
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    if (_selectedImage == null) ...[
                      const Icon(Icons.cloud_upload_outlined, size: 48, color: AppColors.primary),
                      const SizedBox(height: 12),
                      const Text(
                        'แตะเพื่ออัปโหลดสลิป',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ] else ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: kIsWeb
                            ? Image.network(
                                _selectedImage!.path,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.contain,
                              )
                            : Image.file(
                                File(_selectedImage!.path),
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.contain,
                              ),
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 20),
                          SizedBox(width: 8),
                          Text('เลือกรูปภาพเรียบร้อย', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
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
