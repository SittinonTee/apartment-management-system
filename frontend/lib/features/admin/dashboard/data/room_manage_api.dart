import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/auth_service.dart';

class RoomManageApi {
  static final RoomManageApi _instance = RoomManageApi._internal();
  factory RoomManageApi() => _instance;

  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  RoomManageApi._internal();

  /// เพิ่มห้องพักใหม่
  Future<Map<String, dynamic>> addRoom(Map<String, dynamic> data) async {
    try {
      final token = await AuthService().getToken();

      final response = await _dio.post(
        '/rooms',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.data;
    } on DioException catch (e) {
      debugPrint('AddRoom DioError: ${e.response?.data}');
      return e.response?.data ??
          {
            'status': 'error',
            'message': 'เกิดข้อผิดพลาดในการเชื่อมต่อเซิร์ฟเวอร์',
          };
    } catch (e) {
      debugPrint('AddRoom Error: $e');
      return {'status': 'error', 'message': 'เกิดข้อผิดพลาดที่ไม่รู้จัก'};
    }
  }

  /// ดึงข้อมูลห้องพักทั้งหมด
  Future<List<Map<String, dynamic>>> getAllRooms() async {
    try {
      final token = await AuthService().getToken();

      final response = await _dio.get(
        '/rooms',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data['status'] == 'success') {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } on DioException catch (e) {
      debugPrint('GetAllRooms DioError: ${e.response?.data}');
      return [];
    } catch (e) {
      debugPrint('GetAllRooms Error: $e');
      return [];
    }
  }

  /// อัปเดตสถานะห้องพัก
  Future<Map<String, dynamic>> updateRoomStatus(int id, String status) async {
    try {
      final token = await AuthService().getToken();

      final response = await _dio.patch(
        '/rooms/$id/status',
        data: {'status': status},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.data;
    } on DioException catch (e) {
      debugPrint('UpdateRoomStatus DioError: ${e.response?.data}');
      return e.response?.data ?? {'status': 'error'};
    } catch (e) {
      debugPrint('UpdateRoomStatus Error: $e');
      return {'status': 'error'};
    }
  }

  /// ลบห้องพัก
  Future<Map<String, dynamic>> deleteRoom(int id) async {
    try {
      final token = await AuthService().getToken();

      final response = await _dio.delete(
        '/rooms/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.data;
    } on DioException catch (e) {
      debugPrint('DeleteRoom DioError: ${e.response?.data}');
      return e.response?.data ?? {'status': 'error'};
    } catch (e) {
      debugPrint('DeleteRoom Error: $e');
      return {'status': 'error'};
    }
  }

  /// อัปเดตข้อมูลห้องพัก
  Future<Map<String, dynamic>> updateRoom(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await AuthService().getToken();

      final response = await _dio.patch(
        '/rooms/$id',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.data;
    } on DioException catch (e) {
      debugPrint('UpdateRoom DioError: ${e.response?.data}');
      return e.response?.data ??
          {
            'status': 'error',
            'message': 'เกิดข้อผิดพลาดในการเชื่อมต่อเซิร์ฟเวอร์',
          };
    } catch (e) {
      debugPrint('UpdateRoom Error: $e');
      return {'status': 'error', 'message': 'เกิดข้อผิดพลาดที่ไม่รู้จัก'};
    }
  }
}
