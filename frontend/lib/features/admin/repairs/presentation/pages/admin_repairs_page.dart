import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/core/widgets/choicechip_filter.dart';
import 'package:frontend/core/widgets/custom_button.dart';
import 'package:frontend/core/widgets/searchbar.dart';
import 'package:frontend/features/admin/repairs/data/admin_repair_model.dart';
import 'package:frontend/features/admin/repairs/data/get_allrepairs.dart';
import 'package:frontend/features/admin/repairs/presentation/admin_repairs_widgets/admin_repair_ticket_card.dart';
import 'package:frontend/features/admin/repairs/presentation/admin_repairs_widgets/repairs_summary.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// หน้าจอนี้แสดงรายการยื่นเรื่องซ่อม (Repairs Page) สำหรับผู้ใช้ทั่วไป (Tenant)
/// จะประกอบไปด้วย 3 ส่วนหลัก ได้แก่
/// 1. ส่วนหัวและปุ่มสร้างรายการใหม่
/// 2. Grid สรุปสถานะรายการแจ้งซ่อม 4 ช่อง
/// 3. แถบตัวกรองสถานะและรายการแจ้งซ่อมตามหมวดหมู่
class AdminRepairsPage extends StatefulWidget {
  const AdminRepairsPage({super.key});
  @override
  State<AdminRepairsPage> createState() => _AdminRepairsPageState();
}

class _AdminRepairsPageState extends State<AdminRepairsPage> {
  int _selectedFilterIndex = 0;
  String searchQuery = '';
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
  List<AdminRepairModel> _repairs = [];
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

      final repairs = await GetAllRepairs().getAllRepairs(token);

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

  /// ฟังก์ชันวาดส่วนแถบสรุปข้อมูล ด้านบนสุด
  Widget _buildSummaryBar(List<AdminRepairModel> repairs) {
    int countProblem = 0;
    int countInProgress = 0;
    int countMaterial = 0;
    int countCompleted = 0;

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

    return RepairsSummary(
      countProblem: countProblem,
      countInProgress: countInProgress,
      countMaterial: countMaterial,
      countCompleted: countCompleted,
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
                Text('สถานะการซ่อม', style: textTheme.displayLarge),
                Row(
                  children: [
                    CustomButton(
                      text: 'จัดการช่าง',
                      textStyle: textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      width: 100,
                      height: 38,
                      borderRadius: BorderRadius.circular(12),
                      onPressed: () => context.push('/admin/technicians'),
                      icon: const Icon(Icons.engineering, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.logout, size: 20),
                        onPressed: () => context.read<AuthService>().logout(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text("ตรวจสอบการซ่อมแซมได้ที่นี่", style: textTheme.bodyMedium),
            const SizedBox(height: 12),

            // --------------------------------------------------- ส่วนที่ 2 + 3 Body Area ที่รอดึงข้อมูลหลังบ้าน
            // ส่วนตารางโชว์รายการทีละตัว
            Expanded(
              child: _isLoading
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
        _buildSummaryBar(allRepairs),

        const SizedBox(height: 12),
        //------------------------------Search Bar----------------------------//
        SearchWidget(
          onSearch: (value) {
            setState(() {
              searchQuery = value;
              // หากต้องการค้นหาฝั่ง API ใหม่ตรงนี้ ให้เลิกคอมเมนต์ด้านล่าง
              // _loadBills();
            });
          },
        ),

        //------------------------------Search Bar----------------------------//
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
                    return AdminRepairTicketCard(
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
                    );
                  },
                ),
        ),
      ],
    );
  }

  //----------------------------------- ใบรายละเอียดการซ่อม --------------------------------//
}
