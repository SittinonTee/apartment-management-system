import 'package:flutter/material.dart';

enum RepairStatus {
  problem,      // REPORTED
  inProgress,   // ASSIGNED, PENDING
  completed,    // COMPLETED
  cancelled,    // CANCELLED
}

enum RepairType { water, electricity, air, other }

class RepairRequest {
  final int id;
  final String title;
  final String description;
  final DateTime date;
  final String status; // จาก DB
  final int categoryId;
  final String? roomNumber;
  final int? roomFloor;
  final String? tenantName;
  final String? tenantPhone;
  final String? categoryName;
  final String? repairsImageUrl;
  final String? preferredTime;

  RepairRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.status,
    required this.categoryId,
    this.roomNumber,
    this.roomFloor,
    this.tenantName,
    this.tenantPhone,
    this.categoryName,
    this.repairsImageUrl,
    this.preferredTime,
  });

  // แปลงจาก JSON สู่ Model
  factory RepairRequest.fromJson(Map<String, dynamic> json) {
    return RepairRequest(
      id: json['repairsuser_id'],
      title: json['head_repairs'] ?? '',
      description: json['description'] ?? '',
      date: DateTime.parse(json['created_at']),
      status: json['status'] ?? 'REPORTED',
      categoryId: json['category_id'] ?? 4,
      roomNumber: json['room_number'],
      roomFloor: json['room_floor'],
      tenantName: json['firstname'] != null
          ? '${json['firstname']} ${json['lastname']}'
          : null,
      tenantPhone: json['phone'],
      categoryName: json['category_name'],
      repairsImageUrl: json['repairsimage_url'],
      preferredTime: json['preferred_time'],
    );
  }

  // แปลงสถานะจาก String เป็น Enum สำหรับ UI
  RepairStatus get statusEnum {
    switch (status) {
      case 'REPORTED':
        return RepairStatus.problem;
      case 'ASSIGNED':
      case 'PENDING':
        return RepairStatus.inProgress;
      case 'COMPLETED':
        return RepairStatus.completed;
      case 'CANCELLED':
        return RepairStatus.cancelled;
      default:
        return RepairStatus.problem;
    }
  }

  // ข้อความสถานะภาษาไทย
  String get statusText {
    switch (status) {
      case 'REPORTED':
        return 'ปัญหา';
      case 'ASSIGNED':
      case 'PENDING':
        return 'กำลังดำเนินการ';
      case 'COMPLETED':
        return 'เสร็จสิ้น';
      case 'CANCELLED':
        return 'ยกเลิก';
      default:
        return 'อื่นๆ';
    }
  }

  // สีพื้นหลังป้ายสถานะ
  Color get statusColor {
    switch (status) {
      case 'REPORTED':
        return const Color(0xFFFFE0E0);
      case 'ASSIGNED':
      case 'PENDING':
        return const Color(0xFFFFF3DB);
      case 'COMPLETED':
        return const Color(0xFFE8F5E9);
      case 'CANCELLED':
        return const Color(0xFFEEEEEE);
      default:
        return Colors.grey.shade200;
    }
  }

  // สีตัวอักษรป้ายสถานะ
  Color get statusTextColor {
    switch (status) {
      case 'REPORTED':
        return const Color(0xFFFF5252);
      case 'ASSIGNED':
      case 'PENDING':
        return const Color(0xFFFFAB40);
      case 'COMPLETED':
        return const Color(0xFF4CAF50);
      case 'CANCELLED':
        return const Color(0xFF9E9E9E);
      default:
        return Colors.grey;
    }
  }

  // ไอคอนตามหมวดหมู่
  IconData get typeIcon {
    switch (categoryId) {
      case 2:
        return Icons.water_drop;
      case 1:
        return Icons.bolt;
      case 3:
        return Icons.air;
      default:
        return Icons.build;
    }
  }

  // สีไอคอน
  Color get typeIconColor {
    switch (categoryId) {
      case 2:
        return const Color(0xFF40C4FF);
      case 1:
        return const Color(0xFFFFAB40);
      case 3:
        return const Color(0xFF81D4FA);
      default:
        return Colors.grey;
    }
  }
}
