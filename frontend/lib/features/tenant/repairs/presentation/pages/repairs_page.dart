import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/core/widgets/custom_button.dart';
import 'package:frontend/core/widgets/choicechip_filter.dart';
import 'package:provider/provider.dart';

import 'package:frontend/features/tenant/repairs/data/get_repairs.dart';
import 'package:frontend/features/tenant/repairs/data/repair_model.dart';
import 'package:frontend/features/tenant/repairs/presentation/repairs_widgets/repairs_info_card.dart';
import 'package:frontend/features/tenant/repairs/presentation/repairs_widgets/repair_ticket_card.dart';
import 'package:frontend/features/tenant/repairs/presentation/pages/new_repair_page.dart';

/// หน้าจอนี้แสดงรายการยื่นเรื่องซ่อม (Repairs Page) สำหรับผู้ใช้ทั่วไป (Tenant)
/// จะประกอบไปด้วย 3 ส่วนหลัก ได้แก่
/// 1. ส่วนหัวและปุ่มสร้างรายการใหม่
/// 2. Grid สรุปสถานะรายการแจ้งซ่อม 4 ช่อง
/// 3. แถบตัวกรองสถานะและรายการแจ้งซ่อมตามหมวดหมู่
class RepairsPage extends StatefulWidget {
  const RepairsPage({super.key});
  @override
  State<RepairsPage> createState() => _RepairsPageState();
}

class _RepairsPageState extends State<RepairsPage> {
  // `_selectedFilterIndex` เก็บตำแหน่งของหมวดหมู่ที่ผู้ใช้กดเลือกในปัจจุบัน
  // โดย 0 = ทั้งหมด, 1 = ปัญหา, 2 = กำลังดำเนิน.., 3 = จัดซื้อวัสดุ, 4 = สำเร็จ
  int _selectedFilterIndex = 0;

  // ลิสต์ข้อความที่จะนำไปสร้างบนแถบสไลด์ตัวกรองแนวนอน
  final List<String> _filters = [
    'ทั้งหมด',
    'ปัญหา',
    'กำลังดำเนิน..',
    'จัดซื้อวัสดุ',
    'สำเร็จ',
    'ยกเลิก',
  ];

