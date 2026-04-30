import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';

// ----------------------------- template -----------------------------
class UserTemplate {
  final int userId;
  final String firstname;
  final String lastname;
  final String phone;
  final String? emergencyPhone;
  final String email;
  final String role;
  final String? roomNumber;
  final int? floor;
  final int? rateRoom;
  final int? rateWater;
  final int? rateElectric;
  final String? contractNo;
  final String? startDate;
  final String? endDate;
  final int? deposit;
  final int? billsId;
  final String userStatus;
  final String contractStatus;
  final int? contractId;
  final String? inviteCode;

  UserTemplate({
    required this.userId,
    required this.firstname,
    required this.lastname,
    required this.phone,
    this.emergencyPhone,
    required this.email,
    required this.role,
    this.roomNumber,
    this.floor,
    this.rateRoom,
    this.rateWater,
    this.rateElectric,
    this.contractNo,
    this.startDate,
    this.endDate,
    this.deposit,
    this.billsId,
    required this.userStatus,
    required this.contractStatus,
    this.contractId,
    this.inviteCode,
  });

  factory UserTemplate.fromJson(Map<String, dynamic> json) {
    return UserTemplate(
      userId: json['id'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      phone: json['phone'].toString(), // กัน error
      emergencyPhone: json['emergency_phone'].toString(), // กัน error
      email:
          json['email']?.toString() ??
          'ยังไม่ได้เข้าสู่ระบบ', // กัน error ไม่มีค่า
      role: json['role'],
      roomNumber: json['room_number'],
      floor: json['floor'],
      rateRoom: json['rate_room'],
      rateWater: json['rate_water'],
      rateElectric: json['rate_electric'],
      contractNo: json['contract_no']?.toString(),
      startDate: json['start_date'],
      endDate: json['end_date'],
      deposit: json['deposit'],
      billsId: json['bills_no'],
      userStatus: json['user_status'] ?? '',
      contractStatus: json['contract_status'] ?? '',
      contractId: json['contract_id'],
      inviteCode: json['invite_code']?.toString(),
    );
  }
}

// ----------------------------- ดึงข้อมูล api -----------------------------

class AdminService extends ChangeNotifier {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;

  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  AdminService._internal();

  Future<List<UserTemplate>> getUserData() async {
    try {
      final response = await _dio.get('/admin/getUserData');

      if (response.data['status'] == 'success') {
        final List data = response.data['data'];
        return List<UserTemplate>.from(
          data.map((x) => UserTemplate.fromJson(x)),
        );
      }
      return [];
    } on DioException catch (e) {
      debugPrint(
        'เกิดข้อผิดพลาดในการดึงข้อมูลผู้ใช้ (Dio): ${e.response?.data}',
      );
      return [];
    } catch (e) {
      debugPrint('เกิดข้อผิดพลาดในการดึงข้อมูลผู้ใช้: $e');
      return [];
    }
  }

  Future<List<UserTemplate>> getTechnicianData() async {
    try {
      final response = await _dio.get('/admin/getTechnicians');

      if (response.data['status'] == 'success') {
        final List data = response.data['data'];
        return List<UserTemplate>.from(
          data.map((x) => UserTemplate.fromJson(x)),
        );
      }
      return [];
    } on DioException catch (e) {
      debugPrint('เกิดข้อผิดพลาดในการดึงข้อมูลช่าง (Dio): ${e.response?.data}');
      return [];
    } catch (e) {
      debugPrint('เกิดข้อผิดพลาดในการดึงข้อมูลช่าง: $e');
      return [];
    }
  }
}
