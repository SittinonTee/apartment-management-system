import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';

import 'package:frontend/features/admin/packages/data/admin_packages_provider.dart';

class AdminPackagesAdd extends StatefulWidget {
  const AdminPackagesAdd({super.key});

  @override
  State<AdminPackagesAdd> createState() => _AdminPackagesAddState();
}

class _AdminPackagesAddState extends State<AdminPackagesAdd> {
  final _roomController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _roomController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_roomController.text.trim().isEmpty ||
        _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final errorMessage = await AdminPackagesProvider().addParcel({
      "room_number": _roomController.text.trim(),
      "name": _nameController.text.trim(),
      "parcelsimage_url": "", // สามารถเพิ่มฟังก์ชันอัปโหลดรูปในอนาคต
    });

    setState(() => _isLoading = false);

    if (errorMessage == null && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('สำเร็จ'),
          content: const Text('เพิ่มพัสดุเรียบร้อยแล้ว'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // ปิด Dialog
                Navigator.pop(context); // ปิดหน้าเพิ่มพัสดุ
              },
              child: const Text('ตกลง'),
            ),
          ],
        ),
      );
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('ข้อผิดพลาด'),
            content: Text(
              errorMessage ?? 'เพิ่มพัสดุไม่สำเร็จ ลองใหม่อีกครั้ง',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ตกลง'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                children: [
                  // ===== HEADER =====
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            "เพิ่มรายการพัสดุ",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ===== UPLOAD BOX ===== ตย
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "อัพโหลดรูปพัสดุ",
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ===== FORM =====
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(20, 0, 0, 0),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "ข้อมูลพัสดุ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 12),

                        // ห้อง
                        const Text("เลขห้องพัก"),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _roomController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ชื่อ
                        const Text("ชื่อผู้รับ"),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),

                        // (ในตัวอย่างเดิมมีช่อง 'เวลาเข้ารับ' ตรงนี้ลบออกเพราะ Backend ให้ Default เวลาปัจจุบันให้อัตโนมัติเวลาแอดมินกดเพิ่ม)
                        const SizedBox(height: 20),

                        // ===== BUTTON =====
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  _roomController.clear();
                                  _nameController.clear();
                                },
                                child: const Text("เคลียร์"),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                ),
                                onPressed: _isLoading ? null : _submit,
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text("ยืนยัน"),
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
        ),
      ),
    );
  }
}
