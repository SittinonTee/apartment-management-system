import 'package:flutter/material.dart';

import '../../../../../core/widgets/status_badge.dart';
import '../widgets/bill_summary_card.dart';
import '../widgets/contract_progress_card.dart';
import '../widgets/quick_action_menu.dart';
import '../widgets/user_greeting.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Keep appbar hidden or simple to allow custom header
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const UserGreeting(
                userName: 'สิทธินนท์ จันประทุม', // Mocked user from Figma
                roomNumber: 'A329',
              ),
              const SizedBox(height: 24),
              const ContractProgressCard(
                progressPercent: 0.67,
                timeRemaining: '4 เดือน',
              ),
              const SizedBox(height: 32),
              QuickActionMenu(
                onContractPressed: () {
                  // Navigate to Contract
                },
                onBillsPressed: () {
                  // Navigate to Bills
                },
                onPackagePressed: () {
                  // Navigate to Packages
                },
                onRepairPressed: () {
                  // Navigate to Repairs
                },
              ),
              const SizedBox(height: 32),
              BillSummaryCard(
                amount: 8000.00,
                month: 'พฤษภาคม 2567',
                status: BadgeStatus.pending,
                statusText: 'รอชำระ',
                onPayPressed: () {
                  // Navigate to Payment
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
