import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/services/upload_service.dart';

import 'package:frontend/features/admin/packages/data/admin_packages_provider.dart';
import 'package:frontend/features/admin/dashboard/data/get_vailable_room.dart';
import 'package:frontend/features/admin/dashboard/data/room_manage_api.dart';
import 'package:frontend/features/admin/dashboard/presentation/dashboard_widgets/custom_dropdown_menu.dart';

class AdminPackagesAdd extends StatefulWidget {
  const AdminPackagesAdd({super.key});

  @override
  State<AdminPackagesAdd> createState() => _AdminPackagesAddState();
}

class _AdminPackagesAddState extends State<AdminPackagesAdd> {
  final _roomController = TextEditingController();
  final _nameController = TextEditingController();
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  String? _selectedRoomId;
  List<RoomTemplate> _occupiedRooms = [];

  @override
  void initState() {
    super.initState();
    _fetchOccupiedRooms();
  }

  Future<void> _fetchOccupiedRooms() async {
    final allRooms = await RoomManageApi().getAllRooms();
    if (!mounted) return;
    setState(() {
      _occupiedRooms = allRooms
          .where((r) => r['room_status'] == 'OCCUPIED')
          .map((r) => RoomTemplate.fromJson(r))
          .toList();
    });
  }

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

  @override
  void dispose() {
    _roomController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_selectedRoomId == null ||
        _selectedRoomId!.isEmpty ||
        _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
      );
      return;
    }

    setState(() => _isLoading = true);

    String parcelsImageUrl = "";
    if (_selectedImage != null) {
      final url = await UploadService().uploadImage(
        _selectedImage!,
        folder: 'packages',
      );
      if (url == null) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('อัพโหลดรูปล้มเหลว กรุณาลองใหม่')),
          );
        }
        return;
      }
      parcelsImageUrl = url;
    }

    final selectedRoom = _occupiedRooms.firstWhere(
      (room) => room.id == _selectedRoomId,
      orElse: () => RoomTemplate(id: '', roomNumber: ''),
    );

    final errorMessage = await AdminPackagesProvider().addParcel({
      "room_number": selectedRoom.roomNumber,
      "name": _nameController.text.trim(),
      "parcelsimage_url": parcelsImageUrl,
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

                  // ===== UPLOAD BOX =====
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: _selectedImage == null
                          ? const Center(
                              child: Text(
                                "อัพโหลดรูปพัสดุ",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                ),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: kIsWeb
                                  ? Image.network(
                                      _selectedImage!.path,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(_selectedImage!.path),
                                      fit: BoxFit.cover,
                                    ),
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
                        CustomDropdownMenu<String>(
                          label: 'เลขห้อง',
                          hintText: 'เลือกเลขห้อง',
                          controller: _roomController,
                          enableFilter: true,
                          requestFocusOnTap: true,
                          validator: (value) {
                            if (_selectedRoomId == null ||
                                _selectedRoomId!.isEmpty) {
                              return 'กรุณาเลือกเลขห้องพัก';
                            }
                            return null;
                          },
                          dropdownMenuEntries: _occupiedRooms.isEmpty
                              ? [
                                  DropdownMenuEntry<String>(
                                    value: '',
                                    enabled: false,
                                    label: 'ไม่พบห้องที่มีผู้เช่า',
                                    labelWidget: Text(
                                      'ไม่พบห้องที่มีผู้เช่า',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ),
                                ]
                              : _occupiedRooms.map((room) {
                                  return DropdownMenuEntry<String>(
                                    value: room.id,
                                    label: 'ห้อง ${room.roomNumber}',
                                    labelWidget: Text(
                                      'ห้อง ${room.roomNumber}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  );
                                }).toList(),
                          onSelected: (roomId) {
                            setState(() {
                              _selectedRoomId = roomId;
                            });
                          },
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
                                  setState(() {
                                    _selectedRoomId = null;
                                  });
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
