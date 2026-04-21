import 'package:flutter/material.dart';
import 'dart:convert';

enum RepairStatus {
  problem, // REPORTED
  inProgress, // ASSIGNED
  pending, // PENDING (ใช้เป็น จัดซื้อวัสดุ)
  completed, // COMPLETED
  cancelled, // CANCELLED
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
  final int? technicianId;
  final String? mechanicName;

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
    this.technicianId,
    this.mechanicName,
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
      repairsImageUrl: _parseImageUrl(json['repairsimage_url']),
      preferredTime: json['preferred_time'],
      technicianId: json['technician_by'],
      mechanicName: json['mechanic_firstname'] != null
          ? '${json['mechanic_firstname']} ${json['mechanic_lastname'] ?? ''}'
                .trim()
          : null,
    );
  }

  // ฟังก์ชันช่วยจัดการ URL รูปภาพ (รองรับทั้ง String ธรรมดา และ JSON Array String)
  static String? _parseImageUrl(dynamic rawUrl) {
    if (rawUrl == null || rawUrl.toString().isEmpty) return null;

    String url = rawUrl.toString().trim();

    // ถ้ามาเป็น JSON Array เช่น ["https://..."]
    if (url.startsWith('[') && url.endsWith(']')) {
      try {
        final List<dynamic> urls = jsonDecode(url);
        if (urls.isNotEmpty) {
          return urls.first.toString();
        }
      } catch (e) {
        debugPrint('Error parsing image URL with jsonDecode: $e');
      }
    }

    return url.isEmpty ? null : url;
  }

  // แปลงสถานะจาก String เป็น Enum สำหรับ UI
  RepairStatus get statusEnum {
    switch (status) {
      case 'REPORTED':
        return RepairStatus.problem;
      case 'ASSIGNED':
        return RepairStatus.inProgress;
      case 'PENDING':
        return RepairStatus.pending;
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
        return 'กำลังดำเนินการ';
      case 'PENDING':
        return 'เตรียมอุปกรณ์';
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
        return const Color(0xFFFFF3DB);
      case 'PENDING':
        return const Color(0xFFFFF4E5); // Light Orange background
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
        return const Color(0xFFFFAB40);
      case 'PENDING':
        return const Color(0xFFF2994A); // Dark Orange text
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
