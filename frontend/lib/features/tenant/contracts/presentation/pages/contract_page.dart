import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/choicechip_filter.dart';
import '../../data/contract_service.dart';
import '../../utils/contract_utils.dart';
import '../widgets/contract_list_card.dart';
import 'contract_detail_page.dart';

class ContractPage extends StatefulWidget {
  const ContractPage({super.key});

  @override
  State<ContractPage> createState() => _ContractPageState();
}

class _ContractPageState extends State<ContractPage> {
  int _selectedIndex = 0;
  final List<String> _categories = [
    'ทั้งหมด',
    'ใช้งานอยู่',
    'กำลังรอ',
    'สิ้นสุด',
    'ยกเลิก',
  ];

  bool _isLoading = true;
  List<dynamic> _contracts = [];
  final ContractService _contractService = ContractService();

  @override
  void initState() {
    super.initState();
    _fetchContracts();
  }

  Future<void> _fetchContracts() async {
    setState(() => _isLoading = true);
    final data = await _contractService.getMyContracts();
    
    // จัดเรียงข้อมูลให้สถานะ 'ACTIVE' (ใช้งานอยู่) ขึ้นกล่องบนสุดเสมอ
    if (data != null) {
      data.sort((a, b) {
        final statusA = a['status']?.toString().toUpperCase() ?? '';
        final statusB = b['status']?.toString().toUpperCase() ?? '';
        if (statusA == 'ACTIVE' && statusB != 'ACTIVE') return -1;
        if (statusA != 'ACTIVE' && statusB == 'ACTIVE') return 1;
        return 0; // สถานะอื่นๆ ให้เรียงตามลำดับเดิมที่ส่งมาจาก Backend
      });
    }

    if (mounted) {
      setState(() {
        _contracts = data ?? [];
        _isLoading = false;
      });
    }
  }



  // จัดการฟิลเตอร์หมวดหมู่
  List<dynamic> get _filteredContracts {
    if (_selectedIndex == 0) return _contracts;
    
    final statusFilter = _categories[_selectedIndex];
    return _contracts.where((c) {
      final textStatus = ContractUtils.mapStatusToText(c['status']?.toString());
      return textStatus == statusFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final displayContracts = _filteredContracts;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildFilterBar(),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : displayContracts.isEmpty
                      ? const Center(
                          child: Text(
                            'ไม่พบข้อมูลสัญญาเช่า',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                          itemCount: displayContracts.length,
                          itemBuilder: (context, index) {
                            final contract = displayContracts[index];
                            final statusStr = contract['status']?.toString();
                            
                            // จัด Format วันที่
                            final startDate = ContractUtils.formatDateThai(contract['start_date']?.toString());
                            final endDate = ContractUtils.formatDateThai(contract['end_date']?.toString());
                            final dateRange = (startDate.isNotEmpty && endDate.isNotEmpty) 
                                ? '$startDate - $endDate' 
                                : '-';

                            // ดึงเปอร์เซ็นต์ (แปลงจาก Float String)
                            double? progress;
                            if (contract['occupancy_percent'] != null) {
                              final rawVal = double.tryParse(contract['occupancy_percent'].toString());
                              if (rawVal != null) {
                                // ถ้า Backend ส่งมาเป็น Format 0-100 (เช่น 74.93) ให้แปลงกลับเป็น 0.0-1.0 
                                progress = rawVal > 1.0 ? rawVal / 100.0 : rawVal;
                              }
                            }

                            return ContractListCard(
                              title: contract['contract_title']?.toString() ?? 'สัญญารอการอนุมัติ',
                              roomInfo: contract['room_display']?.toString() ?? 'รอยืนยันห้องพัก',
                              dateRange: dateRange,
                              rentPrice: '${contract['monthly_rent'] ?? 0} บาท/เดือน',
                              status: ContractUtils.mapStatusToBadge(statusStr),
                              statusText: ContractUtils.mapStatusToText(statusStr),
                              progressPercent: (statusStr?.toUpperCase() == 'ACTIVE') ? progress : null, 
                              onTap: () {
                                final contractId = contract['contracts_id'];
                                if (contractId != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ContractDetailPage(
                                        contractId: int.parse(contractId.toString()),
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'สัญญาของฉัน',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'ตรวจสอบรายละเอียดสัญญาของคุณที่นี่',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final isSelected = _selectedIndex == index;
            return ChoiceChipFilter(
              label: _categories[index],
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedIndex = index);
              },
              selectedColor: AppColors.primary,
              bgColor: Colors.white,
              shape: _getChipShape(isSelected),
            );
          },
        ),
      ),
    );
  }

  OutlinedBorder _getChipShape(bool isSelected) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(100),
      side: isSelected
          ? BorderSide.none
          : const BorderSide(color: AppColors.border, width: 1),
    );
  }
}
