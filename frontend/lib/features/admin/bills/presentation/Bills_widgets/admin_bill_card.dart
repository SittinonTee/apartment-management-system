import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/widgets/section_card.dart';
import 'package:frontend/core/widgets/status_badge.dart';

// ---------------------------------------------------------------------------
// AdminBillCard: วิดเจ็ตสำหรับแสดงการ์ดรายการบิล 1 รายการ
// รองรับการกดเพื่อกางออก (Expand) และยุบ (Collapse) ดูรายละเอียดบิล
// ---------------------------------------------------------------------------
class AdminBillCard extends StatefulWidget {
  final int billId;
  final String roomNumber; // หมายเลขห้อง เช่น "A329"
  final String tenantName; // ชื่อผู้เช่า
  final BadgeStatus
  status; // สถานะของบิล (pending, completed, urgent) เพื่อกำหนดอารมณ์สี
  final String statusText; // ข้อความสถานะที่จะแสดงในป้ายแบดจ์ เช่น "ค้างชำระ"
  final String amount; // จำนวนเงินยอดชำระ
  final String dueDate; // วันครบกำหนดชำระ
  final String?
  payDate; // วันที่ฝั่งผู้เช่าชำระเงินเข้ามา (อาจเป็น null ได้ถ้ายังไม่จ่าย)
  final String? payMethod; // วิธีการชำระเงิน (เช่น "บัตรเครดิต")
  final String? slipImageUrl;
  final VoidCallback? onConfirm;
  final bool
  initialExpanded; // กำหนดว่าตอนโหลดมาครั้งแรก จะกางการ์ดนี้ไว้เลยหรือไม่

  const AdminBillCard({
    super.key,
    required this.billId,
    required this.roomNumber,
    required this.tenantName,
    required this.status,
    required this.statusText,
    required this.amount,
    required this.dueDate,
    this.payDate,
    this.payMethod,
    this.slipImageUrl,
    this.onConfirm,
    this.initialExpanded = false,
  });

  @override
  State<AdminBillCard> createState() => _AdminBillCardState();
}

class _AdminBillCardState extends State<AdminBillCard> {
  // state สำหรับเก็บว่าตอนนี้การ์ดกำลัง "กางอยู่" หรือ "ยุบอยู่"
  late bool isExpanded;

  @override
  void initState() {
    super.initState();
    // กำหนดค่าเริ่มต้นตอนสร้างวิดเจ็ต ว่าจะให้กางหรือยุบ
    isExpanded = widget.initialExpanded;
  }

  // ฟังก์ชันช่วยหา "สีพื้นหลังของไอคอน" ตามสถานะของบิล
  Color _getIconBgColor() {
    switch (widget.status) {
      case BadgeStatus.pending: // สถานะรอ (ส้มจางๆ)
        return AppColors.warning.withValues(alpha: 0.15);
      case BadgeStatus.completed: // สถานะสำเร็จ (เขียวจางๆ)
        return AppColors.success.withValues(alpha: 0.15);
      case BadgeStatus.urgent: // สถานะด่วน/เกินกำหนด (แดงจางๆ)
      case BadgeStatus.info:
        return AppColors.error.withValues(alpha: 0.15);
    }
  }

  // ฟังก์ชันช่วยหา "สีของตัวไอคอน" ตามสถานะของบิล
  Color _getIconColor() {
    switch (widget.status) {
      case BadgeStatus.pending:
        return AppColors.warning;
      case BadgeStatus.completed:
        return AppColors.success;
      case BadgeStatus.urgent:
      case BadgeStatus.info:
        return AppColors.error;
    }
  }

