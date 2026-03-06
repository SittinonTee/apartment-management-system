import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/features/admin/main/presentation/pages/admin_main_screen.dart';
import 'package:frontend/features/auth/presentation/pages/login_page.dart';
import 'package:frontend/features/auth/presentation/pages/register_page.dart';
import 'package:frontend/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:frontend/features/tenant/main/presentation/pages/main_screen.dart';

class AppRouter {
  static final AuthService _authService = AuthService();

  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable:
        _authService, // Re-evaluate routes when auth state changes
    redirect: (BuildContext context, GoRouterState state) {
      final bool isAuthenticated =
          _authService.isAuthenticated; // ตรวจสอบว่าผู้ใช้ล็อกอินแล้วหรือยัง
      final bool isLoggingIn =
          state.matchedLocation ==
          '/login'; // ตรวจสอบว่าผู้ใช้กำลังล็อกอินหรือไม่
      final bool isRegistering =
          state.matchedLocation ==
          '/register'; // ตรวจสอบว่าผู้ใช้กำลังสมัครสมาชิกหรือไม่
      final bool isReseting = state.matchedLocation == '/forgot-password';

      if (!isAuthenticated && !isLoggingIn && !isRegistering && !isReseting) {
        return '/login';
      }

      if (isAuthenticated && (isLoggingIn || isRegistering || isReseting)) {
        // Redirect based on role
        if (_authService.currentRole == UserRole.admin) {
          return '/admin';
        } else if (_authService.currentRole == UserRole.technician) {
          // ในอนาคตอาจมีหน้าแยกสำหรับ Technician
          return '/tenant';
        } else {
          return '/tenant';
        }
      }

      // Handle root path
      if (state.matchedLocation == '/') {
        if (isAuthenticated) {
          return _authService.currentRole == UserRole.admin
              ? '/admin'
              : '/tenant';
        }
        return '/login';
      }

      return null; // Return null means no redirect needed
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(path: '/tenant', builder: (context, state) => const MainScreen()),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminMainScreen(),
      ),
    ],
  );
}
