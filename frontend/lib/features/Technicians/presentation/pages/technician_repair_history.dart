import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/auth_service.dart';
import '../../data/repair_model.dart';
import '../../data/repair_service.dart';
import '../widgets/technician_repair_card.dart';
import 'technician_repair_history_detail.dart';

class TechnicianRepairHistoryPage extends StatefulWidget {
  final String? roomNumber;

  const TechnicianRepairHistoryPage({super.key, this.roomNumber});

  @override
  State<TechnicianRepairHistoryPage> createState() =>
      _TechnicianRepairHistoryPageState();
}

class _TechnicianRepairHistoryPageState
    extends State<TechnicianRepairHistoryPage> {
  final RepairService _repairService = RepairService();
  List<RepairRequest> _historyRepairs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchHistoryRepairs());
  }

  Future<void> _fetchHistoryRepairs() async {
    final currentUserId = context.read<AuthService>().userId;

    try {
      final repairs = await _repairService.getTechnicianRepairs();
      if (mounted) {
        setState(() {
          // กรองเฉพาะสถานะ ASSIGNED, PENDING และต้องเป็นงานของช่างที่ล็อกอินอยู่
          _historyRepairs = repairs
              .where(
                (r) =>
                    r.statusEnum == RepairStatus.inProgress &&
                    r.technicianId == currentUserId,
              )
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back_ios_new,
                      color: Color(0xFF5AB6A9),
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'ย้อนกลับ',
                      style: TextStyle(
                        color: Color(0xFF5AB6A9),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Column(
                  children: [
                    Text(
                      'ประวัติการซ่อม',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'ตรวจสอบประวัติการซ่อมแซมได้ที่นี่',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : _historyRepairs.isEmpty
                    ? const Center(
                        child: Text(
                          'ไม่พบประวัติการรับงาน',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _historyRepairs.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final repair = _historyRepairs[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TechnicianRepairCard(
                                repair: repair,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TechnicianRepairHistoryDetailPage(
                                            repair: repair,
                                          ),
                                    ),
                                  ).then((_) {
                                    // fetch ข้อมูลใหม่หลังจากกดยกเลิก
                                    _fetchHistoryRepairs();
                                  });
                                },
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
