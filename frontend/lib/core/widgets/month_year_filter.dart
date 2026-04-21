import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class MonthYearFilter extends StatelessWidget {
  final int? selectedMonth;
  final int? selectedYear;
  final Function(int? month, int? year) onChanged;

  const MonthYearFilter({
    super.key,
    this.selectedMonth,
    this.selectedYear,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> months = [
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
    ];

    final int currentYear = DateTime.now().year;
    final List<int> years = List.generate(5, (index) => currentYear - index);

    return Row(
      children: [
        // Dropdown เลือกเดือน
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: selectedMonth,
                hint: const Text('เดือน', style: TextStyle(color: AppColors.textHint)),
                isExpanded: true,
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('ทุกเดือน'),
                  ),
                  ...List.generate(months.length, (index) {
                    return DropdownMenuItem<int>(
                      value: index + 1,
                      child: Text(months[index]),
                    );
                  }),
                ],
                onChanged: (value) => onChanged(value, selectedYear),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Dropdown เลือกปี
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: selectedYear,
                hint: const Text('ปี', style: TextStyle(color: AppColors.textHint)),
                isExpanded: true,
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('ทุกปี'),
                  ),
                  ...years.map((year) {
                    return DropdownMenuItem<int>(
                      value: year,
                      child: Text('${year + 543}'), // แสดงเป็น พ.ศ.
                    );
                  }),
                ],
                onChanged: (value) => onChanged(selectedMonth, value),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
