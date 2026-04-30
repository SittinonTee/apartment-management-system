import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/widgets/custom_button.dart';
import 'package:frontend/core/widgets/custom_text_field.dart';
import 'package:frontend/core/widgets/searchbar.dart';
import 'package:frontend/features/admin/dashboard/presentation/dashboard_widgets/users_info_card.dart';
import 'package:frontend/features/admin/dashboard/data/room_manage_api.dart';

class RoomManageTab extends StatefulWidget {
  final List<Map<String, dynamic>> rooms;
  final bool isLoading;
  final VoidCallback onRefresh;

  const RoomManageTab({
    super.key,
    required this.rooms,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  State<RoomManageTab> createState() => _RoomManageTabState();
}

class _RoomManageTabState extends State<RoomManageTab> {
  String _roomSearchQuery = '';

  void _showAddRoomDialog() {
    final TextEditingController roomNoController = TextEditingController();
    final TextEditingController floorController = TextEditingController();
    String? roomNoError;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text(
                'เพิ่มห้องพักใหม่',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    labelText: 'หมายเลขห้อง',
                    controller: roomNoController,
                    onChanged: (value) =>
                        setStateDialog(() => roomNoError = null),
                  ),
                  if (roomNoError != null)
                    Text(
                      roomNoError!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    labelText: 'ชั้น (Floor)',
                    controller: floorController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('ยกเลิก'),
                ),
                CustomButton(
                  text: 'บันทึก',
                  width: 100,
                  onPressed: () async {
                    final roomNo = roomNoController.text.trim();
                    final floor =
                        int.tryParse(floorController.text.trim()) ?? 0;
                    if (roomNo.isEmpty || floor == 0) return;

                    // เช็คแบบ frontend ไปเลย
                    final isDuplicate = widget.rooms.any(
                      (r) =>
                          r['room_number'].toString().toLowerCase() ==
                          roomNo.toLowerCase(),
                    );

                    if (isDuplicate) {
                      setStateDialog(
                        () => roomNoError = 'หมายเลขห้องนี้มีอยู่แล้วในระบบ',
                      );
                      return;
                    }

                    final result = await RoomManageApi().addRoom({
                      'room_number': roomNo,
                      'floor': floor,
                    });
                    if (result['status'] == 'success') {
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                      if (mounted) {
                        widget.onRefresh();
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditRoomDialog(Map<String, dynamic> room) {
    final TextEditingController roomNoController = TextEditingController(
      text: room['room_number'].toString(),
    );
    final TextEditingController floorController = TextEditingController(
      text: room['floor'].toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'แก้ไขรายละเอียดห้อง',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                labelText: 'หมายเลขห้อง',
                controller: roomNoController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                labelText: 'ชั้น (Floor)',
                controller: floorController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            CustomButton(
              text: 'บันทึก',
              width: 100,
              onPressed: () async {
                final roomId = int.tryParse(
                  room['room_id']?.toString() ?? room['id']?.toString() ?? '',
                );
                if (roomId == null) return;
                final result = await RoomManageApi().updateRoom(roomId, {
                  'room_number': roomNoController.text.trim(),
                  'floor': int.tryParse(floorController.text.trim()) ?? 0,
                });
                if (result['status'] == 'success') {
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                  if (mounted) {
                    widget.onRefresh();
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteRoom(Map<String, dynamic> room) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'ยืนยันการลบห้อง',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'คุณต้องการลบห้อง ${room['room_number']} ออกจากระบบใช่หรือไม่?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            CustomButton(
              text: 'ลบห้อง',
              width: 100,
              onPressed: () async {
                final roomId = int.tryParse(
                  room['room_id']?.toString() ?? room['id']?.toString() ?? '',
                );
                if (roomId == null) return;
                final result = await RoomManageApi().deleteRoom(roomId);
                if (result['status'] == 'success') {
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                  if (mounted) {
                    widget.onRefresh();
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredRooms = widget.rooms
        .where((r) => r['room_number'].toString().contains(_roomSearchQuery))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ห้องพักทั้งหมด',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            CustomButton(
              text: 'เพิ่มห้องพัก',
              icon: const Icon(Icons.add_circle_outline, size: 18),
              width: 120,
              height: 38,
              onPressed: _showAddRoomDialog,
            ),
          ],
        ),
        const SizedBox(height: 16),
        SearchWidget(
          onSearch: (value) => setState(() => _roomSearchQuery = value),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: filteredRooms.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final room = filteredRooms[index];
              final isVacant =
                  (room['room_status'] ?? 'AVAILABLE') == 'AVAILABLE';

              return CustomCard(
                height: 80,
                borderColor: AppColors.border,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.meeting_room_rounded,
                          color: isVacant
                              ? AppColors.success
                              : AppColors.primary,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ห้อง ${room['room_number']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'ชั้น ${room['floor']}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _showEditRoomDialog(room),
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _confirmDeleteRoom(room),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
