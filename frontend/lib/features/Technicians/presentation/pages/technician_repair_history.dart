import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/month_year_filter.dart';
import '../../../../core/services/auth_service.dart';
import '../../data/repair_model.dart';
import '../../data/repair_service.dart';
import '../widgets/technician_repair_card.dart';
import 'technician_repair_history_detail.dart';
import '../../../../core/widgets/searchbar.dart';
import '../../../../core/widgets/choicechip_filter.dart';

class TechnicianRepairHistoryPage extends StatefulWidget {
  final String? roomNumber;

  const TechnicianRepairHistoryPage({super.key, this.roomNumber});

  @override
  State<TechnicianRepairHistoryPage> createState() =>
      _TechnicianRepairHistoryPageState();
}

class _TechnicianRepairHistoryPageState
    extends State<TechnicianRepairHistoryPage> {
  final RepairService _repairService = RepairService();
  List<RepairRequest> _allHistory = [];
  bool _isLoading = true;

  int _selectedIndex = 0; // 0: ทั้งหมด, 1: เสร็จสิ้น, 2: ยกเลิก
  String _searchQuery = '';
  int? _selectedMonth;
  int? _selectedYear;

  final List<String> _categories = ['ทั้งหมด', 'เสร็จสิ้น', 'ยกเลิก'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchHistoryRepairs());
  }

  Future<void> _fetchHistoryRepairs() async {
    final currentUserId = context.read<AuthService>().userId;

    try {
      final repairs = await _repairService.getTechnicianRepairs();
      if (mounted) {
        setState(() {
          _allHistory = repairs
              .where(
                (r) =>
                    (r.status == 'COMPLETED' || r.status == 'CANCELLED') &&
                    (r.technicianId == currentUserId || r.technicianId == null),
              )
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<RepairRequest> get _filteredHistory {
    List<RepairRequest> filtered = List.from(_allHistory);

    // กรองตาม Tab (เสร็จสิ้น / ยกเลิก)
    if (_selectedIndex == 1) {
      filtered = filtered.where((r) => r.status == 'COMPLETED').toList();
    } else if (_selectedIndex == 2) {
      filtered = filtered.where((r) => r.status == 'CANCELLED').toList();
    }

    // กรองตามการค้นหา
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((r) {
        final searchLower = _searchQuery.toLowerCase();
        return (r.roomNumber?.toLowerCase().contains(searchLower) ?? false) ||
            (r.tenantName?.toLowerCase().contains(searchLower) ?? false) ||
            r.title.toLowerCase().contains(searchLower);
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back_ios_new,
                      color: Color(0xFF5AB6A9),
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'ย้อนกลับ',
                      style: TextStyle(
                        color: Color(0xFF5AB6A9),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildHeader(),
              const SizedBox(height: 16),
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
                    : _buildHistoryList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Center(
      child: Column(
        children: [
          Text(
            'ประวัติการซ่อม',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'ตรวจสอบประวัติการซ่อมแซมได้ที่นี่',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Column(
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
    );
  }

  Widget _buildFilterTabs() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
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

  Widget _buildHistoryList() {
    final tasks = _filteredHistory;

    if (tasks.isEmpty) {
      return const Center(
        child: Text(
          'ไม่พบประวัติการรับงาน',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      itemCount: tasks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final repair = tasks[index];
        return TechnicianRepairCard(
          repair: repair,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TechnicianRepairHistoryDetailPage(
                  repair: repair,
                ),
              ),
            ).then((_) => _fetchHistoryRepairs());
          },
        );
      },
    );
  }
}
