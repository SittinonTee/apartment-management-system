import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';

class RoomTemplate {
  final String id;
  final String roomNumber;

  RoomTemplate({required this.id, required this.roomNumber});

  factory RoomTemplate.fromJson(Map<String, dynamic> json) {
    return RoomTemplate(
      id: json['room_id']?.toString() ?? '',
      roomNumber: json['room_number']?.toString() ?? '',
    );
  }
}

class GetAvailableRoom extends ChangeNotifier {
  static final GetAvailableRoom _instance = GetAvailableRoom._internal();
  factory GetAvailableRoom() => _instance;

  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  GetAvailableRoom._internal();

  Future<List<RoomTemplate>> getAvailableRooms() async {
    try {
      final response = await _dio.get('/admin/getAvailableRooms');

      if (response.data['status'] == 'success') {
        final List data = response.data['data'];
        return List<RoomTemplate>.from(
          data.map((x) => RoomTemplate.fromJson(x)),
        );
      }
      return [];
    } on DioException catch (e) {
      debugPrint('GetAvailableRooms DioError: ${e.response?.data}');
      return [];
    } catch (e) {
      debugPrint('GetAvailableRooms Error: $e');
      return [];
    }
  }
}
