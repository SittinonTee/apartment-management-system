import 'package:flutter/material.dart';

class AdminBillsPage extends StatelessWidget {
  const AdminBillsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.payments_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'จัดการบิลค่าเช่า',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('จัดการบิลแจ้งหนี้และการชำระเงิน'),
        ],
      ),
    );
  }
}
