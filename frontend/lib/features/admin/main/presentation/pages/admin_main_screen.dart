import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/features/admin/dashboard/presentation/pages/admin_dashboard_page.dart';
import 'package:frontend/features/admin/bills/presentation/pages/admin_bills_page.dart';
import 'package:frontend/features/admin/packages/presentation/page/admin_packages_page.dart';
import 'package:frontend/features/admin/repairs/presentation/pages/admin_repairs_page.dart';
import 'package:frontend/features/admin/manage/presentation/page/manage_page.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  // Real pages for Admin
  final List<Widget> _pages = [
    const AdminDashboardPage(),
    const AdminBillsPage(),
    const AdminPackagesPage(),
    const AdminRepairsPage(),
    const ManagePage(),
  ];

  final List<String> _titles = [
    'หน้าหลักผู้ดูแล',
    'บิลค่าเช่า',
    'รับพัสดุ',
    'ยื่นเรื่องซ่อม',
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(_titles[_currentIndex]),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.logout),
      //       onPressed: () => context.read<AuthService>().logout(),
      //     ),
      //   ],
      // ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings_outlined),
            activeIcon: Icon(Icons.admin_panel_settings),
            label: 'หน้าหลักผู้ดูแล',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments_outlined),
            activeIcon: Icon(Icons.payments),
            label: 'บิลค่าเช่า',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'รับพัสดุ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build_outlined),
            activeIcon: Icon(Icons.build),
            label: 'ยื่นเรื่องซ่อม',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.meeting_room),
            activeIcon: Icon(Icons.meeting_room),
            label: 'ราคาห้อง',
          ),
        ],
      ),
    );
  }
}
