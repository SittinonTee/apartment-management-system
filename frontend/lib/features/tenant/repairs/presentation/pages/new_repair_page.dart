import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/features/tenant/repairs/data/get_repairs.dart';
import 'package:frontend/features/tenant/repairs/data/repair_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/widgets/custom_text_field.dart';
import 'package:frontend/core/services/upload_service.dart';

/// หน้าจอนี้ใช้สำหรับให้ผู้เช่าส่งคำร้องแจ้งซ่อมใหม่
/// โดยมีแบบฟอร์มให้กรอกข้อมูลต่างๆ เช่น บ้านเลขที่, อาคาร, ชั้นห้อง,
/// ประเภทงานซ่อม, หัวข้อ, รายละเอียด และเบอร์โทรศัพท์ติดต่อกลับ
class NewRepairPage extends StatefulWidget {
  const NewRepairPage({super.key});

  @override
  State<NewRepairPage> createState() => _NewRepairPageState();
}

class _NewRepairPageState extends State<NewRepairPage> {
  // ใช้สำหรับการตรวจสอบความถูกต้อง (Validate) ของ Form
  final _formKey = GlobalKey<FormState>();

  // ---------------- Controllers ---------------- //
  // ใช้สำหรับควบคุมและดึงข้อความจากช่องกรอกข้อมูลต่างๆ
  final _houseNumberController = TextEditingController();
  final _titleController =
      TextEditingController(); // ควบคุมช่อง "หัวข้อแจ้งซ่อม"
  final _descriptionController =
      TextEditingController(); // ควบคุมช่อง "รายละเอียด"
  final _phoneController =
      TextEditingController(); // ควบคุมช่อง "เบอร์โทรศัพท์"
  final _preferredTimeController =
      TextEditingController(); // ควบคุมช่อง "ช่วงเวลาที่สะดวก"

