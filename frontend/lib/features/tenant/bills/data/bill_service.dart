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
        '/tenant-billing/my-bills',
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



  Future<bool> processPayment(int billId, String slipUrl) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await _dio.patch(
        '/tenant-billing/payment/$billId',
        data: {'slipUrl': slipUrl},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data['status'] == 'success';
    } catch (e) {
      if (kDebugMode) {
        print('Error processing payment: $e');
      }
      return false;
    }
  }
}
