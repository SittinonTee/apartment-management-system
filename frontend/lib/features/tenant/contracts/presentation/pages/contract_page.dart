import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/choicechip_filter.dart';

class ContractPage extends StatefulWidget {
  const ContractPage({super.key});

  @override
  State<ContractPage> createState() => _ContractPageState();
}

class _ContractPageState extends State<ContractPage> {
  int _selectedIndex = 0;
  final List<String> _categories = ['ทั้งหมด', 'สำเร็จ', 'กำลังรอ', 'สิ้นสุด'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildFilterBar(),
            const Expanded(child: Center(child: Text('Contract Content Here'))),
          ],
        ),
      ),
    );
  }

  /// ส่วนหัวข้อหน้าจอ
  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'สัญญาของฉัน',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'ตรวจสอบรายละเอียดสัญญาของคุณที่นี่',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  /// ส่วนแถบเลือกหมวดหมู่ (Filter)
  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final isSelected = _selectedIndex == index;
            return ChoiceChipFilter(
              label: _categories[index],
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedIndex = index);
              },
              selectedColor: AppColors.primaryLight,
              bgColor: Colors.white,
              shape: _getChipShape(isSelected),
            );
          },
        ),
      ),
    );
  }

  /// ตัวช่วยจัดการเส้นขอบของ Chip
  OutlinedBorder _getChipShape(bool isSelected) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(100),
      side: isSelected
          ? BorderSide.none
          : const BorderSide(color: AppColors.border, width: 1),
    );
  }
}
