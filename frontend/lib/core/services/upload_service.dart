import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/api_constants.dart';
import 'auth_service.dart';

class UploadService {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
  final AuthService _authService = AuthService();

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

      FormData formData = FormData.fromMap({
        'file': multipartFile,
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
      if (kDebugMode) {
        print('Error uploading image: $e');
      }
      return null;
    }
  }
}
