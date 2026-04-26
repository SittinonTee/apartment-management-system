import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../constants/api_constants.dart';
import 'auth_service.dart';

class UploadService {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
  final AuthService _authService = AuthService();

  // ตัวใหม่: รองรับ PlatformFile (เลือกผ่าน FilePicker ได้ทั้งรูปและ PDF)
  Future<String?> uploadFile(PlatformFile file, {String folder = 'others'}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      String fileName = file.name;
      MultipartFile multipartFile;
      
      if (kIsWeb || file.bytes != null) {
        multipartFile = MultipartFile.fromBytes(file.bytes!, filename: fileName);
      } else {
        multipartFile = await MultipartFile.fromFile(file.path!, filename: fileName);
      }
      return await _performUpload(multipartFile, folder, token);
    } catch (e) {
      if (kDebugMode) print('Error uploading file: $e');
      return null;
    }
  }

  // ตัวเดิม: รองรับ XFile (เพื่อความเข้ากันได้กับหน้าเดิมๆ)
  Future<String?> uploadImage(XFile image, {String folder = 'others'}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      String fileName = image.name;
      MultipartFile multipartFile;
      
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        multipartFile = MultipartFile.fromBytes(bytes, filename: fileName);
      } else {
        multipartFile = await MultipartFile.fromFile(image.path, filename: fileName);
      }
      return await _performUpload(multipartFile, folder, token);
    } catch (e) {
      if (kDebugMode) print('Error uploading image: $e');
      return null;
    }
  }

  // ฟังก์ชันกลางที่ใช้ส่งข้อมูลจริงๆ
  Future<String?> _performUpload(MultipartFile file, String folder, String token) async {
    try {
      FormData formData = FormData.fromMap({
        'file': file,
        'folder': folder,
      });

      final response = await _dio.post(
        '/upload',
        data: formData,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data'
        }),
      );

      if (response.data['status'] == 'success') {
        return response.data['data']['url'];
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Upload API Error: $e');
      return null;
    }
  }
}
