import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/features/admin/main/presentation/pages/admin_main_screen.dart';
import 'package:frontend/features/auth/presentation/pages/login_page.dart';
import 'package:frontend/features/auth/presentation/pages/register_page.dart';
import 'package:frontend/features/tenant/main/presentation/pages/main_screen.dart';
import 'package:frontend/features/admin/dashboard/presentation/pages/new_tenant_page.dart';

class AppRouter {
  static final AuthService _authService = AuthService();

  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable:
        _authService, // Re-evaluate routes when auth state changes
    redirect: (BuildContext context, GoRouterState state) {
      final bool isAuthenticated = _authService.isAuthenticated;
      final bool isLoggingIn = state.matchedLocation == '/login';
      final bool isRegistering = state.matchedLocation == '/register';

      if (!isAuthenticated && !isLoggingIn && !isRegistering) {
        return '/login';
      }

      if (isAuthenticated && (isLoggingIn || isRegistering)) {
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
      GoRoute(path: '/tenant', builder: (context, state) => const MainScreen()),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminMainScreen(),
      ),
      GoRoute(
        path: '/admin/newTenant',
        builder: (context, state) => const NewTenantPage(),
      ),
    ],
  );
}
