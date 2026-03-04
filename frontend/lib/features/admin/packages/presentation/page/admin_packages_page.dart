import 'package:flutter/material.dart';

class AdminPackagesPage extends StatelessWidget {
  const AdminPackagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'จัดการพัสดุ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('ลงทะเบียนและจัดการการรับพัสดุ'),
        ],
      ),
    );
  }
}
