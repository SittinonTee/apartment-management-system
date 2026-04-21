import 'dart:convert';

class AdminRepairModel {
  // Centralized Category Mapping
  final int id;
  final int userId;
  final int categoryId;
  final String categoryName;
  final String title; // head_repairs
  final String description;
  final String preferredTime;
  final List<String> imageUrls;
  final String status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String tenantfirstname;
  final String tenantlastname;
  final String roomNumber;
  final String tenantPhone;
  final String mechanicfirstname;
  final String mechaniclastname;
  final String mechanicPhone;

  AdminRepairModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.categoryName,
    required this.title,
    required this.description,
    required this.preferredTime,
    this.imageUrls = const [],
    required this.status,
    required this.createdAt,
    this.completedAt,
    required this.tenantfirstname,
    required this.tenantlastname,
    required this.roomNumber,
    required this.tenantPhone,
    required this.mechanicfirstname,
    required this.mechaniclastname,
    required this.mechanicPhone,
  });

  factory AdminRepairModel.fromJson(Map<String, dynamic> json) {
    return AdminRepairModel(
      id: json['repairsuser_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      categoryName: json['category_name'] ?? '',
      title: json['head_repairs'] ?? '',
      description: json['description'] ?? '',
      preferredTime: json['preferred_time'] ?? '',
      imageUrls: _parseImageUrls(json['repairsimage_url']),
      status: json['status'] ?? 'REPORTED',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at']).toLocal()
          : null,
      tenantfirstname: json['tenant_firstname'] ?? '',
      tenantlastname: json['tenant_lastname'] ?? '',
      roomNumber: json['room_number'] ?? '',
      tenantPhone: json['tenant_phone'] ?? '',
      mechanicfirstname: json['mechanic_firstname'] ?? '',
      mechaniclastname: json['mechanic_lastname'] ?? '',
      mechanicPhone: json['mechanic_phone'] ?? '',
    );
  }

  static List<String> _parseImageUrls(dynamic data) {
    if (data == null) return [];
    final String raw = data.toString().trim();
    if (raw.isEmpty) return [];

    // Try parsing as JSON array
    try {
      if (raw.startsWith('[') && raw.endsWith(']')) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      }
    } catch (_) {
      // Fallback to comma-separated
    }

    // Fallback to comma-separated if not JSON or if JSON parse failed
    if (raw.contains(',')) {
      return raw
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    // Default: return single string in list
    return [raw];
  }
}
