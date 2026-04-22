import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/auth_service.dart';
import 'repair_model.dart';

class RepairService {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
  final AuthService _authService = AuthService();

  // ดึงรายการงานซ่อมทั้งหมดจาก API
  Future<List<RepairRequest>> getTechnicianRepairs() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      final response = await _dio.get(
        '/technicians/repairs',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data['status'] == 'success') {
        final List<dynamic> repairsList =
            response.data['data']['repairs'] ?? [];
        
        List<RepairRequest> repairs = [];
        for (var json in repairsList) {
          try {
            repairs.add(RepairRequest.fromJson(json));
          } catch (e) {
            if (kDebugMode) print('Skipping a malformed repair record: $e');
          }
        }
        return repairs;
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('Error fetching technical repairs: $e');
      return [];
    }
  }
}