  // เก็บ ID ของประเภทงานซ่อมที่ถูกเลือก โดยส่งประเภทเริ่มต้นเป็น 2 (ไฟฟ้า)
  int _selectedCategoryId = 1;

  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  // ---------------- Controllers ---------------- //

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    // ล้างค่า Controller ทิ้งเมื่อหน้าจอนี้ถูกทำลาย/ปิดทิ้งไปแล้ว
    _houseNumberController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _preferredTimeController.dispose();
    super.dispose();
  }

  List<CategoryModel> _categories = [];
  String? _error;

  Future<void> _loadCategories() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getToken();

      if (token == null) {
        if (mounted) {
          setState(() {
            _error = 'กรุณาเข้าสู่ระบบใหม่';
          });
        }
        return;
      }

      final categories = await GetRepairs().getCategories(token);

      if (mounted) {
        setState(() {
          _categories = categories;
          // ถ้ามี categories ให้เลือกอันแรกเป็น default หรือถ้ามี ID 2 (ไฟฟ้า) ให้เลือกอันนั้น
          if (_categories.isNotEmpty) {
            final hasDefault = _categories.any((c) => c.categoryId == 2);
            if (hasDefault) {
              _selectedCategoryId = 1;
            } else {
              _selectedCategoryId = _categories.first.categoryId;
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
      if (mounted) {
        setState(() {
          _error = 'ไม่สามารถโหลดข้อมูลประเภทงานซ่อมได้';
        });
      }
    }
  }

  // ----------------------------------- ฟังก์ชันกดปุ่ม ยืนยัน" ---------------------------------//
  Future<void> _submitRepair() async {
    if (_formKey.currentState?.validate() ?? false) {
      // แสดง Loading Dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        final token = await authService.getToken();

        if (token == null) {
          if (mounted) Navigator.pop(context); // Close loading
          throw Exception('Token not found');
        }

        List<String> imageUrls = [];
        if (_selectedImages.isNotEmpty) {
          for (var image in _selectedImages) {
            final url = await UploadService().uploadImage(
              image,
              folder: 'repairs',
            );
            if (url != null) {
              imageUrls.add(url);
            }
          }

          if (imageUrls.length != _selectedImages.length) {
            if (mounted) {
              Navigator.pop(context); // Close loading
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('อัพโหลดรูปภาพบางส่วนล้มเหลว'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
            return;
          }
        }

        final repairsImageUrlJson = imageUrls.isNotEmpty
            ? jsonEncode(imageUrls)
            : null;

        final success = await GetRepairs().createRepairRequest(
          token: token,
          categoryId: _selectedCategoryId,
          title: _titleController.text,
          description: _descriptionController.text,
          preferredTime: _preferredTimeController.text.isEmpty
              ? 'ไม่ระบุ'
              : _preferredTimeController.text,
          imageUrl: repairsImageUrlJson,
        );

        if (mounted) Navigator.pop(context); // Close loading

        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('บันทึกข้อมูลเรียบร้อย'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context, true); // กลับหน้าหลักและแจ้งให้รีเฟรช
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('เกิดข้อผิดพลาดในการบันทึกข้อมูล'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) Navigator.pop(context); // Close loading
        debugPrint('Error submitting repair: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('เกิดข้อผิดพลาด: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
  // ----------------------------------- ฟังก์ชันกดปุ่ม ยืนยัน" ---------------------------------//

  // ----------------------------------- Widget ย่อยสำหรับสร้างหัวข้อด้านบนของช่องกรอกต่างๆ (Label) ---------------------------------//
  Widget _buildLabel(String text, {bool isRequired = false, String? counter}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          children: [
            TextSpan(text: text),
            if (counter != null)
              TextSpan(
                text: ' ($counter)',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
  // ----------------------------------- Widget ย่อยสำหรับสร้างหัวข้อด้านบนของช่องกรอกต่างๆ (Label) ---------------------------------//

  // Widget ย่อยสำหรับส่วนการเลือกรูปภาพ
  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('แนบรูปภาพประกอบ'),
        const Text(
          'สามารถแนบรูปภาพเพื่อช่วยให้ช่างเข้าใจปัญหาได้ชัดเจนขึ้น',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildAddImageButton(),
              ..._selectedImages.asMap().entries.map((entry) {
                int index = entry.key;
                XFile image = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: kIsWeb
                              ? Image.network(image.path, fit: BoxFit.cover)
                              : Image.file(File(image.path), fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImages.removeAt(index);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // ----------------------------------- Widget สำหรับปุ่มเพิ่มรูปภาพ (Add Button) ---------------------------------//
  Widget _buildAddImageButton() {
    return InkWell(
      onTap: _pickImages,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              color: AppColors.primary,
              size: 30,
            ),
            SizedBox(height: 4),
            Text(
              'เพิ่มรูปภาพ',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  // ----------------------------------- Widget สำหรับปุ่มเพิ่มรูปภาพ (Add Button) ---------------------------------//

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
        title: const Text(
          'เพิ่มรายการแจ้งซ่อม',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  _buildLabel('ประเภทงานซ่อม', isRequired: true),
                  if (_error != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                    )
                  else
                    DropdownButtonFormField<int>(
                      initialValue: _selectedCategoryId,
                      items: _categories.map((category) {
                        return DropdownMenuItem<int>(
                          value: category.categoryId,
                          child: Text(
                            category.categoryName,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'เลือกประเภทงานซ่อม',
                        hintStyle: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      isExpanded: true,
                      isDense: true,
                      validator: (value) {
                        if (value == null) {
                          return 'กรุณาเลือกประเภทงานซ่อม';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    labelText: 'หัวข้อการแจ้งซ่อม',
                    controller: _titleController,
                    hintText: 'พิมพ์หัวข้อการแจ้งซ่อม',
                    isRequired: true,
                    maxLength: 100,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    labelText: 'รายละเอียด',
                    controller: _descriptionController,
                    hintText: 'พิมพ์รายละเอียดการแจ้งซ่อม',
                    isRequired: true,
                    maxLines: 4,
                    buildCounter:
                        (
                          context, {
                          required currentLength,
                          required isFocused,
                          required maxLength,
                        }) => null,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    labelText: 'เบอร์โทรสำหรับติดต่อกลับ',
                    controller: _phoneController,
                    hintText: 'พิมพ์เบอร์โทรศัพท์',
                    isRequired: true,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (value) {
                      if (value != null && value.length != 10) {
                        return 'กรุณากรอกเบอร์โทรศัพท์ให้ครบ 10 หลัก';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    labelText: 'ช่วงเวลาที่สะดวกให้ช่างเข้า',
                    controller: _preferredTimeController,
                    hintText: 'เช่น พรุ่งนี้ 10:00 หรือ ทุกเย็นวันศุกร์',
                  ),
                  const SizedBox(height: 24),

                  // ส่วนของการเพิ่มรูปภาพ
                  _buildImagePicker(),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitRepair,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF76C4C6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'ยืนยัน',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
