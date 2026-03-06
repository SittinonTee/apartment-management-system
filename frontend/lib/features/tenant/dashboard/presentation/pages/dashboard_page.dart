import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../../core/widgets/status_badge.dart';
import '../../../../tenant/contracts/data/contract_service.dart';
import '../widgets/bill_summary_card.dart';
import '../widgets/contract_progress_card.dart';
import '../widgets/quick_action_menu.dart';
import '../widgets/user_greeting.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ContractService _contractService = ContractService();
  Map<String, dynamic>? _contractData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final data = await _contractService.getMyContract();
      if (mounted) {
        setState(() {
          _contractData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  double _calculateProgress(String start, String end) {
    try {
      final startDate = DateTime.parse(start);
      final endDate = DateTime.parse(end);
      final now = DateTime.now();

      if (now.isBefore(startDate)) return 0.0;
      if (now.isAfter(endDate)) return 1.0;

      final totalDuration = endDate.difference(startDate).inDays;
      final elapsedDuration = now.difference(startDate).inDays;

      return (elapsedDuration / totalDuration).clamp(0.0, 1.0);
    } catch (e) {
      return 0.0;
    }
  }

  String _formatDate(String dateStr) {
    try {
      // Use toLocal() to ensure 17:00:00Z becomes 00:00:00 (next day) in Thailand (UTC+7)
      final date = DateTime.parse(dateStr).toLocal();
      final year = date.year + 543;
      final formatter = DateFormat('d MMM', 'th');
      return '${formatter.format(date)} $year';
    } catch (e) {
      if (kDebugMode) print('DateFormat Error: $e');
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Process data from backend
    final roomNumber = _contractData?['room_number'] ?? 'ไม่มีข้อมูลห้อง';
    final floor = _contractData?['floor']?.toString() ?? '-';
    final buildingInfo = 'อาคาร A ชั้น $floor';
    final startDate = _contractData?['start_date'];
    final endDate = _contractData?['end_date'];

    double progress = 0.0;
    String formattedEndDate = '-';

    if (startDate != null && endDate != null) {
      progress = _calculateProgress(startDate, endDate);
      formattedEndDate = _formatDate(endDate);
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchDashboardData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserGreeting(
                  userName: '', // Will be picked from AuthService automatically
                  roomNumber: roomNumber,
                ),
                const SizedBox(height: 24),
                ContractProgressCard(
                  progressPercent: progress,
                  roomNumber: roomNumber == 'ไม่มีข้อมูลห้อง'
                      ? roomNumber
                      : 'ห้อง $roomNumber',
                  buildingInfo: buildingInfo,
                  endDate: formattedEndDate,
                ),
                const SizedBox(height: 32),
                QuickActionMenu(
                  onContractPressed: () {},
                  onBillsPressed: () {},
                  onPackagePressed: () {},
                  onRepairPressed: () {},
                ),
                const SizedBox(height: 32),
                BillSummaryCard(
                  amount: 0.0, // TODO: Fetch real bill data
                  month: 'ไม่มีข้อมูลบิลล่าสุด',
                  status: BadgeStatus.completed,
                  statusText: 'ไม่มีค้างชำระ',
                  onPayPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
