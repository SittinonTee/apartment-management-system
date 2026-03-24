import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/features/admin/dashboard/presentation/dashboard_widgets/users_info_card.dart';
import 'package:frontend/core/widgets/custom_text_field.dart';

class UserForm extends StatefulWidget {
  const UserForm({super.key});

  @override
  UserFormState createState() => UserFormState();
}

class UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();

  // ---------------- Controllers ----------------
  final _identityCardController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedFileName;

  // ---------------- validate ก่อนส่งข้อมูล ----------------
  bool validate() {
    return _formKey.currentState?.validate() ?? false;
  }

  @override
  void dispose() {
    _identityCardController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emergencyPhoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // ---------------- ดึงข้อมูลจาก form ไปใช้ใน API ----------------
  Map<String, dynamic> getRawData() {
    return {
      'firstname': _firstNameController.text.trim(),
      'lastname': _lastNameController.text.trim(),
      'identity_card': _identityCardController.text.trim(),
      'phone': _phoneController.text.trim(),
      'emergency_phone': _emergencyPhoneController.text.trim(),
      'address': _addressController.text.trim(),
    };
  }

  // ---------------- ดึงข้อมูลจาก form ไปใช้แสดงผล (Confirmation) ----------------
  Map<String, String> getData() {
    return {
      'ชื่อ-นามสกุล':
          '${_firstNameController.text} ${_lastNameController.text}',
      'เลขบัตรประชาชน': _identityCardController.text,
      'เบอร์โทรศัพท์': _phoneController.text,
      'เบอร์ติดต่อฉุกเฉิน': _emergencyPhoneController.text.isEmpty
          ? 'ไม่ได้ระบุ'
          : _emergencyPhoneController.text,
      'ที่อยู่': _addressController.text,
    };
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      height: null,
      shadow: true,
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomTextField(
                    isRequired: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Zก-๙]')),
                    ],
                    labelText: 'ชื่อจริง',
                    controller: _firstNameController,
                    hintText: 'เช่น สมชาย',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    isRequired: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Zก-๙]')),
                    ],
                    labelText: 'นามสกุล',
                    controller: _lastNameController,
                    hintText: 'เช่น ใจดี',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              isRequired: true,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(13),
              ],
              validator: (value) {
                if (value != null && value.length != 13) {
                  return 'เลขบัตรประชาชนต้องมี 13 หลัก';
                }
                return null;
              },
              labelText: 'เลขประจำตัวประชาชน',
              controller: _identityCardController,
              hintText: 'X-XXXX-XXXXX-XX-X',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              isRequired: true,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (value) {
                if (value != null && value.length != 10) {
                  return 'เบอร์โทรศัพท์ต้องมี 10 หลัก';
                }
                return null;
              },
              labelText: 'เบอร์โทรศัพท์',
              controller: _phoneController,
              hintText: '081-XXX-XXXX',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (value) {
                if (value != null && value.isNotEmpty && value.length != 10) {
                  return 'เบอร์โทรศัพท์ต้องมี 10 หลัก';
                }
                return null;
              },
              labelText: 'เบอร์ติดต่อฉุกเฉิน (*ไม่บังคับ)',
              controller: _emergencyPhoneController,
              hintText: '081-XXX-XXXX',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              isRequired: true,
              labelText: 'ที่อยู่',
              controller: _addressController,
              hintText:
                  'บ้านเลขที่, ถนน, ตำบล/แขวง, อำเภอ/เขต, จังหวัด, รหัสไปรษณีย์',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'ไฟล์ข้อมูลเพิ่มเติม (*ไม่บังคับ)',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                // TODO: เพิ่ม package 'file_picker' เพื่อใช้งานการอัพโหลดไฟล์จริง
                // setState(() { _selectedFileName = 'test_document.pdf'; });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.upload_file,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedFileName ?? 'อัพโหลดไฟล์ (PDF, JPG, PNG)',
                        style: TextStyle(
                          color: _selectedFileName != null
                              ? Theme.of(context).colorScheme.onSurface
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                    if (_selectedFileName != null)
                      const Icon(Icons.check_circle, color: Colors.green),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
