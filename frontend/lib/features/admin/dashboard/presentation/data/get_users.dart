import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/api_constants.dart';

// ----------------------------- template -----------------------------
class UserTemplate {
  final int id;
  final String firstname;
  final String lastname;
  final String email;
  final String role;
  final String status;

  UserTemplate({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.role,
    required this.status,
  });
  factory UserTemplate.fromJson(Map<String, dynamic> json) {
    return UserTemplate(
      // แปลง id เป็น int ตลอด
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      firstname: json['firstname']?.toString() ?? '',
      lastname: json['lastname']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'role': role,
      'status': status,
    };
  }
}

// ----------------------------- ดึงข้อมูล api -----------------------------

class AdminService extends ChangeNotifier {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;

  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  AdminService._internal();

  Future<List<UserTemplate>> getUserData() async {
    try {
      final response = await _dio.get('/admin/getUserData');

      if (response.data['status'] == 'success') {
        final List data = response.data['data'];
        return List<UserTemplate>.from(
          data.map((x) => UserTemplate.fromJson(x)),
        );
      }
      return [];
    } on DioException catch (e) {
      debugPrint('GetUserData DioError: ${e.response?.data}');
      return [];
    } catch (e) {
      debugPrint('GetUserData Error: $e');
      return [];
    }
  }
}
