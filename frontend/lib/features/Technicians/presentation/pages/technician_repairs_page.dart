import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/choicechip_filter.dart';
import '../../data/repair_model.dart';
import '../../data/repair_service.dart';
import '../widgets/technician_repair_card.dart';
import 'technician_repair_detail_page.dart';

class TechnicianRepairsPage extends StatefulWidget {
  const TechnicianRepairsPage({super.key});

  @override
  State<TechnicianRepairsPage> createState() => _TechnicianRepairsPageState();
}

class _TechnicianRepairsPageState extends State<TechnicianRepairsPage> {
  final RepairService _repairService = RepairService();
  int _selectedIndex = 0;
  final List<String> _categories = [
    'ทั้งหมด',
    'ปัญหา', // REPORTED
    'กำลังดำเนินการ', // ASSIGNED, PENDING
    'เสร็จสิ้น', // COMPLETED
    'ยกเลิก', // CANCELLED
  ];

  List<RepairRequest> _allRepairs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRepairs();
  }

  Future<void> _fetchRepairs() async {
    // ดึงข้อมูลจริงจาก API
    try {
      final repairs = await _repairService.getTechnicianRepairs();
      if (mounted) {
        setState(() {
          _allRepairs = repairs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<RepairRequest> get _filteredRepairs {
    if (_selectedIndex == 0) return _allRepairs;

    // แปลง Text แถบเมนูเป็น Enum สถานะเพื่อกรองข้อมูล
    final category = _categories[_selectedIndex];
    RepairStatus? status;
    if (category == 'ปัญหา') status = RepairStatus.problem;
    if (category == 'กำลังดำเนินการ') status = RepairStatus.inProgress;
    if (category == 'เสร็จสิ้น') status = RepairStatus.completed;
    if (category == 'ยกเลิก') status = RepairStatus.cancelled;

    return _allRepairs.where((r) => r.statusEnum == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildFilterTabs(),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : _buildRepairList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ยื่นเรื่องซ่อม',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'ตรวจสอบการซ่อมบำรุงได้ที่นี่',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF5AB6A9),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Text(
              'ประวัติการซ่อม',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedIndex == index;
          return ChoiceChipFilter(
            label: _categories[index],
            selected: isSelected,
            onSelected: (selected) {
              if (selected) setState(() => _selectedIndex = index);
            },
            selectedColor: AppColors.primary,
            bgColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
              side: BorderSide(
                color: isSelected ? Colors.transparent : AppColors.border,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRepairList() {
    final tasks = _filteredRepairs;

    if (tasks.isEmpty) {
      return const Center(
        child: Text(
          'ไม่พบรายการแจ้งซ่อมในหมวดหมู่นี้',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return TechnicianRepairCard(
          repair: tasks[index],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    TechnicianRepairDetailPage(repair: tasks[index]),
              ),
            );
          },
        );
      },
    );
  }
}
