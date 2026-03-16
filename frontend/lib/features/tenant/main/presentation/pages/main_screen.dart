import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/services/auth_service.dart';

import '../../../bills/presentation/pages/bills_page.dart';
import '../../../contracts/presentation/pages/contract_page.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../packages/presentation/pages/packages_page.dart';
import '../../../repairs/presentation/pages/repairs_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    ContractPage(),
    BillsPage(),
    PackagesPage(),
    RepairsPage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed, // Ensure all items show labels
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'หน้าติดต่อ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            activeIcon: Icon(Icons.description),
            label: 'สัญญาเช่า',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
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
        ],
      ),
    );
  }
}
