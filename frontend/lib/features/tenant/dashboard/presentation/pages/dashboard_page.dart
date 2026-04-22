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
import '../../../bills/presentation/pages/bill_pay_page.dart';
import '../../../../../core/utils/date_utils.dart';

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
    return AppDateUtils.formatDateThai(dateStr);
  }

  //-------------------------------------แมพสถานะบิล-----------------------------------------------
  (BadgeStatus, String) _getBillStatusInfo(String? dbStatus) {
    switch (dbStatus?.toUpperCase()) {
      case 'PAID':
        return (BadgeStatus.completed, 'ชำระแล้ว');
      case 'PENDING':
        return (BadgeStatus.pending, 'รอชำระ');
      case 'OVERDUE':
        return (BadgeStatus.urgent, 'เลยกำหนด');
      case 'WAITING_CONFIRM':
        return (BadgeStatus.verifying, 'รอยืนยัน');
      case 'CANCELLED':
        return (BadgeStatus.cancelled, 'ถูกปฏิเสธ');
      default:
        return (BadgeStatus.pending, 'รอชำระ');
    }
  }

  //-------------------------------------แสดงหน้า-----------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Process data from backend
    // พยายามดึงข้อมูลห้องจากสัญญา ถ้าไม่มีให้ดึงจากบิลใบล่าสุด (Fallback)
    String roomNumber = _contractData?['room_number']?.toString() ?? '';
    String floor = _contractData?['floor']?.toString() ?? '';
    
    if (roomNumber.isEmpty && _bills.isNotEmpty) {
      roomNumber = _bills.first['room_number']?.toString() ?? '';
      floor = _bills.first['floor']?.toString() ?? '';
    }

    // กำหนดค่า Default ถ้ายังไม่มีจริงๆ
    if (roomNumber.isEmpty) roomNumber = 'ไม่มีข้อมูลห้อง';
    if (floor.isEmpty) floor = '-';

    final buildingInfo = 'ชั้น $floor';
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
                    // ค้นหาบิลที่ด่วนที่สุดมาโชว์ (CANCELLED > OVERDUE > PENDING > WAITING_CONFIRM > PAID)
                    Map<String, dynamic>? priorityBill;
                    
                    final rejected = _bills.where((b) => b['status'] == 'CANCELLED').toList();
                    final overdue = _bills.where((b) => b['status'] == 'OVERDUE').toList();
                    final pending = _bills.where((b) => b['status'] == 'PENDING').toList();
                    final waiting = _bills.where((b) => b['status'] == 'WAITING_CONFIRM').toList();

                    if (rejected.isNotEmpty) {
                      priorityBill = rejected.first;
                    } else if (overdue.isNotEmpty) {
                      priorityBill = overdue.first;
                    } else if (pending.isNotEmpty) {
                      priorityBill = pending.first;
                    } else if (waiting.isNotEmpty) {
                      priorityBill = waiting.first;
                    } else if (_bills.isNotEmpty) {
                      priorityBill = _bills.first; // ถ้าจ่ายหมดแล้ว โชว์ใบลาสุด
                    }

                    if (priorityBill == null) {
                      return const SizedBox.shrink();
                    }

                    final amount = double.tryParse(priorityBill['grand_total']?.toString() ?? '0') ?? 0.0;
                    final billMonth = AppDateUtils.formatMonthFull(priorityBill['bill_month']);
                    final (status, statusText) = _getBillStatusInfo(priorityBill['status']);
                    final canPay = priorityBill['status'] != 'PAID' && priorityBill['status'] != 'WAITING_CONFIRM';

                    return BillSummaryCard(
                      amount: amount,
                      month: billMonth,
                      status: status,
                      statusText: statusText,
                      showPayButton: canPay,
                      onPayPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BillPayPage(billData: priorityBill!),
                          ),
                        );
                        if (result == true) {
                          _fetchDashboardData();
                        }
                      },
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
                        // แสดงรายการล่าสุดแค่ 3 รายการ
                        final recentBills = _bills.take(3).toList();
                        
                        return Column(
                          children: recentBills.map((bill) {
                            final total = double.tryParse(bill['grand_total']?.toString() ?? '0') ?? 0.0;
                            final (status, statusText) = _getBillStatusInfo(bill['status']);

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
