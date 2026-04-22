import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/date_utils.dart';
import '../widgets/total_paid_card.dart';
import '../widgets/current_due_card.dart';
import '../../../dashboard/presentation/widgets/recent_bill_card.dart';
import '../../../../../core/widgets/status_badge.dart';
import '../../data/bill_service.dart';
import '../../../contracts/data/contract_service.dart';
import 'bill_pay_page.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  late Future<Map<String, dynamic>> _dataFuture;
  int _refreshKey = 0; // เพิ่มตัวแปรสำหรับคุมการรีเฟรชหน้าจอ

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchData();
  }

  Future<Map<String, dynamic>> _fetchData() async {
    final results = await Future.wait([
      BillService().getMyBills(),
      ContractService().getMyContract(),
    ]);
    return {
      'bills': results[0] as List<Map<String, dynamic>>,
      'contract': results[1] as Map<String, dynamic>?,
    };
  }

  int _calculateMonthDifference(DateTime start, DateTime end) {
    return ((end.year - start.year) * 12) + end.month - start.month + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          key: ValueKey(_refreshKey), // ใช้ Key เพื่อบังคับให้สร้าง FutureBuilder ใหม่เมื่อค่าเปลี่ยน
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
            }

            final dataMap = snapshot.data ?? {'bills': [], 'contract': null};
            final allBills = dataMap['bills'] as List<Map<String, dynamic>>;
            final contract = dataMap['contract'] as Map<String, dynamic>?;

            // แยกบิลที่ต้องจ่าย (PENDING/OVERDUE) และ บิลที่จ่ายแล้ว (PAID)
            // Logic: แสดงการ์ดบิลที่ค้าง (PENDING) และถึงกำหนด (วันที่ 1 ของเดือนถัดไป)
            final now = DateTime.now();
            final firstDayOfCurrentMonth = DateTime(now.year, now.month, 1);

            final pendingBills = allBills.where((b) {
              if (b['status'] == 'PAID') return false;
              if (b['status'] == 'DRAFT') return false;

              // ถ้าเป็นสถานะ รอยืนยัน หรือ ถูกปฏิเสธ (CANCELLED) ให้แสดงในการ์ด
              if (b['status'] == 'WAITING_CONFIRM' || b['status'] == 'CANCELLED') return true;

              final billMonthStr = b['bill_month'] as String?;
              if (billMonthStr == null) return false;

              try {
                // บิลเดือน 2026-02 จะโชว์เมื่อถึง 2026-03-01 เป็นต้นไป
                final billMonthDate = DateTime.parse("$billMonthStr-01");
                return billMonthDate.isBefore(firstDayOfCurrentMonth);
              } catch (_) {
                return false;
              }
            }).toList();

            // เรียงลำดับบิลที่ค้างชำระจากเก่าไปใหม่ (วันที่น้อยสุดขึ้นก่อน)
            pendingBills.sort((a, b) {
              final dateA = a['due_date'] != null
                  ? DateTime.tryParse(a['due_date'].toString())
                  : null;
              final dateB = b['due_date'] != null
                  ? DateTime.tryParse(b['due_date'].toString())
                  : null;
              if (dateA != null && dateB != null) return dateA.compareTo(dateB);
              return 0;
            });

            final paidBills = allBills
                .where((b) => b['status'] == 'PAID')
                .toList();

            // --- คำนวณข้อมูลจริงสำหรับ TotalPaidCard ---
            double totalPaid = 0;
            for (var bill in paidBills) {
              totalPaid +=
                  double.tryParse(bill['grand_total']?.toString() ?? '0') ?? 0;
            }

            int paidMonthsCount = paidBills.length;
            int totalMonths = 12; // Default 12 month if no contract found

            if (contract != null &&
                contract['start_date'] != null &&
                contract['end_date'] != null) {
              try {
                final startDate = DateTime.parse(
                  contract['start_date'].toString(),
                );
                final endDate = DateTime.parse(contract['end_date'].toString());
                totalMonths = _calculateMonthDifference(startDate, endDate);
              } catch (_) {
                totalMonths = 12;
              }
            }

            final progressPercent = totalMonths > 0
                ? (paidMonthsCount / totalMonths)
                : 0.0;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    'ค่าเช่า',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'ตรวจสอบรายการจ่ายที่นี่',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 1. Total Paid Card
                  TotalPaidCard(
                    totalPaid: totalPaid,
                    currentMonth: paidMonthsCount,
                    totalMonths: totalMonths,
                    progressPercent: progressPercent,
                  ),
                  const SizedBox(height: 16),

                  // 2. Current Due Cards (แสดงบิลค้างชำระทั้งหมด โดยเรียงจากเก่าไปใหม่)
                  if (pendingBills.isNotEmpty) ...[
                    ...pendingBills.map((bill) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: CurrentDueCard(
                          dueDate: AppDateUtils.formatDateThai(
                            bill['due_date'],
                          ),
                          amount:
                              (double.tryParse(
                                bill['grand_total']?.toString() ?? '0',
                              ) ??
                              0.0),
                          isOverdue: bill['status'] == 'OVERDUE',
                          isVerifying: bill['status'] == 'WAITING_CONFIRM',
                          isRejected: bill['status'] == 'CANCELLED',
                          onPayPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BillPayPage(billData: bill),
                              ),
                            );

                            // ถ้ามีการจ่ายเงินสำเร็จ (ส่งค่า true กลับมา) ให้รีโหลดข้อมูลใหม่
                            if (result == true) {
                              // หน่วงเวลาเพื่อให้ DB บันทึกเสร็จชัวร์
                              await Future.delayed(const Duration(milliseconds: 800));
                              if (mounted) {
                                setState(() {
                                  _refreshKey++; // เปลี่ยน Key เพื่อบังคับ FutureBuilder สร้างใหม่
                                  _dataFuture = _fetchData();
                                });
                              }
                            }
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],

                  // 3. History List Area (เฉพาะบิล PAID)
                  const Text(
                    'ประวัติย้อนหลัง',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (paidBills.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Center(
                        child: Text(
                          'ไม่มีประวัติการชำระเงิน',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: paidBills.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final data = paidBills[index];
                      final grandTotal =
                          double.tryParse(
                            data['grand_total']?.toString() ?? '0',
                          ) ??
                          0.0;

                      return RecentBillCard(
                        month: AppDateUtils.formatMonthFull(data['bill_month']),
                        amount: grandTotal,
                        statusText: 'ชำระแล้ว',
                        status: BadgeStatus.completed,
                        roomNumber: data['room_number']?.toString() ?? '-',
                        tenantName: 'ID: ${data['user_id'] ?? ''}',
                        dueDate: AppDateUtils.formatDateThai(data['due_date']),
                        paymentDate: AppDateUtils.formatDateThai(
                          data['payment_date'],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
