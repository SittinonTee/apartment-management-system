import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/choicechip_filter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../data/repair_model.dart';
import '../../data/repair_service.dart';
import '../widgets/technician_repair_card.dart';
import 'technician_repair_detail_page.dart';
import 'technician_repair_history.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/month_year_filter.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/widgets/searchbar.dart';

class TechnicianRepairsPage extends StatefulWidget {
  const TechnicianRepairsPage({super.key});

  @override
  State<TechnicianRepairsPage> createState() => _TechnicianRepairsPageState();
}

class _TechnicianRepairsPageState extends State<TechnicianRepairsPage> {
  final RepairService _repairService = RepairService();
  int _selectedIndex = 0;
  String _searchQuery = '';
  int? _selectedMonth;
  int? _selectedYear;

  final List<String> _categories = [
    'ทั้งหมด',
    'ปัญหา', // REPORTED
    'กำลังดำเนินการ', // ASSIGNED
    'เตรียมอุปกรณ์', // PENDING
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
    List<RepairRequest> filtered = _allRepairs.where((r) {
      // หน้าแรกแสดงแต่งานที่ยังไม่เสร็จ (ไม่เอา COMPLETED, CANCELLED)
      return r.status != 'COMPLETED' && r.status != 'CANCELLED';
    }).toList();

    // กรองตามแถบสถานะ (Tab)
    if (_selectedIndex != 0) {
      final category = _categories[_selectedIndex];
      RepairStatus? status;
      if (category == 'ปัญหา') status = RepairStatus.problem;
      if (category == 'กำลังดำเนินการ') status = RepairStatus.inProgress;
      if (category == 'เตรียมอุปกรณ์') status = RepairStatus.pending;
      filtered = filtered.where((r) => r.statusEnum == status).toList();
    }

    // กรองตามการค้นหา (เลขห้อง หรือ ชื่อ)
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((r) {
        final searchLower = _searchQuery.toLowerCase();
        final roomMatch = r.roomNumber?.toLowerCase().contains(searchLower) ?? false;
        final nameMatch = r.tenantName?.toLowerCase().contains(searchLower) ?? false;
        final titleMatch = r.title.toLowerCase().contains(searchLower);
        return roomMatch || nameMatch || titleMatch;
      }).toList();
    }

    // กรองตามเดือน/ปี
    if (_selectedMonth != null) {
      filtered = filtered.where((r) => r.date.month == _selectedMonth).toList();
    }
    if (_selectedYear != null) {
      filtered = filtered.where((r) => r.date.year == _selectedYear).toList();
    }

    return filtered;
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
            _buildSearchAndFilter(),
            const SizedBox(height: 16),
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
          Row(
            children: [
              CustomButton(
                isPrimary: true,
                isOutlined: false,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TechnicianRepairHistoryPage(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.history,
                  size: 18,
                  color: Colors.white,
                ),
                width: 34,
                height: 34,
                padding: const EdgeInsets.only(left: 6),
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(width: 8),
              CustomButton(
                isPrimary: false,
                isOutlined: true,
                onPressed: () {
                  Provider.of<AuthService>(context, listen: false).logout();
                },
                icon: const Icon(
                  Icons.logout,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                width: 34,
                height: 34,
                padding: const EdgeInsets.only(left: 6),
                borderRadius: BorderRadius.circular(12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SearchWidget(
            onChanged: (value) => setState(() => _searchQuery = value),
            onSearch: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 12),
          MonthYearFilter(
            selectedMonth: _selectedMonth,
            selectedYear: _selectedYear,
            onChanged: (month, year) {
              setState(() {
                _selectedMonth = month;
                _selectedYear = year;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(), // บังคับให้มีเอฟเฟกต์เด้งดึ๋งเมื่อเลื่อนสุด
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChipFilter(
                label: _categories[index],
                selected: _selectedIndex == index,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedIndex = index);
                },
              ),
            );
          },
        ),
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
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    TechnicianRepairDetailPage(repair: tasks[index]),
              ),
            );

            // ถ้ารับงานสำเร็จ (result == true) ให้โหลดข้อมูลใหม่ทันที
            if (result == true) {
              _fetchRepairs();
            }
          },
        );
      },
    );
  }
}
