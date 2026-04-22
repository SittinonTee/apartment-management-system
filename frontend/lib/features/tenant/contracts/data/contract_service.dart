import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/auth_service.dart';

class ContractService {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
  final AuthService _authService = AuthService();

  // ดึงรายการสัญญาทั้งหมดของฉัน
  Future<List<dynamic>?> getMyContracts() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await _dio.get(
        '/tenant/my-contracts',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return response.data['data'] as List<dynamic>;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching my contracts: $e');
      }
      return null;
    }
  }

  // ดึงข้อสัญญาแบบ Detail อันเดียวผ่าน ID
  Future<Map<String, dynamic>?> getContractDetails(int id) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await _dio.get(
        '/tenant/contract-details/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return response.data['data'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching contract details: $e');
      }
      return null;
    }
  }

  // ดึงข้อสัญญาอันล่าสุดสำหรับใช้โชว์ใน Dashboard
  Future<Map<String, dynamic>?> getMyContract() async {
    try {
      final contracts = await getMyContracts();
      if (contracts != null && contracts.isNotEmpty) {
        // คืนค่าใบที่ Active หรือใบแรกที่เจอ
        try {
          return contracts.firstWhere((c) => c['status'] == 'ACTIVE');
        } catch (_) {
          return contracts.first;
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error in getMyContract: $e');
      return null;
    }
  }
}
