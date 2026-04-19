import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/core/widgets/searchbar.dart';
import 'package:frontend/core/widgets/choicechip_filter.dart';
import 'package:frontend/core/widgets/status_badge.dart';
import 'package:frontend/features/admin/bills/presentation/Bills_widgets/admin_bill_card.dart';

import 'package:frontend/features/admin/bills/data/get_bills.dart';

class AdminBillsPage extends StatefulWidget {
  const AdminBillsPage({super.key});

  @override
  State<AdminBillsPage> createState() => _AdminBillsPageState();
}

class _AdminBillsPageState extends State<AdminBillsPage> {
  String searchQuery = '';
  int selectedMonthIndex = 0;
  final List<String> monthList = [
    'ทั้งหมด',
    'ม.ค.',
    'ก.พ.',
    'มี.ค.',
    'เม.ย.',
    'พ.ค.',
    'มิ.ย.',
    'ก.ค.',
    'ส.ค.',
    'ก.ย.',
    'ต.ค.',
    'พ.ย.',
    'ธ.ค.',
  ];

  final List<String> monthfull = [
    'มกราคม',
    'กุมภาพันธ์',
    'มีนาคม',
    'เมษายน',
    'พฤษภาคม',
    'มิถุนายน',
    'กรกฎาคม',
    'สิงหาคม',
    'กันยายน',
    'ตุลาคม',
    'พฤศจิกายน',
    'ธันวาคม',
  ];

  late Future<List<BillModel>> _billsFuture;

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  void _loadBills() {
    // โหลดข้อมูลบิลผ่าน Service ใน initState
    _billsFuture = BillsService().getBills();
  }

  // ฟังก์ชันจำลองการแปลง Status จาก Backend เป็น Enum BadgeStatus
  BadgeStatus _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
      case 'paid':
        return BadgeStatus.completed;
      case 'urgent':
      case 'overdue':
        return BadgeStatus.urgent;
      case 'pending':
      default:
        return BadgeStatus.pending;
    }
  }

  // ฟังก์ชันตั้งชื่อป้ายกำกับ
  String _mapStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
      case 'paid':
        return 'ชำระสำเร็จ';
      case 'urgent':
      case 'overdue':
        return 'เลยกำหนด';
      case 'pending':
      default:
        return 'ค้างชำระ';
    }
  }

  // ฟังก์ชันจัดรูปแบบวันที่แบบย่อไทย
  String _formatDate(DateTime date) {
    return '${date.day} ${monthfull[date.month - 1]} ${date.year + 543}';
  }

  Future<void> _confirmBill(int billId) async {
    // แสดง Dialog ยืนยันก่อนดำเนินการ
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการชำระเงิน'),
          content: const Text('คุณแน่ใจหรือไม่ว่าต้องการยืนยันการชำระเงินสำหรับบิลนี้?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('ยกเลิก', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('ยืนยัน', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        );
      },
    );

    if (confirm != true) return;

    final success = await BillsService().confirmBill(billId);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ยืนยันการชำระเงินสำเร็จ'),
          backgroundColor: AppColors.success,
        ),
      );
      setState(() {
        _loadBills();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เกิดข้อผิดพลาดในการยืนยันการชำระเงิน'),
          backgroundColor: AppColors.error,
        ),
      );
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bills',
                style: textTheme.displayLarge?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  CustomButton(
                    isPrimary: false,
                    isOutlined: true,
                    onPressed: () {
                      context.read<AuthService>().logout();
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
          Text(
            "รายการบิลค่าเช่า",
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          SearchWidget(
            onSearch: (value) {
              setState(() {
                searchQuery = value;
                // หากต้องการค้นหาฝั่ง API ใหม่ตรงนี้ ให้เลิกคอมเมนต์ด้านล่าง
                // _loadBills();
              });
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 40,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: monthList.length,
              itemBuilder: (context, i) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChipFilter(
                    label: monthList[i],
                    selected: selectedMonthIndex == i,
                    onSelected: (_) {
                      setState(() {
                        selectedMonthIndex = i;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<BillModel>>(
              future: _billsFuture,
              builder: (context, snapshot) {
                // ระหว่างโหลด API
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // กรณีเรียก API แล้วเกิด Error เช่น พอร์ตผิด หรือ Network มีปัญหา
                else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'เกิดข้อผิดพลาดในการโหลดข้อมูลบิล\n(${snapshot.error})',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  );
                }
                // กรณีไม่มีข้อมูลถูกส่งมาจากหลังบ้านเลย
                else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'ไม่มีรายการบิลค่าเช่า',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                // --------- ดึงข้อมูลที่ได้มามาแสดงผลเป็นรายการ ----------
                List<BillModel> bills = snapshot.data!;

                // 1. กรองตามข้อความที่พิมพ์ค้นหา
                if (searchQuery.isNotEmpty) {
                  bills = bills
                      .where(
                        (b) =>
                            b.roomNumber.contains(searchQuery) ||
                            b.tenantName.contains(searchQuery),
                      )
                      .toList();
                }

                // 2. กรองตาม "เดือนที่กดเลือก" (ชิปด้านบน)
                // index 0 คือ 'ทั้งหมด' ดังนั้นดึงทุกอัน, ถ้า index เบอร์อื่น ให้ดึงแค่บิลของเดือนนั้น
                if (selectedMonthIndex != 0) {
                  bills = bills
                      .where((b) => b.dueDate.month == selectedMonthIndex)
                      .toList();
                }

                // 3. จัดกลุ่มบิลตามเดือน
                Map<int, List<BillModel>> groupedBills = {};
                for (var bill in bills) {
                  int m = bill.dueDate.month;
                  groupedBills.putIfAbsent(m, () => []).add(bill);
                }

                // สั่งเรียงเดือนจาก ล่าสุดไปเก่าสุด หรือตามลำดับในลิสต์ 1-12
                List<int> sortedMonths = groupedBills.keys.toList()..sort();

                if (sortedMonths.isEmpty) {
                  return const Center(
                    child: Text(
                      'ไม่พบรายการบิลค่าเช่าในเดือนที่เลือก',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                // 4. สร้าง ListView ที่แต่ละ Item เป็นกลุ่มของเดือนๆ นั้น
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: sortedMonths.length,
                  itemBuilder: (context, groupIndex) {
                    int currentMonth = sortedMonths[groupIndex];
                    List<BillModel> monthBills = groupedBills[currentMonth]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- 4.1 ส่วนหัวบอกชื่อเดือน (ป้าย มกราคม ฯลฯ) ---
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: 16,
                            top: groupIndex == 0
                                ? 8
                                : 24, // ให้ห่างจากกลุ่มด้านบนถ้าไม่ใช่เดือนแรก
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_month_outlined,
                                size: 28,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                monthfull[currentMonth - 1],
                                style: textTheme.titleLarge?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // --- 4.2 ส่วนแสดงการ์ดบิลทีละใบในเดือนนั้น ---
                        ...monthBills.map((bill) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AdminBillCard(
                              billId: bill.billId,
                              roomNumber: bill.roomNumber,
                              tenantName: bill.tenantName,
                              amount: bill.amount.toString(),
                              status: _mapStatus(bill.status),
                              statusText: _mapStatusText(bill.status),
                              dueDate: _formatDate(bill.dueDate),
                              payDate: bill.payDate != null
                                  ? _formatDate(bill.payDate!)
                                  : null,
                              payMethod: bill.payMethod,
                              slipImageUrl: bill.slipImageUrl,
                              onConfirm: () => _confirmBill(bill.billId),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
