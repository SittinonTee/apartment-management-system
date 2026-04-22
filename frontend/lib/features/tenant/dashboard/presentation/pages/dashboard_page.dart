import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../../core/widgets/status_badge.dart';
import '../../../../tenant/bills/data/bill_service.dart';
import '../../../../tenant/contracts/data/contract_service.dart';
import '../widgets/bill_summary_card.dart';
import '../widgets/contract_progress_card.dart';
import '../widgets/quick_action_menu.dart';
import '../widgets/recent_bill_card.dart';
import '../widgets/user_greeting.dart';

import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  final Function(int)? onTabSelected;
  const DashboardPage({super.key, this.onTabSelected});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ContractService _contractService = ContractService();
  final BillService _billService = BillService();
  Map<String, dynamic>? _contractData;
  List<Map<String, dynamic>> _bills = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  //-------------------------------------ดึงข้อมูลสัญญาเช่าและบิล-----------------------------------------------
  Future<void> _fetchDashboardData() async {
    try {
      final contractData = await _contractService.getMyContract();
      final bills = await _billService.getMyBills();
      
      // Filter out DRAFT bills so tenants don't see incomplete bills
      final visibleBills = bills.where((b) => b['status'] != 'DRAFT').toList();

      if (mounted) {
        setState(() {
          _contractData = contractData;
          _bills = visibleBills;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) print('Dashboard fetch error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  //-------------------------------------คำนวนความคืบหน้าสัญญาเช่า-----------------------------------------------
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

  //-------------------------------------แปลงวันที่-----------------------------------------------
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

  //-------------------------------------แสดงหน้า-----------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Process data from backend
    final roomNumber = _contractData?['room_number'] ?? 'ไม่มีข้อมูลห้อง';
    final floor = _contractData?['floor']?.toString() ?? '-';
    final buildingInfo =
        'อาคาร ${_contractData?['building'] ?? '-'} ชั้น $floor';
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
                  userName: _contractData != null
                      ? '${_contractData!['firstname']} ${_contractData!['lastname']}'
                      : 'ไม่มีข้อมูลผู้ใช้',
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
                  onContractPressed: () => widget.onTabSelected?.call(1),
                  onBillsPressed: () => widget.onTabSelected?.call(2),
                  onPackagePressed: () => widget.onTabSelected?.call(3),
                  onRepairPressed: () => widget.onTabSelected?.call(4),
                ),
                const SizedBox(height: 32),
                Builder(
                  builder: (context) {
                    final latestBill = _bills.isNotEmpty ? _bills.first : null;
                    final snapshot = latestBill?['rent_snapshot'];
                    double totalAmount = 0.0;
                    if (snapshot is Map) {
                      totalAmount =
                          ((snapshot['room'] ?? 0) +
                                  (snapshot['water'] ?? 0) +
                                  (snapshot['electric'] ?? 0))
                              .toDouble();
                    }
                    final billStatus = latestBill?['status'];
                    return BillSummaryCard(
                      amount: totalAmount,
                      month:
                          latestBill?['bill_month'] ?? 'ไม่มีข้อมูลบิลล่าสุด',
                      status: billStatus == 'PAID'
                          ? BadgeStatus.completed
                          : billStatus == 'PENDING'
                          ? BadgeStatus.pending
                          : BadgeStatus.urgent,
                      statusText: billStatus == 'PAID'
                          ? 'ชำระแล้ว'
                          : billStatus == 'PENDING'
                          ? 'รอชำระ'
                          : billStatus == 'OVERDUE'
                          ? 'ค้างชำระ'
                          : 'ไม่มีค้างชำระ',
                      onPayPressed: () {},
                    );
                  },
                ),
                const SizedBox(height: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'รายการล่าสุด',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF4A4A4A),
                              ),
                        ),
                        InkWell(
                          onTap: () {
                            widget.onTabSelected?.call(2);
                          },
                          child: Text(
                            'ดูทั้งหมด',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Builder(
                      builder: (context) {
                        if (_bills.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text('ยังไม่มีข้อมูลบิลล่าสุด'),
                            ),
                          );
                        }
                        return Column(
                          children: _bills.map((bill) {
                            final snapshot = bill['rent_snapshot'];
                            double total = 0.0;
                            if (snapshot is Map) {
                              total =
                                  ((snapshot['room'] ?? 0) +
                                          (snapshot['water'] ?? 0) +
                                          (snapshot['electric'] ?? 0))
                                      .toDouble();
                            }
                            final billStatus = bill['status'];
                            final status = billStatus == 'PAID'
                                ? BadgeStatus.completed
                                : billStatus == 'PENDING'
                                ? BadgeStatus.pending
                                : BadgeStatus.urgent;
                            final statusText = billStatus == 'PAID'
                                ? 'ชำระแล้ว'
                                : billStatus == 'PENDING'
                                ? 'รอชำระ'
                                : billStatus == 'OVERDUE'
                                ? 'ค้างชำระ'
                                : '-';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: RecentBillCard(
                                month: bill['bill_month'] ?? '-',
                                amount: total,
                                status: status,
                                statusText: statusText,
                                roomNumber: roomNumber,
                                tenantName: _contractData != null
                                    ? '${_contractData!['firstname']} ${_contractData!['lastname']}'
                                    : '-',
                                dueDate: bill['due_date'] != null
                                    ? _formatDate(bill['due_date'])
                                    : '-',
                                paymentDate: bill['payment_date'] != null
                                    ? _formatDate(bill['payment_date'])
                                    : null,
                                paymentMethod: bill['payment_date'] != null
                                    ? 'โอนเงินผ่านธนาคาร' // Default for now
                                    : null,
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
