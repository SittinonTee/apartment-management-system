import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/features/tenant/contracts/data/contract_service.dart';
import 'package:frontend/features/tenant/dashboard/presentation/widgets/user_greeting.dart';

class RepairsPage extends StatefulWidget {
  const RepairsPage({super.key});

  @override
  State<RepairsPage> createState() => _RepairsPageState();
}

class _RepairsPageState extends State<RepairsPage> {
  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  final ContractService _contractService = ContractService();
  Map<String, dynamic>? _contractData;
  bool _isLoading = true;

  Future<void> _fetchDashboardData() async {
    try {
      final contractData = await _contractService.getMyContract();
      if (mounted) {
        setState(() {
          _contractData = contractData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) print('Dashboard fetch error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // Process data from backend
    final roomNumber = _contractData?['room_number'] ?? 'ไม่มีข้อมูลห้อง';
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            UserGreeting(
              userName: _contractData != null
                  ? '${_contractData!['firstname']} ${_contractData!['lastname']}'
                  : 'ไม่มีข้อมูลผู้ใช้',
              roomNumber: roomNumber,
            ),
          ],
        ),
      ),
    );
  }
}
