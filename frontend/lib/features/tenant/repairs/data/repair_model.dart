class RepairModel {
  // Centralized Category Mapping
  final int id;
  final int userId;
  final int categoryId;
  final String categoryName;
  final String title; // head_repairs
  final String description;
  final String preferredTime;
  final String? imageUrl;
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

  RepairModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.categoryName,
    required this.title,
    required this.description,
    required this.preferredTime,
    this.imageUrl,
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

  factory RepairModel.fromJson(Map<String, dynamic> json) {
    return RepairModel(
      id: json['repairsuser_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      categoryName: json['category_name'] ?? '',
      title: json['head_repairs'] ?? '',
      description: json['description'] ?? '',
      preferredTime: json['preferred_time'] ?? '',
      imageUrl: json['repairsimage_url'],
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
}

class CategoryModel {
  final int categoryId;
  final String categoryName;

  CategoryModel({required this.categoryId, required this.categoryName});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['category_id'] ?? 0,
      categoryName: json['name_category'] ?? '',
    );
  }
}
