import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/widgets/custom_button.dart';

class SearchWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String buttonLabel;
  final VoidCallback? onSearch;

  const SearchWidget({
    super.key,
    required this.controller,
    this.hintText = 'ค้นหาผู้เช่าด้วย เลขห้อง หรือชื่อผู้เช่า...',
    this.buttonLabel = 'ค้นหา',
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    void doSearch() {
      FocusScope.of(context).unfocus();
      onSearch?.call();
    }

    OutlineInputBorder myBorder(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: 1.5),
    );

    // ดึง textTheme จาก Theme ที่ set ไว้ใน AppTypography
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      child: TextField(
        controller: controller,
        textAlignVertical: TextAlignVertical.center,
        onSubmitted: (_) => doSearch(),
        style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.surface,
          hoverColor: AppColors.surface,
          focusColor: AppColors.surface,
          hintText: hintText,
          hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textHint),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 14, right: 4),
            child: Icon(Icons.search, color: AppColors.textHint, size: 28),
          ),

          border: myBorder(AppColors.border),
          enabledBorder: myBorder(AppColors.border),
          focusedBorder: myBorder(AppColors.primary),

          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 10, top: 6, bottom: 6),
            child: CustomButton(
              text: buttonLabel,
              onPressed: doSearch,
              icon: null,
              width: 65,
              textStyle: textTheme.bodyLarge?.copyWith(
                color: AppColors.textInverse,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
