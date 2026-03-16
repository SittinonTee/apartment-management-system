import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

enum UserRole { guest, tenant, admin, technician }

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  UserRole _currentRole = UserRole.guest; // ค่า role ของ user
  String? _firstName; // ชื่อผู้ใช้
  String? _lastName; // นามสกุลผู้ใช้
  bool _isInitialized = false; // จริงถ้า auth service ถูกโหลดแล้ว
  String? _lastError; // เก็บข้อความ Error ล่าสุด

  AuthService._internal() {
    _initializeAuth();
  }

  bool get isAuthenticated =>
      _currentRole != UserRole.guest; // จริงถ้า user ล็อกอินแล้ว
  UserRole get currentRole => _currentRole; // ค่า role ของ user
  String get userName => '${_firstName ?? ''} ${_lastName ?? ''}'.trim();
  String? get lastError => _lastError;
  bool get isInitialized => _isInitialized; // จริงถ้า auth service ถูกโหลดแล้ว

  Future<void> _initializeAuth() async {
    final token = await _storage.read(key: 'jwt_token');
    final roleString = await _storage.read(key: 'user_role');

    if (token != null && roleString != null) {
      _currentRole = _parseRole(roleString);
      _firstName = await _storage.read(key: 'user_firstname');
      _lastName = await _storage.read(key: 'user_lastname');
    }
    _isInitialized = true; // จริงถ้า auth service ถูกโหลดแล้ว
    notifyListeners(); // แจ้งให้ UI ทราบว่า auth service ถูกโหลดแล้ว
  }

  //-----------------------------------------------------------เข้าสู่ระบบ-------------------------------------------------------------
  Future<bool> login(String email, String password) async {
    try {
      _lastError = null;
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.data['status'] == 'success') {
        final data = response.data['data'];
        final token = data['token'];
        final roleString = data['user']['role'];
        final firstName = data['user']['firstname'];
        final lastName = data['user']['lastname'];

        // Save to secure storage
        await _storage.write(key: 'jwt_token', value: token);
        await _storage.write(key: 'user_role', value: roleString);
        await _storage.write(key: 'user_firstname', value: firstName);
        await _storage.write(key: 'user_lastname', value: lastName);

        _currentRole = _parseRole(roleString);
        _firstName = firstName;
        _lastName = lastName;
        notifyListeners();
        return true;
      }
      return false;
    } on DioException catch (e) {
      if (e.response == null) {
        _lastError =
            'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ กรุณาตรวจสอบอินเทอร์เน็ตหรือตั้งค่า IP';
      } else {
        _lastError = e.response?.data['message'] ?? 'เข้าสู่ระบบล้มเหลว';
      }
      debugPrint(
        'Login DioError: ${e.response?.data['message'] ?? e.message ?? e.error}',
      );
      notifyListeners();
      return false;
    } catch (e) {
      _lastError = 'เข้าสู่ระบบล้มเหลว กรุณาลองใหม่อีกครั้ง';
      debugPrint('Login Error: $e');
      notifyListeners();
      return false;
    }
  }

  //-----------------------------------------------------------สมัครสมาชิกบัญชี-------------------------------------------------------------
  Future<bool> register(
    String inviteCode,
    String email,
    String password,
  ) async {
    try {
      _lastError = null;
      final response = await _dio.post(
        '/auth/register',
        data: {'invite_code': inviteCode, 'email': email, 'password': password},
      );

      if (response.data['status'] == 'success') {
        notifyListeners();
        return true;
      }
      return false;
    } on DioException catch (e) {
      if (e.response == null) {
        _lastError =
            'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ กรุณาตรวจสอบอินเทอร์เน็ตหรือตั้งค่า IP';
      } else {
        _lastError =
            e.response?.data['message'] ?? 'การสมัครสมาชิกบัญชีล้มเหลว';
      }
      debugPrint('Register DioError: ${e.message}');
      notifyListeners();
      return false;
    } catch (e) {
      _lastError = 'เกิดข้อผิดพลาดในการสมัครสมาชิกบัญชี';
      debugPrint('Register Error: $e');
      notifyListeners();
      return false;
    }
  }

  //-----------------------------------------------------------ลืมรหัสผ่าน-------------------------------------------------------------
  Future<bool> forgotPassword(String email) async {
    try {
      _lastError = null;
      final response = await _dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
      if (response.data['status'] == 'success') {
        // เพิ่มบรรทัดนี้ลงไปชั่วคราวครับ
        debugPrint('forgotPassword response.data: ${response.data}');
        debugPrint(
          '====== รหัส OTP ของคุณคือ: ${response.data['data']['mock_otp']} ======',
        );
        return true;
      }
      return false;
    } on DioException catch (e) {
      if (e.response == null) {
        _lastError =
            'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ กรุณาตรวจสอบอินเทอร์เน็ตหรือตั้งค่า IP';
      } else {
        _lastError = e.response?.data['message'] ?? 'ส่งคำขอรีเซ็ตรหัสล้มเหลว';
      }
      debugPrint('Forgot Password DioError: ${e.message}');
      return false;
    } catch (e) {
      _lastError = 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง';
      debugPrint('Forgot Password Error: $e');
      return false;
    }
  }

  //-----------------------------------------------------------รีเซ็ตรหัสผ่าน-------------------------------------------------------------
  Future<bool> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    try {
      _lastError = null;
      final response = await _dio.post(
        '/auth/reset-password',
        data: {'email': email, 'otp': otp, 'new_password': newPassword},
      );

      if (response.data['status'] == 'success') {
        return true;
      }
      return false;
    } on DioException catch (e) {
      if (e.response == null) {
        _lastError =
            'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ กรุณาตรวจสอบอินเทอร์เน็ตหรือตั้งค่า IP';
      } else {
        _lastError = e.response?.data['message'] ?? 'รีเซ็ตรหัสผ่านล้มเหลว';
      }
      debugPrint('Reset Password DioError: ${e.message}');
      return false;
    } catch (e) {
      _lastError = 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง';
      debugPrint('Reset Password Error: $e');
      return false;
    }
  }

  //-----------------------------------------------------------ออกจากระบบ-------------------------------------------------------------
  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await _dio.post(
          '/auth/logout',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      }
    } catch (e) {
      debugPrint('Error during backend logout: $e');
    }

    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_role');
    await _storage.delete(key: 'user_firstname');
    await _storage.delete(key: 'user_lastname');
    _currentRole = UserRole.guest;
    _firstName = null;
    _lastName = null;
    notifyListeners();
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  UserRole _parseRole(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return UserRole.admin;
      case 'TECHNICIAN':
        return UserRole.technician;
      case 'TENANT':
      default:
        return UserRole.tenant; // Default to tenant if unknown
    }
  }
}
