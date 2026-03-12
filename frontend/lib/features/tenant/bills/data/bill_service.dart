import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/auth_service.dart';

class BillService {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
  final AuthService _authService = AuthService();

  Future<List<Map<String, dynamic>>> getMyBills() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      final response = await _dio.get(
        '/bills/my-bills',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data['status'] == 'success') {
        final data = response.data['data'];
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        }
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching bills: $e');
      }
      return [];
    }
  }
}
