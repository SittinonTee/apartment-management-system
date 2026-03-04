import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

// ตระกูล Display (ใหญ่สุด): displayLarge, displayMedium, displaySmall
// ตระกูล Headline (หัวข้อหลัก): headlineLarge, headlineMedium, headlineSmall
// ตระกูล Title (หัวข้อย่อย/ชื่อการ์ด): titleLarge, titleMedium, titleSmall
// ตระกูล Body (เนื้อหา): bodyLarge, bodyMedium, bodySmall
// ตระกูล Label (ปุ่ม/คำอธิบายเล็ก ๆ): labelLarge, labelMedium, labelSmall

// ตัวอย่างการใช้
// style: Theme.of(context).textTheme.titleLarge,

class AppTypography {
  static TextTheme get textTheme {
    return GoogleFonts.promptTextTheme().copyWith(
      displayLarge: GoogleFonts.prompt(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      displayMedium: GoogleFonts.prompt(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      displaySmall: GoogleFonts.prompt(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      headlineMedium: GoogleFonts.prompt(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleLarge: GoogleFonts.prompt(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleMedium: GoogleFonts.prompt(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.prompt(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.prompt(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      bodySmall: GoogleFonts.prompt(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      labelLarge: GoogleFonts.prompt(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textInverse,
      ),
    );
  }
}
