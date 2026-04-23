import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/widgets/custom_button.dart';
import 'package:frontend/core/widgets/custom_text_field.dart';
import 'package:frontend/features/admin/dashboard/presentation/dashboard_widgets/custom_dropdown_menu.dart';
import 'package:frontend/features/admin/dashboard/data/get_rate.dart';
import 'package:frontend/features/admin/dashboard/data/rate_manage_api.dart';
import 'package:frontend/features/admin/dashboard/data/room_manage_api.dart';
import 'package:frontend/core/widgets/searchbar.dart';
import 'package:frontend/features/admin/dashboard/presentation/dashboard_widgets/users_info_card.dart'; // From users_info_card.dart

class ManagePage extends StatefulWidget {
  const ManagePage({super.key});

  @override
  State<ManagePage> createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // -------- Rate Management State --------
  List<RateTemplate> _rates = [];
  final TextEditingController _rateSelectionController =
      TextEditingController();
  final TextEditingController _rateRoomController = TextEditingController();
  final TextEditingController _rateWaterController = TextEditingController();
  final TextEditingController _rateElectricController = TextEditingController();
  RateTemplate? _selectedRate;
  bool _isLoadingRates = false;

  // -------- Room Management State --------
  String _roomSearchQuery = '';
  List<Map<String, dynamic>> _rooms = [];
  bool _isLoadingRooms = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchRateData();
    _fetchRoomData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _rateSelectionController.dispose();
    _rateRoomController.dispose();
    _rateWaterController.dispose();
    _rateElectricController.dispose();
    super.dispose();
  }

  Future<void> _fetchRateData() async {
    setState(() => _isLoadingRates = true);
    final ratesData = await RateManageApi().getAllRates();
    if (!mounted) return;
    setState(() {
      _rates = ratesData.map((x) => RateTemplate.fromJson(x)).toList();
      _isLoadingRates = false;
    });
  }

  Future<void> _fetchRoomData() async {
    setState(() => _isLoadingRooms = true);
    final rooms = await RoomManageApi().getAllRooms();
    if (!mounted) return;
    setState(() {
      _rooms = rooms;
      _rooms.sort(
        (a, b) => naturalCompare(
          a['room_number'].toString().toUpperCase(),
          b['room_number'].toString().toUpperCase(),
        ),
      );
      _isLoadingRooms = false;
    });
  }

  void _onRateSelected(RateTemplate? rate) {
    if (rate != null) {
      setState(() {
        _selectedRate = rate;
        _rateRoomController.text = rate.rateRoom;
        _rateWaterController.text = rate.rateWater;
        _rateElectricController.text = rate.rateElectric;
      });
    }
  }

  void _showAddRateDialog() {
    final TextEditingController newRateRoomController = TextEditingController();
    final TextEditingController newRateWaterController =
        TextEditingController();
    final TextEditingController newRateElectricController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'เพิ่มเรทราคา',
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
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                labelText: 'ราคาเช่าห้องพัก',
                controller: newRateRoomController,
                keyboardType: TextInputType.number,
                suffixIcon: _buildRateFieldSuffix('บาท/เดือน'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                labelText: 'ค่าน้ำประปา',
                controller: newRateWaterController,
                keyboardType: TextInputType.number,
                suffixIcon: _buildRateFieldSuffix('บาท/หน่วย'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                labelText: 'ค่าไฟฟ้า',
                controller: newRateElectricController,
                keyboardType: TextInputType.number,
                suffixIcon: _buildRateFieldSuffix('บาท/หน่วย'),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'ยกเลิก',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            CustomButton(
              text: 'บันทึก',
              width: 100,
              height: 40,
              padding: const EdgeInsets.all(0),
              onPressed: () async {
                final rateRoom = newRateRoomController.text.trim();
                final rateWater = newRateWaterController.text.trim();
                final rateElectric = newRateElectricController.text.trim();

                if (rateRoom.isEmpty ||
                    rateWater.isEmpty ||
                    rateElectric.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
                  );
                  return;
                }

                final result = await RateManageApi().addRate({
                  'rate_room': rateRoom,
                  'rate_water': rateWater,
                  'rate_electric': rateElectric,
                });

                if (context.mounted) {
                  if (result['status'] == 'success') {
                    Navigator.pop(context);
                    _fetchRateData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('เพิ่มเรทราคาสำเร็จ')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['message'] ?? 'เกิดข้อผิดพลาด'),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildRateFieldSuffix(String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

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
                    onChanged: (value) {
                      if (roomNoError != null) {
                        setStateDialog(() => roomNoError = null);
                      }
                    },
                  ),
                  if (roomNoError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 4),
                      child: Text(
                        roomNoError!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                        ),
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
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'ยกเลิก',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                CustomButton(
                  text: 'บันทึก',
                  width: 100,
                  height: 40,
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    final roomNo = roomNoController.text.trim();
                    final floor =
                        int.tryParse(floorController.text.trim()) ?? 0;

                    setStateDialog(() => roomNoError = null);

                    if (roomNo.isEmpty || floor == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('กรุณากรอกข้อมูลให้ครบถ้วน'),
                        ),
                      );
                      return;
                    }

                    // Check for duplicate room
                    final isDuplicate = _rooms.any(
                      (room) =>
                          room['room_number'].toString().toLowerCase() ==
                          roomNo.toLowerCase(),
                    );

                    if (isDuplicate) {
                      setStateDialog(() {
                        roomNoError = 'หมายเลขห้องนี้มีอยู่ในระบบแล้ว';
                      });
                      return;
                    }

                    final result = await RoomManageApi().addRoom({
                      'room_number': roomNo,
                      'floor': floor,
                    });

                    if (context.mounted) {
                      if (result['status'] == 'success') {
                        Navigator.pop(context);
                        _fetchRoomData(); // Refresh list
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('เพิ่มห้องพักสำเร็จ')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result['message'] ?? 'เกิดข้อผิดพลาด',
                            ),
                          ),
                        );
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
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'ยกเลิก',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            CustomButton(
              text: 'ลบห้อง',
              width: 100,
              height: 40,
              padding: EdgeInsets.zero,
              onPressed: () async {
                final roomId = int.tryParse(
                  room['room_id']?.toString() ?? room['id']?.toString() ?? '',
                );
                if (roomId == null) return;

                final result = await RoomManageApi().deleteRoom(roomId);

                if (context.mounted) {
                  if (result['status'] == 'success') {
                    Navigator.pop(context);
                    _fetchRoomData(); // Refresh list
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ลบห้องพักสำเร็จ')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('เกิดข้อผิดพลาดในการลบห้อง'),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // ======== TABS BUILDERS ===================
  // ==========================================

  Widget _buildRateTab(TextTheme textTheme) {
    if (_isLoadingRates) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'จัดการเรทราคา',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              CustomButton(
                text: 'เพิ่มเรทใหม่',
                icon: const Icon(Icons.add_circle_outline, size: 18),
                width: 120,
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                onPressed: () => _showAddRateDialog(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomDropdownMenu<RateTemplate>(
                  label: 'เลือกเรทที่ต้องการแก้ไข',
                  hintText: 'เลือกเรทราคาที่ใช้งานอยู่',
                  controller: _rateSelectionController,
                  dropdownMenuEntries: _rates.map((rate) {
                    return DropdownMenuEntry<RateTemplate>(
                      value: rate,
                      label: 'เรทราคา ${rate.rateRoom} บาท',
                    );
                  }).toList(),
                  onSelected: _onRateSelected,
                ),
                const SizedBox(height: 24),
                const Divider(color: AppColors.divider),
                const SizedBox(height: 16),
                CustomTextField(
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  labelText: 'ราคาเช่าห้องพัก',
                  controller: _rateRoomController,
                  keyboardType: TextInputType.number,
                  suffixIcon: _buildRateFieldSuffix('บาท/เดือน'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        labelText: 'ค่าน้ำประปา',
                        controller: _rateWaterController,
                        keyboardType: TextInputType.number,
                        suffixIcon: _buildRateFieldSuffix('บาท/หน่วย'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        labelText: 'ค่าไฟฟ้า',
                        controller: _rateElectricController,
                        keyboardType: TextInputType.number,
                        suffixIcon: _buildRateFieldSuffix('บาท/หน่วย'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: CustomButton(
                    text: 'บันทึกการแก้ไข',
                    width: double.infinity,
                    height: 50,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    onPressed: () async {
                      if (_selectedRate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('กรุณาเลือกเรทที่ต้องการแก้ไข'),
                          ),
                        );
                        return;
                      }

                      final result = await RateManageApi().updateRate(
                        _selectedRate!.id,
                        {
                          'rate_room': _rateRoomController.text.trim(),
                          'rate_water': _rateWaterController.text.trim(),
                          'rate_electric': _rateElectricController.text.trim(),
                        },
                      );

                      if (!mounted) return;

                      if (result['status'] == 'success') {
                        _fetchRateData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('อัปเดตเรทราคาสำเร็จ')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result['message'] ?? 'เกิดข้อผิดพลาด',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomTab(TextTheme textTheme) {
    if (_isLoadingRooms) {
      return const Center(child: CircularProgressIndicator());
    }

    List<Map<String, dynamic>> filteredRooms = _rooms;
    if (_roomSearchQuery.isNotEmpty) {
      filteredRooms = _rooms
          .where((r) => r['room_number'].toString().contains(_roomSearchQuery))
          .toList();
    }

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
                color: AppColors.textPrimary,
              ),
            ),
            CustomButton(
              text: 'เพิ่มห้องพัก',
              icon: const Icon(Icons.add_circle_outline, size: 18),
              width: 120,
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              onPressed: () => _showAddRoomDialog(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SearchWidget(
          onSearch: (value) => setState(() => _roomSearchQuery = value),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 18),
              itemCount: filteredRooms.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final room = filteredRooms[index];
                final status = room['room_status'] ?? 'AVAILABLE';
                final isVacant = status == 'AVAILABLE';
                final statusLabel = status == 'AVAILABLE'
                    ? 'ว่าง'
                    : 'มีผู้เช่า';

                return CustomCard(
                  height: 80,
                  shadow: false,
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
                            size: 24,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'ห้อง ${room['room_number']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '($statusLabel)',
                                    style: TextStyle(
                                      color: isVacant
                                          ? AppColors.success
                                          : AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'ชั้น ${room['floor']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFB0B0B0),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Material(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        child: IconButton(
                          onPressed: () => _confirmDeleteRoom(room),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.error,
                            size: 20,
                          ),
                          tooltip: 'ลบห้อง',
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manage',
            style: textTheme.displayLarge?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            "จัดการข้อมูลเรทราคา และห้องพัก",
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // -------- TabBar ควบคุมการสลับหน้า --------
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                fontFamily: 'NotoSansThai',
              ),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(child: Text('เรทราคา')),
                Tab(child: Text('ห้องพัก')),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // -------- หน้าต่างแต่ละ Tab --------
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [_buildRateTab(textTheme), _buildRoomTab(textTheme)],
            ),
          ),
        ],
      ),
    );
  }
}

int naturalCompare(String a, String b) {
  final regExp = RegExp(r'(\d+|\D+)');
  final aMatches = regExp.allMatches(a).map((m) => m.group(0)!).toList();
  final bMatches = regExp.allMatches(b).map((m) => m.group(0)!).toList();

  final length = aMatches.length < bMatches.length
      ? aMatches.length
      : bMatches.length;

  for (int i = 0; i < length; i++) {
    final aPart = aMatches[i];
    final bPart = bMatches[i];
    final aInt = int.tryParse(aPart);
    final bInt = int.tryParse(bPart);

    if (aInt != null && bInt != null) {
      final compare = aInt.compareTo(bInt);
      if (compare != 0) return compare;
    } else {
      final compare = aPart.compareTo(bPart);
      if (compare != 0) return compare;
    }
  }
  return aMatches.length.compareTo(bMatches.length);
}
