import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/date_utils.dart';
import 'package:intl/intl.dart';
import 'bill_pay_qr_page.dart';

class BillPayPage extends StatelessWidget {
  final Map<String, dynamic> billData;

  const BillPayPage({super.key, required this.billData});

  @override
  Widget build(BuildContext context) {
    // 1. ดึงข้อมูล
    final billsId = billData['bills_id']?.toString() ?? '0000';
    final invoiceNo = billsId.padLeft(10, '0'); // สมมติ format 10 หลัก
    
    final createdDate = AppDateUtils.formatDateThaiPadded(billData['created_at']);
    final dueDate = AppDateUtils.formatDateThaiPadded(billData['due_date']);
    final shortMonth = AppDateUtils.formatMonthYearShort(billData['bill_month']);
    final roomNumber = billData['room_number']?.toString() ?? '-';

    // 2. ข้อมูลตัวเลขราคา และค่าไฟ ค่าน้ำ จาก Database โดยตรง
    double roomPrice = double.tryParse(billData['room_total']?.toString() ?? '0') ?? 0.0;
    double waterPrice = double.tryParse(billData['water_total']?.toString() ?? '0') ?? 0.0;
    double electricPrice = double.tryParse(billData['electric_total']?.toString() ?? '0') ?? 0.0;
    final grandTotal = double.tryParse(billData['grand_total']?.toString() ?? '0') ?? 0.0;
    
    // ถ้าบางบิลไม่มีข้อมูลการแยกประเภทแต่ให้ grandTotal มา
    if (roomPrice == 0 && waterPrice == 0 && electricPrice == 0 && grandTotal > 0) {
      roomPrice = grandTotal;
    }

    // 3. ข้อมูลมิเตอร์
    // ในฐานข้อมูลอาจจะส่งมาแค่ water_used / electric_used เลย หรืออาจจะมี start/end คู่มาด้วย
    int wDiff = int.tryParse(billData['water_used']?.toString() ?? '0') ?? 0;
    int wStart = int.tryParse(billData['water_unit_start']?.toString() ?? '0') ?? 0;
    int wEnd = int.tryParse(billData['water_unit_end']?.toString() ?? '0') ?? 0;
    if (wDiff == 0 && wEnd > wStart) wDiff = wEnd - wStart;

    int eDiff = int.tryParse(billData['electric_used']?.toString() ?? '0') ?? 0;
    int eStart = int.tryParse(billData['electric_unit_start']?.toString() ?? '0') ?? 0;
    int eEnd = int.tryParse(billData['electric_unit_end']?.toString() ?? '0') ?? 0;
    if (eDiff == 0 && eEnd > eStart) eDiff = eEnd - eStart;


    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ใบแจ้งหนี้',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    // Main Invoice Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ส่วนหัวบิลเลขที่
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'ใบแจ้งหนี้เลขที่ $invoiceNo',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Divider(height: 1, color: Colors.grey.shade300),
                          
                          // วันที่ออกและกำหนดชำระ
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('วันที่ออกใบแจ้งหนี้', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                    const SizedBox(height: 4),
                                    Text(createdDate, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('วันครบกำหนดชำระ', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                    const SizedBox(height: 4),
                                    Text(dueDate, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Divider(height: 1, color: Colors.grey.shade300),
                          
                          // รายละเอียด
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('รายละเอียด', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
                                
                                // 1. ค่าห้อง
                                _buildInvoiceItem(
                                  icon: Icons.keyboard_arrow_down_rounded,
                                  title: 'ค่าเช่าห้อง / Room Charge',
                                  subtitle: '(inv.)\n$shortMonth | ห้อง $roomNumber',
                                  price: roomPrice,
                                ),

                                // 2. ค่าไฟฟ้่า
                                _buildInvoiceItem(
                                  icon: Icons.keyboard_arrow_down_rounded,
                                  title: 'ค่าไฟฟ้า / Thunder Charge',
                                  subtitle: '(inv.)\n$shortMonth | $roomNumber : $eEnd - $eStart = $eDiff',
                                  price: electricPrice,
                                ),

                                // 3. ค่าน้ำประปา
                                _buildInvoiceItem(
                                  icon: Icons.keyboard_arrow_down_rounded,
                                  title: 'ค่าน้ำประปา / Water Charge',
                                  subtitle: '(inv.)\n$shortMonth | $roomNumber : $wEnd - $wStart = $wDiff',
                                  price: waterPrice,
                                ),
                              ],
                            ),
                          ),

                          Divider(height: 1, color: Colors.grey.shade300),
                          
                          // รวมสุทธิ และ ยอดที่ต้องชำระ
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('รวมสุทธิ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                    Text('${NumberFormat.decimalPattern().format(grandTotal)} บาท', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('ยอดที่ต้องชำระ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)),
                                    Text('${NumberFormat.decimalPattern().format(grandTotal)} บาท', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // ปุ่มชำระบิลด้านล่าง
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.background,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  )
                ]
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BillPayQrPage(billData: billData),
                      ),
                    );

                    // ถ้าจ่ายสำเร็จจากหน้า QR ให้ปิดหน้านี้และส่ง true กลับไปหน้าหลัก
                    if (result == true) {
                      if (context.mounted) {
                        Navigator.pop(context, true);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'ชำระบิล',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required double price,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black87, width: 2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 20, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, height: 1.5, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${NumberFormat.decimalPattern().format(price)} บาท',
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
