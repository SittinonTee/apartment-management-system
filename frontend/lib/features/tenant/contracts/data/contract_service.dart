import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/auth_service.dart';

class ContractService {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>?> getMyContract() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await _dio.get(
        '/contracts/my-contract',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data['status'] == 'success') {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching contract: $e');
      }
      return null;
    }
  }
}
