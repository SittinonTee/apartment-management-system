import 'package:flutter/material.dart';

class BillsPage extends StatelessWidget {
  const BillsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('บิลค่าเช่า')),
      body: const Center(child: Text('Bills Content Here')),
    );
  }
}
