import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/routing/app_router.dart';
import 'core/constants/app_theme.dart';
import 'core/services/auth_service.dart';
// import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/services/notification_service.dart';
import 'features/admin/dashboard/data/get_users.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (Requires google-services.json / GoogleService-Info.plist)
  try {
    await Firebase.initializeApp();
    final notificationService = NotificationService();
    
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(NotificationService.firebaseMessagingBackgroundHandler);
    
    await notificationService.initialize();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint('Make sure you have added google-services.json to android/app/');
  }

  await initializeDateFormatting('th', null);
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
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => AdminService()),
      ],
      child: MaterialApp.router(
        title: 'Au Usabai',
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router, // ใช้การตั้งค่าจาก Router
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
