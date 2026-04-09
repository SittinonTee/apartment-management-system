import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/features/admin/repairs/data/admin_repair_model.dart';

class GetAllRepairs extends ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
  Future<List<AdminRepairModel>> getAllRepairs(String token) async {
    try {
      final response = await _dio.get(
        '/repairs/all-repairs',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = response.data;
        if (responseData is Map && responseData.containsKey('data')) {
          responseData = responseData['data'];
        }

        final List data = responseData;
        return List<AdminRepairModel>.from(
          data.map((x) => AdminRepairModel.fromJson(x)),
        );
      }
      return <AdminRepairModel>[];
    } on DioException catch (e) {
      debugPrint('GetRepairs DioError: ${e.message} - ${e.response?.data}');
      return <AdminRepairModel>[];
    } catch (e) {
      debugPrint('GetRepairs Error: $e');
      return <AdminRepairModel>[];
    }
  }
}
