import 'package:flutter/material.dart';

class AdminRepairsPage extends StatelessWidget {
  const AdminRepairsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.build_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'จัดการเรื่องซ่อม',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('ติดตามและจัดการรายการแจ้งซ่อม'),
        ],
      ),
    );
  }
}
