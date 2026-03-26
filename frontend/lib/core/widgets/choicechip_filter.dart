import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';

class ChoiceChipFilter extends StatelessWidget {
  final Color selectedColor;
  final Color bgColor;
  final OutlinedBorder shape;
  final String label;
  final bool selected;
  final Function(bool)? onSelected;

  const ChoiceChipFilter({
    super.key,
    this.selectedColor = AppColors.primary,
    this.bgColor = Colors.white,
    this.label = 'ใส่ข้อความเป็น lable เช่น Au ei arrr',
    this.shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      side: BorderSide(color: AppColors.border),
    ),
    this.selected = false,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: selected ? Colors.white : AppColors.textSecondary,
        ),
      ),
      selected: selected,
      showCheckmark: false,
      selectedColor: selectedColor,
      backgroundColor: bgColor,
      onSelected: onSelected,
      shape: shape,
    );
  }
}
