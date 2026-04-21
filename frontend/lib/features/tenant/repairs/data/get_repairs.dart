import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/features/tenant/repairs/data/repair_model.dart';

class GetRepairs extends ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  // --------------------------------------------- Insert to Repairs_user --------------------------------------//
  Future<bool> createRepairRequest({
    required String token,
    required int categoryId,
    required String title,
    required String description,
    required String preferredTime,
    String? imageUrl,
    String? repairsImageUrl,
  }) async {
    try {
      final response = await _dio.post(
        '/repairs/request',
        data: {
          'category_id': categoryId,
          'head_repairs': title,
          'description': description,
          'preferred_time': preferredTime,
          'repairsimage_url': imageUrl,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      debugPrint('CreateRepair DioError: ${e.message} - ${e.response?.data}');
      return false;
    } catch (e) {
      debugPrint('CreateRepair Error: $e');
      return false;
    }
  }
  // --------------------------------------------- Insert to Repairs_user --------------------------------------//

  // --------------------------------------------- Get vw_Repairs --------------------------------------//
  Future<List<RepairModel>> getMyRepairs(String token) async {
    try {
      final response = await _dio.get(
        '/repairs/my-repairs',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // อิงตามรูปแบบ API ทั่วไป ถ้าเป็น List ตรงๆ ก็ map เลย
        // ถ้า Backend คืนมาเป็น { status: 'success', data: [...] } ต้องแก้เป็น response.data['data']
        var responseData = response.data;
        if (responseData is Map && responseData.containsKey('data')) {
          responseData = responseData['data'];
        }

        final List data = responseData;
        return List<RepairModel>.from(data.map((x) => RepairModel.fromJson(x)));
      }
      return <RepairModel>[];
    } on DioException catch (e) {
      debugPrint('GetRepairs DioError: ${e.message} - ${e.response?.data}');
      return <RepairModel>[];
    } catch (e) {
      debugPrint('GetRepairs Error: $e');
      return <RepairModel>[];
    }
  }
  // // --------------------------------------------- Get vw_Repairs --------------------------------------//

  // // --------------------------------------------- Get Categories --------------------------------------//
  // Future<List<CategoryModel>> getCategories(String token) async {
  //   try {
  //     final response = await _dio.get(
  //       '/repairs/categories',
  //       options: Options(headers: {'Authorization': 'Bearer $token'}),
  //     );

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       var responseData = response.data;

  //       if (responseData is Map && responseData.containsKey('data')) {
  //         responseData = responseData['data'];
  //       }

  //       if (responseData == null || responseData is! List) {
  //         return [];
  //       }

  //       return List<CategoryModel>.from(
  //         responseData.map((x) => CategoryModel.fromJson(x)),
  //       );
  //     }

  //     return [];
  //   } on DioException catch (e) {
  //     debugPrint('GetCategories DioError: ${e.message} - ${e.response?.data}');
  //     return [];
  //   } catch (e) {
  //     debugPrint('GetCategories Error: $e');
  //     return [];
  //   }
  // }

  Future<List<CategoryModel>> getCategories(String token) async {
    try {
      final response = await _dio.get(
        '/repairs/categories',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data['status'] == 'success') {
        final data = response.data['data'];

        // ✅ กัน null + กันไม่ใช่ List
        if (data == null || data is! List) {
          return [];
        }

        // ✅ cast ให้ชัด
        return data
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return [];
    }
  }

  // --------------------------------------------- Get Categories --------------------------------------//

  // --------------------------------------------- Update Repair Status --------------------------------------//
  Future<bool> cancelRepairRequest({
    required String token,
    required int repairId,
  }) async {
    try {
      final response = await _dio.post(
        '/repairs/update-repair',
        data: {'repairsuser_id': repairId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data['status'] == 'success') {
        return true;
      }
      return false;
    } on DioException catch (e) {
      debugPrint('CancelRepair DioError: ${e.message} - ${e.response?.data}');
      return false;
    } catch (e) {
      debugPrint('CancelRepair Error: $e');
      return false;
    }
  }
}
