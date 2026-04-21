import 'dart:convert';

class RepairModel {
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
  final String tenantPhone;
  final String mechanicfirstname;
  final String mechaniclastname;
  final String mechanicPhone;

  RepairModel({
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
    required this.tenantPhone,
    required this.mechanicfirstname,
    required this.mechaniclastname,
    required this.mechanicPhone,
  });

  factory RepairModel.fromJson(Map<String, dynamic> json) {
    return RepairModel(
      id: json['repairsuser_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      categoryName: (json['category_name'] ?? '').toString(),
      title: (json['head_repairs'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      preferredTime: (json['preferred_time'] ?? '').toString(),
      imageUrls: _parseImageUrls(json['repairsimage_url']),
      status: (json['status'] ?? 'REPORTED').toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString()).toLocal()
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'].toString()).toLocal()
          : null,
      tenantfirstname: (json['tenant_firstname'] ?? '').toString(),
      tenantlastname: (json['tenant_lastname'] ?? '').toString(),
      tenantPhone: (json['tenant_phone'] ?? '').toString(),
      mechanicfirstname: (json['mechanic_firstname'] ?? '').toString(),
      mechaniclastname: (json['mechanic_lastname'] ?? '').toString(),
      mechanicPhone: (json['mechanic_phone'] ?? '').toString(),
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

class CategoryModel {
  final int categoryId;
  final String categoryName;

  CategoryModel({required this.categoryId, required this.categoryName});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['category_id'] ?? 0,
      categoryName: (json['name_category'] ?? '').toString(),
    );
  }
}
