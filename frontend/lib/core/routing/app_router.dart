import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/features/admin/main/presentation/pages/admin_main_screen.dart';
import 'package:frontend/features/auth/presentation/pages/login_page.dart';
import 'package:frontend/features/auth/presentation/pages/register_page.dart';
import 'package:frontend/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:frontend/features/tenant/main/presentation/pages/main_screen.dart';
import 'package:frontend/features/Technicians/presentation/pages/technician_repairs_page.dart';
import 'package:frontend/features/admin/dashboard/presentation/pages/new_tenant_page.dart';
import 'package:frontend/features/admin/dashboard/presentation/pages/user_infomation_page.dart';
import 'package:frontend/features/admin/dashboard/data/get_users.dart';
import 'package:frontend/features/admin/repairs/presentation/pages/admin_technicians_page.dart';

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
          return '/technician';
        } else {
          return '/tenant';
        }
      }

      // Handle root path
      if (state.matchedLocation == '/') {
        if (isAuthenticated) {
          if (_authService.currentRole == UserRole.admin) return '/admin';
          if (_authService.currentRole == UserRole.technician) return '/technician';
          return '/tenant';
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
        path: '/technician',
        builder: (context, state) => const TechnicianRepairsPage(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminMainScreen(),
      ),
      GoRoute(
        path: '/admin/userInfomation',
        builder: (context, state) {
          final user = state.extra as UserTemplate;
          return UserInfomationPage(user: user);
        },
      ),
      GoRoute(
        path: '/admin/newTenant',
        builder: (context, state) => const NewTenantPage(),
      ),
      GoRoute(
        path: '/admin/technicians',
        builder: (context, state) => const AdminTechniciansPage(),
      ),
    ],
  );
}
