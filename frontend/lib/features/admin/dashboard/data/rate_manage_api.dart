import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/auth_service.dart';

class RateManageApi {
  static final RateManageApi _instance = RateManageApi._internal();
  factory RateManageApi() => _instance;

  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  RateManageApi._internal();

  /// ดึงข้อมูลเรทราคาทั้งหมด
  Future<List<Map<String, dynamic>>> getAllRates() async {
    try {
      final token = await AuthService().getToken();

      final response = await _dio.get(
        '/rates',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data['status'] == 'success') {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } on DioException catch (e) {
      debugPrint('GetAllRates DioError: ${e.response?.data}');
      return [];
    } catch (e) {
      debugPrint('GetAllRates Error: $e');
      return [];
    }
  }

  /// เพิ่มเรทราคาใหม่
  Future<Map<String, dynamic>> addRate(Map<String, dynamic> data) async {
    try {
      final token = await AuthService().getToken();

      final response = await _dio.post(
        '/rates',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.data;
    } on DioException catch (e) {
      debugPrint('AddRate DioError: ${e.response?.data}');
      return e.response?.data ??
          {'status': 'error', 'message': 'เกิดข้อผิดพลาด'};
    } catch (e) {
      debugPrint('AddRate Error: $e');
      return {'status': 'error', 'message': 'เกิดข้อผิดพลาดที่ไม่รู้จัก'};
    }
  }

  /// แก้ไขเรทราคา
  Future<Map<String, dynamic>> updateRate(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await AuthService().getToken();

      final response = await _dio.patch(
        '/rates/$id',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.data;
    } on DioException catch (e) {
      debugPrint('UpdateRate DioError: ${e.response?.data}');
      return e.response?.data ??
          {'status': 'error', 'message': 'เกิดข้อผิดพลาด'};
    } catch (e) {
      debugPrint('UpdateRate Error: $e');
      return {'status': 'error', 'message': 'เกิดข้อผิดพลาดที่ไม่รู้จัก'};
    }
  }
}
