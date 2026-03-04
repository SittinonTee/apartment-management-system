import 'package:flutter/material.dart';

class RepairsPage extends StatelessWidget {
  const RepairsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('แจ้งซ่อม')),
      body: const Center(child: Text('Repairs Content Here')),
    );
  }
}
