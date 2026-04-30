import 'package:flutter/material.dart';
import 'package:frontend/features/admin/dashboard/data/get_rate.dart';
import 'package:frontend/features/admin/dashboard/data/rate_manage_api.dart';
import 'package:frontend/features/admin/dashboard/data/room_manage_api.dart';
import 'package:frontend/core/constants/app_colors.dart';
import '../manage_widget/rate_manage_tab.dart';
import '../manage_widget/room_manage_tab.dart';

class ManagePage extends StatefulWidget {
  const ManagePage({super.key});

  @override
  State<ManagePage> createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // -------- State --------
  List<RateTemplate> _rates = [];
  List<Map<String, dynamic>> _rooms = [];
  bool _isLoadingRates = false;
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
    super.dispose();
  }

  Future<void> _fetchRateData() async {
    setState(() => _isLoadingRates = true);
    try {
      final ratesData = await RateManageApi().getAllRates();
      if (!mounted) return;
      setState(() {
        _rates = ratesData.map((x) => RateTemplate.fromJson(x)).toList();
        _isLoadingRates = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoadingRates = false);
    }
  }

  Future<void> _fetchRoomData() async {
    setState(() => _isLoadingRooms = true);
    try {
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
    } catch (e) {
      if (mounted) setState(() => _isLoadingRooms = false);
    }
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

          // -------- TabBar --------
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

          // -------- TabBarView Content --------
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                RateManageTab(
                  rates: _rates,
                  isLoading: _isLoadingRates,
                  onRefresh: _fetchRateData,
                ),
                RoomManageTab(
                  rooms: _rooms,
                  isLoading: _isLoadingRooms,
                  onRefresh: _fetchRoomData,
                ),
              ],
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
