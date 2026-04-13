import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/services/auth_service.dart';

class AdminPackagesProvider extends ChangeNotifier {
  static final AdminPackagesProvider _instance =
      AdminPackagesProvider._internal();
  factory AdminPackagesProvider() => _instance;

  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  List<Map<String, dynamic>> _parcels = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get parcels => _parcels;
  bool get isLoading => _isLoading;

  AdminPackagesProvider._internal();

  Future<void> fetchParcels() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await AuthService().getToken();

      final response = await _dio.get(
        '${ApiConstants.baseUrl}/packages/admin',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      _parcels = List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      debugPrint('FetchParcels DioError: ${e.response?.data}');
    } catch (e) {
      debugPrint('FetchParcels Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ฟังก์ชันเพิ่มพัสดุ
  Future<String?> addParcel(Map<String, dynamic> data) async {
    try {
      final token = await AuthService().getToken();
      await _dio.post(
        '${ApiConstants.baseUrl}/packages/admin',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      // ถ้ายิงสำเร็จ ดึงรายการใหม่
      await fetchParcels();
      return null; // null หมายถึงสำเร็จ ไม่มี Error
    } on DioException catch (e) {
      debugPrint('AddParcel DioError: ${e.response?.data}');
      if (e.response != null && e.response!.data != null) {
        final err = e.response!.data;
        return err['error']?.toString() ??
            err['message']?.toString() ??
            'เกิดข้อผิดพลาด กรุณาลองใหม่';
      }
      return 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้';
    } catch (e) {
      debugPrint('AddParcel Error: $e');
      return 'เกิดข้อผิดพลาดที่ไม่รู้จัก';
    }
  }

  // ฟังก์ชันเซ็นรับพัสดุ
  Future<bool> pickupParcel(int parcelId) async {
    try {
      final token = await AuthService().getToken();
      await _dio.patch(
        '${ApiConstants.baseUrl}/packages/admin/$parcelId/pickup',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      // ถ้ายิงสำเร็จ ดึงรายการใหม่
      await fetchParcels();
      return true;
    } catch (e) {
      debugPrint('PickupParcel Error: $e');
      return false;
    }
  }
}
