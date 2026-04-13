import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../data/repair_model.dart';

class AcceptJobDialog extends StatefulWidget {
  final RepairRequest repair;
  final bool isLoading;
  final Function(DateTime) onConfirm;

  const AcceptJobDialog({
    super.key,
    required this.repair,
    required this.isLoading,
    required this.onConfirm,
  });

  @override
  State<AcceptJobDialog> createState() => _AcceptJobDialogState();
}

class _AcceptJobDialogState extends State<AcceptJobDialog> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  String _formatThaiDate(DateTime date) {
    final months = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year + 543}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header และปุ่มปิด
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'รายละเอียดการซ่อม',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (!widget.isLoading)
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // ข้อมูลย่อ
            _buildPopupRow('ต้องการให้ :', widget.repair.title),
            _buildPopupRow('ประเภท :', widget.repair.categoryName ?? 'อื่นๆ'),
            _buildPopupRow('ห้อง :', '${widget.repair.roomNumber ?? '-'}  ชั้น: ${widget.repair.roomFloor ?? '-'}'),
            _buildPopupRow('อาคาร :', 'A'),
            _buildPopupRow('สะดวกที่ :', widget.repair.preferredTime ?? 'ไม่ระบุ'),
            const SizedBox(height: 24),

            // การเลือกวันที่
            const Text(
              'เลือกวันที่ที่จะเข้ามาทำงาน',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildDatePicker(context),
            const SizedBox(height: 32),

            // ปุ่มแอคชั่น
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: widget.isLoading
          ? null
          : () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF5AB6A9),
                      onPrimary: Colors.white,
                      onSurface: Colors.black,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) {
                setState(() => selectedDate = picked);
              }
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatThaiDate(selectedDate),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            const Icon(Icons.calendar_month_outlined, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'ยกเลิก',
            isOutlined: true,
            onPressed: widget.isLoading ? () {} : () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : () => widget.onConfirm(selectedDate),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5AB6A9),
              disabledBackgroundColor: const Color(0xFF5AB6A9).withValues(alpha: 0.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('ยืนยัน', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildPopupRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
