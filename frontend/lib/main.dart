import 'package:flutter/material.dart';
import 'package:frontend/features/tenant/main/presentation/pages/main_screen.dart';

import 'core/routing/app_router.dart';
import 'core/constants/app_theme.dart';
import 'core/services/auth_service.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  //   @override
  //   Widget build(BuildContext context) {
  //     // return MaterialApp.router(
  //     //   title: 'Tenant Portal',
  //     //   theme: AppTheme.lightTheme,
  //     //   routerConfig: AppRouter.router,
  //     //   debugShowCheckedModeBanner: false,
  //     // );
  //     // return MultiProvider(
  //     //   providers: [ChangeNotifierProvider(create: (_) => AuthService())],
  //     //   child: MaterialApp.router(
  //     //     title: 'Tenant Portal',
  //     //     theme: AppTheme.lightTheme,
  //     //     routerConfig: AppRouter.router,
  //     //     debugShowCheckedModeBanner: false,
  //     //   ),
  //     // );
  //     return MaterialApp(
  //       title: 'Tenant Portal',
  //       theme: AppTheme.lightTheme,
  //       home: MainScreen(),
  //       debugShowCheckedModeBanner: false,
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthService())],
      child: MaterialApp.router(
        title: 'Tenant Portal',
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router, // ใช้การตั้งค่าจาก Router
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
