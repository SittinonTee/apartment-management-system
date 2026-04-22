import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/widgets/searchbar.dart';
import 'package:frontend/core/widgets/choicechip_filter.dart';
import 'package:frontend/core/widgets/status_badge.dart';
import 'package:frontend/features/admin/bills/presentation/Bills_widgets/admin_bill_card.dart';
import 'package:frontend/core/widgets/month_year_filter.dart';

import 'package:frontend/features/admin/bills/data/get_bills.dart';

class AdminBillsPage extends StatefulWidget {
  const AdminBillsPage({super.key});

  @override
  State<AdminBillsPage> createState() => _AdminBillsPageState();
}

class _AdminBillsPageState extends State<AdminBillsPage> {
  String searchQuery = '';
  int? selectedMonth;
  int? selectedYear;
  String selectedStatus = 'ทั้งหมด';

  final List<String> statusList = [
    'ทั้งหมด',
    'รอยืนยัน',
    'ค้างชำระ',
    'ชำระสำเร็จ',
    'เลยกำหนด',
    'ยกเลิก',
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
  int _refreshKey = 0; // เพิ่มตัวแปรสำหรับคุมการรีเฟรชหน้าจอแอดมิน

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
        return BadgeStatus.pending;
      case 'cancelled':
        return BadgeStatus.cancelled;
      case 'waiting_confirm':
        return BadgeStatus.verifying;
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
        return 'ค้างชำระ';
      case 'cancelled':
        return 'ยกเลิก';
      case 'waiting_confirm':
        return 'รอยืนยัน';
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
          content: const Text(
            'คุณแน่ใจหรือไม่ว่าต้องการยืนยันการชำระเงินสำหรับบิลนี้?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'ยกเลิก',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'ยืนยัน',
                style: TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
      // หน่วงเวลาเล็กน้อยเพื่อให้ DB อัปเดตข้อมูล View เสร็จสมบูรณ์
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _refreshKey++; // เปลี่ยน Key เพื่อบังคับรีโหลดใหม่
          _loadBills();
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เกิดข้อผิดพลาดในการยืนยันการชำระเงิน'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _rejectBill(int billId) async {
    // แสดง Dialog ยืนยันก่อนปฏิเสธ
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ปฏิเสธการชำระเงิน'),
          content: const Text(
            'คุณแน่ใจหรือไม่ว่าต้องการปฏิเสธการชำระเงินนี้? ข้อมูลสลิปจะถูกลบทิ้งและบิลจะกลับเป็นสถานะค้างชำระ',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'ยกเลิก',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'ยืนยันการปฏิเสธ',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );

    if (confirm != true) return;

    final success = await BillsService().rejectBill(billId);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ปฏิเสธการชำระเงินเรียบร้อยแล้ว'),
          backgroundColor: AppColors.warning,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _refreshKey++;
          _loadBills();
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เกิดข้อผิดพลาดในการปฏิเสธการชำระเงิน'),
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
          const SizedBox(height: 16),
          MonthYearFilter(
            selectedMonth: selectedMonth,
            selectedYear: selectedYear,
            onChanged: (month, year) {
              setState(() {
                selectedMonth = month;
                selectedYear = year;
              });
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: statusList.length,
              itemBuilder: (context, i) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChipFilter(
                    label: statusList[i],
                    selected: selectedStatus == statusList[i],
                    onSelected: (_) {
                      setState(() {
                        selectedStatus = statusList[i];
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
              key: ValueKey(_refreshKey), // บังคับ Rebuild เมื่อ Key เปลี่ยน
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

                // 2. กรองตาม "เดือนและปีที่เลือก"
                if (selectedMonth != null) {
                  bills = bills
                      .where((b) => b.dueDate.month == selectedMonth)
                      .toList();
                }
                if (selectedYear != null) {
                  bills = bills
                      .where((b) => b.dueDate.year == selectedYear)
                      .toList();
                }

                // 3. กรองตาม "สถานะ"
                if (selectedStatus != 'ทั้งหมด') {
                  bills = bills.where((b) {
                    final text = _mapStatusText(b.status);
                    return text == selectedStatus;
                  }).toList();
                }

                // 4. จัดกลุ่มบิลตามเดือนและปี
                Map<String, List<BillModel>> groupedBills = {};
                for (var bill in bills) {
                  String key = "${bill.dueDate.year}-${bill.dueDate.month}";
                  groupedBills.putIfAbsent(key, () => []).add(bill);
                }

                // เรียงลำดับกลุ่มบิล (ปี-เดือน) จากล่าสุดไปเก่าสุด
                List<String> sortedKeys = groupedBills.keys.toList()
                  ..sort((a, b) {
                    // เรียงจากค่ามากไปหาน้อย (ล่าสุดไปเก่าสุด)
                    return b.compareTo(a);
                  });

                if (sortedKeys.isEmpty) {
                  return const Center(
                    child: Text(
                      'ไม่พบรายการบิลค่าเช่าตามเงื่อนไขที่เลือก',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                // 5. สร้าง ListView ที่แต่ละ Item เป็นกลุ่มของเดือนๆ นั้น
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: sortedKeys.length,
                  itemBuilder: (context, groupIndex) {
                    String currentKey = sortedKeys[groupIndex];
                    List<int> parts = currentKey
                        .split('-')
                        .map(int.parse)
                        .toList();
                    int year = parts[0];
                    int month = parts[1];
                    List<BillModel> monthBills = groupedBills[currentKey]!;

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
                                '${monthfull[month - 1]} ${year + 543}',
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
                              approvedBy: bill.approvedBy,
                              onConfirm: () => _confirmBill(bill.billId),
                              onReject: () => _rejectBill(bill.billId),
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
