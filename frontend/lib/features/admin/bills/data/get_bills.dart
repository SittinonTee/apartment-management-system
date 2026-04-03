import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/core/services/auth_service.dart';

class BillModel {
  final String roomNumber;
  final String tenantName;
  final String status;
  final int amount;
  final DateTime dueDate;
  final DateTime? payDate;
  final String? payMethod;

  BillModel({
    required this.roomNumber,
    required this.tenantName,
    required this.status,
    required this.amount,
    required this.dueDate,
    this.payDate,
    this.payMethod,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      roomNumber: json['room_number']?.toString() ?? '',
      tenantName: json['tenant_name'] ?? '',
      status: json['status'] ?? 'pending',
      amount: json['amount'] is int
          ? json['amount']
          : int.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : DateTime.now(),
      payDate: json['pay_date'] != null
          ? DateTime.parse(json['pay_date'])
          : null,
      payMethod: json['pay_method'],
    );
  }
}

class BillsService {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  Future<List<BillModel>> getBills() async {
    try {
      final token = await AuthService().getToken();

      // ดึงข้อมูลบิลทั้งหมดจากระบบ (แก้ไข Endpoint ให้ตรงกับ Backend ของคุณถ้าไม่ใช้ '/admin/bills')
      final response = await _dio.get(
        '/bills/all-bills',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        // คาดหวังว่า Backend ส่งข้อมูลมาในรูป { "data": [...] } หรือเป็น List [...] โดยตรง
        final responseData = response.data;
        List<dynamic> dataList = [];

        if (responseData is Map && responseData.containsKey('data')) {
          dataList = responseData['data'];
        } else if (responseData is List) {
          dataList = responseData;
        }

        return dataList.map((json) => BillModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('GetBills Error: $e');
      return [];
    }
  }
}
