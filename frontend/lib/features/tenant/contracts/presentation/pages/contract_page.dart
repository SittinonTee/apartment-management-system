import 'package:flutter/material.dart';

class ContractPage extends StatelessWidget {
  const ContractPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('สัญญาเช่า')),
      body: const Center(child: Text('Contract Content Here')),
    );
  }
}