  // `_repairsFuture` เป็นตัวแปรที่จะคอยรอข้อมูล List จาก Backend (ทำงานแบบ Asynchronous)
  // ซึ่งจะเป็นตัวกำหนดว่าหน้าจอจะแสดง Loading หมุนๆ หรือโชว์ข้อมูลลิสต์การซ่อม
  List<RepairModel> _repairs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // เมื่อ Component หน้าจอนี้ถูกวาดขึ้นมาครั้งแรก ให้สั่งรันฟังก์ชันโหลดข้อมูลทันที
    _loadRepairs();
  }

  /// ฟังก์ชันสำหรับดึงข้อมูลแจ้งซอกจาก Backend
  Future<void> _loadRepairs() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getToken();

      if (token == null) {
        setState(() {
          _repairs = [];
          _isLoading = false;
        });
        return;
      }

      final repairs = await GetRepairs().getMyRepairs(token);

      if (mounted) {
        setState(() {
          _repairs = repairs;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading repairs: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  /// ฟังก์ชันแปลงข้อความภาษาอังกฤษจาก Backend ให้เป็น 'สี' ได้อย่างอิสระ
  /// โดยไม่ต้องพึ่งพา BadgeStatus จาก StatusBadge
  Color _mapStatusToColor(String status) {
    status = status.toUpperCase();
    if (status == 'COMPLETED') return AppColors.success; // สำเร็จ
    if (status == 'REPORTED') {
      return AppColors.error; // เกิดปัญหา
    }
    if (status == 'ASSIGNED') {
      return AppColors.warning; // กำลังดำเนิน
    }
    if (status == 'PENDING') {
      return AppColors.info; // จัดซื้อวัสดุ
    }
    if (status == 'CANCELLED') {
      return AppColors.textSecondary; // ยกเลิก
    }
    return Colors.greenAccent; // อื่นๆ
  }

  /// ฟังก์ชันแปลงข้อความภาษาอังกฤษจาก Backend ให้เป็นตัวหนังสือภาษาไทย
  /// สำหรับแสดงผลบริเวณกล่องการ์ด
  String _mapStatusToThaiStr(String status) {
    status = status.toUpperCase();
    if (status == 'COMPLETED') return 'สำเร็จ';
    if (status == 'REPORTED') return 'ปัญหา';
    if (status == 'PENDING') return 'จัดซื้อวัสดุ';
    if (status == 'ASSIGNED') return 'กำลังดำเนิน..';
    if (status == 'CANCELLED') return 'ยกเลิก';
    return status;
  }

  /// ฟังก์ชันวาดส่วนกล่องสรุปข้อมูลแบบตาราง 2x2 กริด ด้านบนสุด
  Widget _buildSummaryGrid(List<RepairModel> repairs) {
    // กำหนดตัวแปรนับจำนวนของคำขอแต่ละสถานะ โดยตั้งต้นที่ 0
    int countProblem = 0; // แทน REPORTED
    int countInProgress = 0; // แทน ASSIGNED
    int countMaterial = 0; // แทน PENDING
    int countCompleted = 0; // แทน COMPLETED

    // วนลูปอ่านข้อมูลทั้งหมดที่ยิงผ่าน API มา แล้วนับเพิ่มทีละ 1 ตามเงื่อนไข
    for (var r in repairs) {
      final s = r.status.toUpperCase();
      if (s == 'REPORTED') {
        countProblem++;
      } else if (s == 'ASSIGNED') {
        countInProgress++;
      } else if (s == 'PENDING') {
        countMaterial++;
      } else if (s == 'COMPLETED') {
        countCompleted++;
      }
    }

    // ส่งคืนเป็น Layout แบบ Grid.count (แบบระบุจำนวนคอลัมน์ตายตัว)
    return GridView.count(
      crossAxisCount: 2, // แบ่งช่องแนวนอนเป็น 2 คอลัมน์
      childAspectRatio: 1.8, // อัตราส่วน กล่องกว้างกว่าความสูง
      mainAxisSpacing: 16, // ช่องว่างแนวตั้ง 16 px
      crossAxisSpacing: 16, // ช่องว่างแนวนอน 16 px
      shrinkWrap:
          true, // ทำให้ Grid หดตัวพอดีตามเนื้อหาในตัวเอง (จะไม่กินที่เกิดความจำเป็น)
      physics:
          const NeverScrollableScrollPhysics(), // ปิดการเลื่อน (Scroll) ด้วยตัวเอง เพราะมันจะฝังอยู่ใน Scroll ใหญ่ชั้นนอก
      children: [
        // วาดให้ครบ 4 กล่อง โดยส่งจำนวนที่นับได้, ชื่อภาษาไทย, และโทนสี
        _buildInfoCard(countProblem, 'ปัญหา', AppColors.error),
        _buildInfoCard(countInProgress, 'กำลังดำเนิน...', AppColors.warning),
        _buildInfoCard(countMaterial, 'จัดซื้อวัสดุ', AppColors.info),
        _buildInfoCard(countCompleted, 'สำเร็จ', AppColors.success),
      ],
    );
  }

  /// ตัวสร้าง Layout กล่องสี่เหลี่ยมด้านบนแบบรับพารามิเตอร์แต่ละสีแยกทีละกล่อง
  Widget _buildInfoCard(int value, String title, Color mainColor) {
    return RepairsInfoCard(
      shadow: true,
      borderSize: 2, // ความหนาเส้นของกรอบสี่เหลี่ยมรอบนอก
      borderColor: mainColor, // สีตีกรอบ
      color: mainColor.withValues(
        alpha: 0.15,
      ), // สีพื้นด้านในจางๆ ให้ไม่ทึบด้วย alpha 0.15
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value.toString(), // ตัวเลขเอามาโชว์
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: mainColor, // ให้สีอักษรเป็นสีหลัก
            ),
          ),
          Text(
            title, // หัวข้อ เช่น "ปัญหา"
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: mainColor,
            ),
          ),
        ],
      ),
    );
  }

  /// กำหนดว่าแต่ละ category_id ควรจะโชว์รูปไอคอนเป็นรูปอะไร
  IconData _getCategoryIcon(int categoryId) {
    switch (categoryId) {
      case 1:
        return Icons.water_drop; // ประปา
      case 2:
        return Icons.bolt; // ไฟฟ้า
      case 3:
        return Icons.air; // แอร์
      case 4:
        return Icons.chair; // เฟอร์นิเจอร์
      default:
        return Icons.lock_outline; // อื่นๆ
    }
  }

  /// กำหนดว่าแต่ละ category_id ควรจะแสดงสีไอคอนเป็นสีอะไรให้สวยงาม
  Color _getCategoryColor(int categoryId) {
    switch (categoryId) {
      case 1:
        return AppColors.info;
      case 2:
        return AppColors.warning;
      case 3:
        return AppColors.error;
      case 4:
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  //--------------------------------------------- Widget หลัก ------------------------------------------------//

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: Padding(
        // ขยับขอบทั้ง ซ้าย-ขวา-บน ออกมาเล็กน้อย เพิ่มความสะอาดตา
        padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --------------------------------- ส่วน Header ด้านบนสุด--------------------------//
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ยื่นเรื่องซ่อม', style: textTheme.displayLarge),
                Row(
                  children: [
                    CustomButton(
                      text: '+ New',
                      isPrimary: true,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => NewRepairPage(
                                  roomNumber:
                                      _repairs.isNotEmpty
                                          ? _repairs.first.roomNumber
                                          : null,
                                ),
                          ),
                        ).then((value) {
                          if (value == true) {
                            _loadRepairs(); // Refresh data if something was submitted
                          }
                        });
                      },
                      width: 90,
                      height: 36,
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.circular(20),
                    ),

                    const SizedBox(width: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: () => context.read<AuthService>().logout(),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 4),
            Text("ตรวจสอบการซ่อมแซมได้ที่นี่", style: textTheme.bodyMedium),
            const SizedBox(height: 24),

            // --------------------------------------------------- ส่วนที่ 2 + 3 Body Area ที่รอดึงข้อมูลหลังบ้าน
            // ส่วนตารางโชว์รายการทีละตัว
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? Center(
                        child: Text(
                          'โหลดข้อมูลไม่สำเร็จ: $_error',
                          style: TextStyle(color: AppColors.error),
                        ),
                      )
                      : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  //----------------------------------- ใบรายละเอียดการซ่อม --------------------------------//
  Widget _buildContent() {
    final allRepairs = _repairs;

    const statusMap = {
      1: 'REPORTED',
      2: 'ASSIGNED',
      3: 'PENDING',
      4: 'COMPLETED',
      5: 'CANCELLED',
    };

    final filteredRepairs = allRepairs.where((r) {
      if (_selectedFilterIndex == 0) return true;
      return r.status.toUpperCase() == statusMap[_selectedFilterIndex];
    }).toList();

    return Column(
      children: [
        _buildSummaryGrid(allRepairs),
        const SizedBox(height: 24),

        /// Filter Chips
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _filters.length,
            itemBuilder: (context, i) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChipFilter(
                  label: _filters[i],
                  selected: _selectedFilterIndex == i,
                  onSelected: (_) {
                    setState(() {
                      _selectedFilterIndex = i;
                    });
                  },
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        /// List
        Expanded(
          child: filteredRepairs.isEmpty
              ? const Center(
                  child: Text(
                    'ไม่มีรายการแจ้งซ่อม',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  itemCount: filteredRepairs.length,
                  itemBuilder: (context, index) {
                    final repair = filteredRepairs[index];
                    final categoryColor = _getCategoryColor(repair.categoryId);
                    return RepairTicketCard(
                      repairId: repair.id,
                      onRefresh: _loadRepairs,
                      title: repair.title,
                      categoryName: repair.categoryName,
                      date: repair.createdAt,
                      statusText: _mapStatusToThaiStr(repair.status),
                      statusColor: _mapStatusToColor(repair.status),
                      icon: _getCategoryIcon(repair.categoryId),
                      iconColor: categoryColor,
                      iconBgColor: categoryColor.withValues(alpha: 0.15),
                      // ส่งข้อมูลเพิ่มเติ่มสำหรับตอนกางการ์ด
                      description: repair.description,
                      completedAt: repair.completedAt,
                      // ข้อมูลสมมติ (Mock) ไว้ชั่วคราวก่อน Backend มีข้อมูลจริงดึงมาให้ประสม
                      tenantfirstname: repair.tenantfirstname,
                      tenantlastname: repair.tenantlastname,
                      roomNumber: repair.roomNumber,
                      tenantPhone: repair.tenantPhone,
                      mechanicfirstname:
                          repair.status.toUpperCase() == 'REPORTED'
                          ? 'ยังไม่ได้มอบหมาย'
                          : repair.mechanicfirstname,
                      mechaniclastname: repair.mechaniclastname,
                      mechanicPhone: repair.mechanicPhone,
                      imageUrl: repair.imageUrl,
                    );
                  },
                ),
        ),
      ],
    );
  }

  //----------------------------------- ใบรายละเอียดการซ่อม --------------------------------//
}
