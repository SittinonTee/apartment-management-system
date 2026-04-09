import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';

class AdminRepairTicketCard extends StatefulWidget {
  final String title;
  final String categoryName;
  final DateTime date;
  final String statusText;
  final Color statusColor;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  // ข้อมูลส่วนเพิ่มเติมสำหรับแสดงตอนกาง Card ออกมา
  final String description;
  final DateTime? completedAt;
  final String tenantfirstname;
  final String tenantlastname;
  final String roomNumber;
  final String tenantPhone;
  final String mechanicfirstname;
  final String mechaniclastname;
  final String mechanicPhone;

  final int repairId;
  final VoidCallback? onRefresh;

  const AdminRepairTicketCard({
    super.key,
    required this.repairId,
    required this.title,
    required this.categoryName,
    required this.date,
    required this.statusText,
    required this.statusColor,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.description,
    this.completedAt,
    required this.tenantfirstname,
    required this.tenantlastname,
    required this.roomNumber,
    required this.tenantPhone,
    required this.mechanicfirstname,
    required this.mechaniclastname,
    required this.mechanicPhone,
    this.onRefresh,
  });

  @override
  State<AdminRepairTicketCard> createState() => _RepairTicketCardState();
}

class _RepairTicketCardState extends State<AdminRepairTicketCard> {
  // สถานะเก็บว่าการ์ดกางอยู่หรือไม่
  bool isExpanded = false;

  bool get _isUnassigned =>
      widget.mechanicfirstname.trim() == 'ยังไม่ได้มอบหมาย';

  String _formatThaiDate(DateTime dt) {
    const months = [
      '',
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
    return '${dt.day} ${months[dt.month]} ${dt.year + 543}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(20, 0, 0, 0),
            blurRadius: 12,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            // เมื่อกดให้สลับสถานะ กาง/ยุบ
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==========================================================
                // ส่วนหัว (Header) ที่จะแสดงตลอดเวลา
                // ==========================================================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ไอคอนหมวดหมู่ (กล่องซ้าย)
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: widget.iconBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.iconColor,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // ข้อมูลตรงกลาง
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(width: 12),

                              Text(
                                widget.categoryName,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          // ตาม Mockup: รูปคน + ชื่อ - ห้อง
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${widget.tenantfirstname} ${widget.tenantlastname} - ${widget.roomNumber}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // ช่างผู้รับงาน หรือ ข้อความแจ้งเตือนสีแดง
                          Row(
                            children: [
                              Icon(
                                _isUnassigned
                                    ? Icons.info_outline
                                    : Icons.engineering_outlined,
                                size: 14,
                                color: _isUnassigned
                                    ? AppColors.error
                                    : const Color(0xFF2DA985),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _isUnassigned
                                      ? 'ยังไม่ได้มอบหมาย'
                                      : 'ผู้รับงาน: ${widget.mechanicfirstname} ${widget.mechaniclastname}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _isUnassigned
                                        ? AppColors.error
                                        : const Color(0xFF2DA985),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // ป้ายสถานะ และลูกศรชี้ขึ้น/ลง
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: widget.statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            widget.statusText,
                            style: TextStyle(
                              color: widget.statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
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

                // ==========================================================
                // ส่วนรายละเอียด (Expanded Content) ที่จะแสดงเมื่อถูกกาง
                // ==========================================================
                if (isExpanded) ...[
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.border),

                  // รายละเอียดปัญหาที่เจอ (Description)
                  Text(
                    widget.description.isNotEmpty
                        ? widget.description
                        : 'ไม่มีรายละเอียดระบุไว้',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // วันที่รับงาน - วันที่จบงาน
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isUnassigned
                            ? 'ลงเมื่อ: -'
                            : 'ลงเมื่อ: ${_formatThaiDate(widget.date)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (_isUnassigned)
                        const Text(
                          'งานนี้ยังไม่มีผู้รับ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (!_isUnassigned && widget.completedAt != null)
                        Text(
                          'จบงานเมื่อ: ${_formatThaiDate(widget.completedAt!)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2DA985),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // กล่องข้อมูลดิดต่อผู้เช่า
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA), // พื้นหลังสีเทาอ่อน
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ติดต่อผู้เช่า',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.tenantfirstname} ${widget.tenantlastname}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'ห้อง ${widget.roomNumber}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.call_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'เบอร์โทร: ${widget.tenantPhone}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // กล่องข้อมูลติดต่อช่าง (แสดงเมื่อมีช่างแล้ว)
                  if (!_isUnassigned)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ติดต่อช่าง',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.mechanicfirstname.isNotEmpty
                                    ? '${widget.mechanicfirstname} ${widget.mechaniclastname}'
                                    : 'ยังไม่ระบุช่าง',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.call_outlined,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'เบอร์โทร: ${widget.mechanicPhone}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  // กล่องแจ้งเตือนเมื่อยังไม่มีผู้รับงาน (Mockup สีแดงด้านล่าง)
                  if (_isUnassigned)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.error, width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ยังไม่มีผู้รับคำขอนี้',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.error,
                                ),
                              ),
                              Text(
                                'กำลังรอช่างเทคนิครับคำขอ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
