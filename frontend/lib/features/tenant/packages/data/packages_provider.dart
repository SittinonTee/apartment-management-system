import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/services/auth_service.dart';

class TenantPackagesProvider extends ChangeNotifier {
  static final TenantPackagesProvider _instance =
      TenantPackagesProvider._internal();
  factory TenantPackagesProvider() => _instance;

  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  List<Map<String, dynamic>> _parcels = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get parcels => _parcels;
  bool get isLoading => _isLoading;

  TenantPackagesProvider._internal();

  Future<void> fetchParcels() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await AuthService().getToken();

      final response = await _dio.get(
        '${ApiConstants.baseUrl}/packages/user',
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
}
