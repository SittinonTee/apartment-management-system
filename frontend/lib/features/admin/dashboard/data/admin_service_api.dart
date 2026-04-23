import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/auth_service.dart';

class AdminServiceApi {
  static final AdminServiceApi _instance = AdminServiceApi._internal();
  factory AdminServiceApi() => _instance;

  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  AdminServiceApi._internal();

  Future<Map<String, dynamic>> addTenant(Map<String, dynamic> data) async {
    try {
      final token = await AuthService().getToken();

      // คัดลอกข้อมูลและแยกไฟล์ออกมาเพื่อไม่ให้ FormData.fromMap พัง
      final Map<String, dynamic> bodyData = Map.from(data);
      final platformFile = bodyData.remove('contract_file') as PlatformFile?;

      // สร้าง FormData จากข้อมูลที่เหลือ
      final formData = FormData.fromMap(bodyData);

      // ถ้ามีการแนบไฟล์สัญญา
      if (platformFile != null) {
        if (platformFile.bytes != null) {
          // สำหรับ Web หรือกรณีที่มี bytes
          formData.files.add(
            MapEntry(
              'contract_file',
              MultipartFile.fromBytes(
                platformFile.bytes!,
                filename: platformFile.name,
              ),
            ),
          );
        } else if (platformFile.path != null) {
          // สำหรับ Mobile หรือ Desktop ที่มี path
          formData.files.add(
            MapEntry(
              'contract_file',
              await MultipartFile.fromFile(
                platformFile.path!,
                filename: platformFile.name,
              ),
            ),
          );
        }
      }

      final response = await _dio.post(
        '/admin/addTenant',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.data;
    } on DioException catch (e) {
      debugPrint('เกิดข้อผิดพลาดในการเพิ่มผู้เช่า (Dio): ${e.response?.data}');
      return e.response?.data ??
          {
            'status': 'error',
            'message': 'เกิดข้อผิดพลาดในการเชื่อมต่อเซิร์ฟเวอร์',
          };
    } catch (e) {
      debugPrint('เกิดข้อผิดพลาดในการเพิ่มผู้เช่า: $e');
      return {'status': 'error', 'message': 'เกิดข้อผิดพลาดที่ไม่รู้จัก'};
    }
  }

  Future<Map<String, dynamic>> terminateContract(
    int contractId,
    PlatformFile file,
  ) async {
    try {
      final token = await AuthService().getToken();
      final formData = FormData.fromMap({'contract_id': contractId});

      if (file.bytes != null) {
        formData.files.add(
          MapEntry(
            'cancel_file',
            MultipartFile.fromBytes(file.bytes!, filename: file.name),
          ),
        );
      } else if (file.path != null) {
        formData.files.add(
          MapEntry(
            'cancel_file',
            await MultipartFile.fromFile(file.path!, filename: file.name),
          ),
        );
      }

      final response = await _dio.post(
        '/admin/terminateContract',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.data;
    } on DioException catch (e) {
      debugPrint('เกิดข้อผิดพลาดในการยกเลิกสัญญา (Dio): ${e.response?.data}');
      return e.response?.data ??
          {
            'status': 'error',
            'message': 'เกิดข้อผิดพลาดในการเชื่อมต่อเซิร์ฟเวอร์',
          };
    } catch (e) {
      debugPrint('เกิดข้อผิดพลาดในการยกเลิกสัญญา: $e');
      return {'status': 'error', 'message': 'เกิดข้อผิดพลาดที่ไม่รู้จัก'};
    }
  }
}
