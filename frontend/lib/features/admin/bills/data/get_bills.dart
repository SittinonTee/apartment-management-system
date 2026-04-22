import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/core/services/auth_service.dart';

class BillModel {
  final int billId;
  final String roomNumber;
  final String tenantName;
  final String status;
  final double amount;
  final DateTime dueDate;
  final DateTime? payDate;
  final String? payMethod;
  final String? slipImageUrl;
  final String? approvedBy;

  BillModel({
    required this.billId,
    required this.roomNumber,
    required this.tenantName,
    required this.status,
    required this.amount,
    required this.dueDate,
    this.payDate,
    this.payMethod,
    this.slipImageUrl,
    this.approvedBy,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      billId: json['bills_id'] ?? 0,
      roomNumber: json['room_number']?.toString() ?? '',
      tenantName: json['tenant_name'] ?? '',
      status: json['status'] ?? 'pending',
      amount: double.tryParse(json['grand_total']?.toString() ?? '0') ?? 0.0,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : DateTime.now(),
      payDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'])
          : null,
      payMethod: json['pay_method'],
      slipImageUrl: json['slipimage_url'],
      approvedBy: json['approved_by']?.toString(),
    );
  }
}

class BillsService {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  Future<List<BillModel>> getBills() async {
    try {
      final token = await AuthService().getToken();

      // ดึงข้อมูลบิลทั้งหมดจากระบบ
      final response = await _dio.get(
        '/bills/all-bills',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
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

  Future<bool> confirmBill(int billId) async {
    try {
      final token = await AuthService().getToken();

      final response = await _dio.patch(
        '/bills/approve/$billId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('ConfirmBill Error: $e');
      return false;
    }
  }

  Future<bool> rejectBill(int billId) async {
    try {
      final token = await AuthService().getToken();

      final response = await _dio.patch(
        '/bills/reject/$billId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('RejectBill Error: $e');
      return false;
    }
  }
}

