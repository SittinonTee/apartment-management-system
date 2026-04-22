import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/status_badge.dart';
import '../../../../../core/utils/date_utils.dart';

class ContractUtils {
  // แปลง ISO Date กลับมาเป็นภาษาไทยแบบย่อ — delegate ไป core AppDateUtils
  static String formatDateThai(String? dateStr) => AppDateUtils.formatDateThai(dateStr);

  // แปลงสถานะ DB เป็น BadgeStatus เพื่อสี UI
  static BadgeStatus mapStatusToBadge(String? dbStatus) {
    switch (dbStatus?.toUpperCase()) {
      case 'ACTIVE':
        return BadgeStatus.completed; // สีเขียว
      case 'INACTIVE':
        return BadgeStatus.pending; // สีเหลือง
      case 'EXPIRED':
        return BadgeStatus.info; // สีฟ้าเทา
      case 'TERMINATED':
        return BadgeStatus.urgent; // สีแดง
      case 'CANCELLED':
        return BadgeStatus.cancelled; // สีเทา
      default:
        return BadgeStatus.info;
    }
  }

  // แปลงสถานะ DB เป็นข้อความภาษาไทย
  static String mapStatusToText(String? dbStatus) {
    switch (dbStatus?.toUpperCase()) {
      case 'ACTIVE':
        return 'ใช้งานอยู่';
      case 'INACTIVE':
        return 'กำลังรอ';
      case 'EXPIRED':
        return 'สิ้นสุด';
      case 'TERMINATED':
      case 'CANCELLED':
        return 'ยกเลิก';
      default:
        return 'ไม่ทราบสถานะ';
    }
  }

  // แปลงสถานะข้อความแบนเนอร์เต็มๆ ในหน้า Detail
  static String getStatusBannerText(String? dbStatus) {
    switch (dbStatus?.toUpperCase()) {
      case 'ACTIVE':
        return 'สัญญาฉบับนี้กำลังดำเนินการใช้งาน';
      case 'INACTIVE':
        return 'สัญญาฉบับนี้กำลังรอการอนุมัติหรือเข้าอยู่';
      case 'EXPIRED':
        return 'สัญญาฉบับนี้สิ้นสุดระยะเวลาการเช่าแล้ว';
      case 'TERMINATED':
      case 'CANCELLED':
        return 'สัญญาฉบับนี้ถูกยกเลิกแล้ว';
      default:
        return 'ไม่ทราบสถานะการดำเนินการของสัญญา';
    }
  }

  // เลือกสีพื้นหลังแบนเนอร์จาก Status
  static Color getBannerBgColor(BadgeStatus status) {
    switch (status) {
      case BadgeStatus.completed:
        return AppColors.success.withValues(alpha: 0.1);
      case BadgeStatus.pending:
        return AppColors.warning.withValues(alpha: 0.1);
      case BadgeStatus.urgent:
        return AppColors.error.withValues(alpha: 0.1);
      case BadgeStatus.info:
        return AppColors.info.withValues(alpha: 0.1);
      case BadgeStatus.cancelled:
        return Colors.grey.withValues(alpha: 0.1);
      case BadgeStatus.verifying:
        return AppColors.info.withValues(alpha: 0.1);
    }
  }
}
