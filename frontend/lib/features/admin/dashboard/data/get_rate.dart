import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';

class RateTemplate {
  final int id;
  final String rateRoom;
  final String rateWater;
  final String rateElectric;

  RateTemplate({
    required this.id,
    required this.rateRoom,
    required this.rateWater,
    required this.rateElectric,
  });

  factory RateTemplate.fromJson(Map<String, dynamic> json) {
    return RateTemplate(
      id: json['rate_id'] is int
          ? json['rate_id']
          : int.tryParse(json['rate_id']?.toString() ?? '0') ?? 0,
      rateRoom: json['rate_room']?.toString() ?? '',
      rateWater: json['rate_water']?.toString() ?? '',
      rateElectric: json['rate_electric']?.toString() ?? '',
    );
  }
}

class GetRate extends ChangeNotifier {
  static final GetRate _instance = GetRate._internal();
  factory GetRate() => _instance;

  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  GetRate._internal();

  Future<List<RateTemplate>> getRates() async {
    try {
      final response = await _dio.get('/admin/getRates');

      if (response.data['status'] == 'success') {
        final List data = response.data['data'];
        return List<RateTemplate>.from(data.map((x) => RateTemplate.fromJson(x)));
      }
      return [];
    } on DioException catch (e) {
      debugPrint('GetRates DioError: ${e.response?.data}');
      return [];
    } catch (e) {
      debugPrint('GetRates Error: $e');
      return [];
    }
  }
}