  // ฟังก์ชันช่วยหา "รูปไอคอน" ตามสถานะของบิล
  IconData _getIconData() {
    switch (widget.status) {
      case BadgeStatus.pending:
        return Icons.access_time; // รูปนาฬิกา
      case BadgeStatus.completed:
        return Icons.check_circle_outline; // รูปติ๊กถูก
      case BadgeStatus.urgent:
      case BadgeStatus.info:
        return Icons.warning_amber_rounded; // รูปตกใจกระพริบ
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // เราใช้ SectionCard เป็นกรอบหลักของการ์ด เพื่อให้ดึงเงามาตรฐานมาใช้
    return SectionCard(
      padding: const EdgeInsets.all(16),
      shadow: true, // เปิดใช้งานเงา (Shadow)
      child: Container(
        color: Colors.transparent, // ป้องกันบั๊ก Container ทับสีพื้นหลัง
        child: Column(
          children: [
            // ==============================================================
            // ส่วนที่ 1: Header Row (แถวข้อมูลหลักที่โชว์ตลอดเวลา)
            // ห่อด้วย InkWell เพื่อให้เมื่อผู้ใช้จับกดบริเวณนี้แล้วเกิดเอฟเฟกต์คลิก
            // ==============================================================
            InkWell(
              onTap: () {
                // เมื่อกดที่การ์ด ให้สลับค่า isExpanded ไปมาระหว่าง ยุบ <-> กาง
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1.1 ไอคอนวงกลมหน้าสุด (แสดงสถานะรูปนาฬิกา, เครื่องหมายถูก)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color:
                          _getIconBgColor(), // ดึงสีพื้นหลังจากฟังก์ชันด้านบน
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconData(), // ดึงรูปไอคอนจากฟังก์ชันด้านบน
                      color: _getIconColor(), // ดึงสีไอคอนจากฟังก์ชันด้านบน
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // 1.2 ข้อมูลกลางการ์ด (หมายเลขห้อง และ ชื่อผู้เช่า)
                  // ใช้ Expanded เพื่อให้มันกินพื้นที่ว่างตรงกลางที่เหลือทั้งหมด
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ข้อความเลขห้อง
                        Text(
                          'ห้อง ${widget.roomNumber}',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // ข้อความชื่อผู้เช่า พร้อมไอคอนตึกเล็กๆ
                        Row(
                          children: [
                            const Icon(
                              Icons.domain,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'ผู้เช่า: ${widget.tenantName}',
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 1.3 กรอบฝั่งขวาสุด (ป้ายสถานะ Badge และ ลูกศรชี้ขึ้น/ลง)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // เรีนกใช้ StatusBadge ที่เรามีใน core/widgets
                      StatusBadge(
                        text: widget.statusText,
                        status: widget.status,
                      ),
                      const SizedBox(height: 8),
                      // ไอคอนลูกศรเปลี่ยนทิศทางตามสถานะการกาง (isExpanded)
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ==============================================================
            // ส่วนที่ 2: Expanded Details (รายละเอียดเพิ่มเติมที่จะโชว์เมื่อกางออก)
            // ==============================================================
            if (isExpanded) ...[
              const SizedBox(height: 16),
              const Divider(color: AppColors.border), // เส้นคั่นบางๆ
              const SizedBox(height: 16),

              // ใช้ฟังก์ชัน _buildDetailRow สร้างแต่ละบรรทัดเพื่อไม่ให้โค้ดซ้ำซ้อน
              _buildDetailRow(
                'จำนวนเงินที่ต้องชำระ',
                '${widget.amount} บาท',
                true, // ให้เน้นสีเข้มและใหญ่ขึ้นสำหรับค่าเงิน
                textTheme,
              ),
              const SizedBox(height: 8),
              _buildDetailRow('กำหนดชำระ', widget.dueDate, false, textTheme),
              const SizedBox(height: 8),
              // ถ้า payDate เป็น null ให้แสดง '-'
              _buildDetailRow(
                'ชำระเมื่อ',
                widget.payDate ?? '-',
                false,
                textTheme,
              ),
              const SizedBox(height: 8),
              // ส่งค่า isMethod = true เข้าไป เพื่อให้มันวาดไอคอนบัตรเครดิตให้ (ถ้ามีข้อมูล)
              _buildDetailRow(
                'วิธีชำระ',
                widget.payMethod ?? '-',
                false,
                textTheme,
                isMethod: true,
              ),

              // ส่วนที่เพิ่ม: แสดงรูปภาพใบเสร็จ (ถ้ามี)
              if (widget.slipImageUrl != null && widget.slipImageUrl!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(color: AppColors.border),
                const SizedBox(height: 12),
                Text(
                  'หลักฐานการโอนเงิน',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.slipImageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, color: AppColors.error),
                            SizedBox(height: 4),
                            Text('โหลดรูปภาพไม่สำเร็จ',
                                style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],

              // ส่วนที่เพิ่ม: ปุ่มยืนยันการจ่ายเงิน (โชว์เฉพาะเมื่อสถานะเป็น pending และมีรูปสลิป)
              if (widget.status == BadgeStatus.pending &&
                  widget.slipImageUrl != null &&
                  widget.slipImageUrl!.isNotEmpty) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'ยืนยันการจ่ายเงิน',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  // ==============================================================================
  // _buildDetailRow: ฟังก์ชันช่วยสร้าง "1 บรรทัด" ในส่วนรายละเอียดด้านล่าง
  // ใช้สำหรับแสดงข้อมูลแบบ ขวา-ซ้าย (Label อยู่ซ้าย, Value อยู่ขวา)
  // ==============================================================================
  Widget _buildDetailRow(
    String label, // คำบรรยายฝั่งซ้าย (เช่น "จำนวนเงินที่ต้องชำระ")
    String value, // ข้อมูลฝั่งขวา (เช่น "8,600 บาท")
    bool isHighlight, // ค่าความจริงว่าจะให้ทำไฮไลต์ให้ตัวหนา/สีเข้มขึ้นไหม
    TextTheme textTheme, {
    bool isMethod = false, // ค่าสำหรับเช็คว่าเป็นบรรทัด "วิธีชำระเงิน" หรือไม่
  }) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween, // ดันซ้ายและขวาให้ห่างกันสุด
      children: [
        // ข้อความฝั่งซ้าย (Label)
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            // ถ้าเป็น Highlight จะสีเข้ม, ถ้าไม่ใช่จะเป็นสีจางๆ
            color: isHighlight
                ? AppColors.textSecondary
                : AppColors.textSecondary.withValues(alpha: 0.8),
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
          ),
        ),

        // ข้อมูลฝั่งขวา (Value)
        Row(
          children: [
            // ถ้าบรรทัดนี้คือบรรทัด 'วิธีชำระเงิน' และไม่ได้ว่างเปล่า (-) ให้วาดไอคอนบัตรเครดิตด้วย
            if (isMethod && value != '-') ...[
              const Icon(
                Icons.credit_card,
                size: 16,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 4),
            ],
            // ข้อความตัวอักษรฝั่งขวา
            Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                fontSize: isHighlight ? 16 : 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
