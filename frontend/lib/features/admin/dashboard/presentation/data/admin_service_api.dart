import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/services/auth_service.dart';

class AdminServiceApi {
  static final AdminServiceApi _instance = AdminServiceApi._internal();
  factory AdminServiceApi() => _instance;

  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  AdminServiceApi._internal();

  Future<Map<String, dynamic>> addTenant(Map<String, dynamic> data) async {
    try {
      final token = await AuthService().getToken();

      final response = await _dio.post(
        '/admin/addTenant',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.data;
    } on DioException catch (e) {
      debugPrint('AddTenant DioError: ${e.response?.data}');
      return e.response?.data ??
          {
            'status': 'error',
            'message': 'เกิดข้อผิดพลาดในการเชื่อมต่อเซิร์ฟเวอร์',
          };
    } catch (e) {
      debugPrint('AddTenant Error: $e');
      return {'status': 'error', 'message': 'เกิดข้อผิดพลาดที่ไม่รู้จัก'};
    }
  }
}
