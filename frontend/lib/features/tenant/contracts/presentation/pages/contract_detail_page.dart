import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/status_badge.dart';
import '../../../../../core/widgets/section_card.dart';
import '../../../../../core/utils/formatter.dart';
import '../../data/contract_service.dart';
import '../../utils/contract_utils.dart';
import '../../../../../core/utils/url_util.dart';

class ContractDetailPage extends StatefulWidget {
  final int contractId;

  const ContractDetailPage({super.key, required this.contractId});

  @override
  State<ContractDetailPage> createState() => _ContractDetailPageState();
}

class _ContractDetailPageState extends State<ContractDetailPage> {
  final ContractService _contractService = ContractService();
  bool _isLoading = true;
  Map<String, dynamic>? _contractData;

  @override
  void initState() {
    super.initState();
    _fetchContractDetails();
  }

  Future<void> _fetchContractDetails() async {
    setState(() => _isLoading = true);
    final data = await _contractService.getContractDetails(widget.contractId);
    if (mounted) {
      setState(() {
        _contractData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : _contractData == null
                  ? const Center(
                      child: Text(
                        'ไม่พบข้อมูลสัญญา',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const Text(
            'รายละเอียดสัญญา',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final statusStr = _contractData!['status']?.toString();
    final badgeStatus = ContractUtils.mapStatusToBadge(statusStr);
    final badgeText = ContractUtils.mapStatusToText(statusStr);

    // เลือกสีพื้นหลัง Banner จาก Status
    Color bannerBgColor = ContractUtils.getBannerBgColor(badgeStatus);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        children: [
          // แบนเนอร์สถานะ
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bannerBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                StatusBadge(text: badgeText, status: badgeStatus),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    ContractUtils.getStatusBannerText(statusStr),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // การ์ดแสดงข้อมูลด้วย SectionCard สไตล์เพื่อน
          _buildSectionCard(
            title:
                _contractData!['contract_title']?.toString() ??
                'รายละเอียดสัญญาเช่า',
            icon: Icons.description_outlined,
            child: Column(
              children: [
                _buildInfoRow(
                  'เลขที่สัญญา',
                  '#${_contractData!['contracts_id'] ?? "-"}',
                  Icons.description_outlined,
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  'อาคาร',
                  _contractData!['building_name']?.toString() ?? '-',
                  Icons.business_outlined,
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  'เลขห้อง',
                  'ห้อง ${_contractData!['room_number'] ?? '-'}',
                  Icons.door_front_door_outlined,
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  'วันที่เริ่มอยู่อาศัย',
                  ContractUtils.formatDateThai(
                    _contractData!['start_date']?.toString(),
                  ),
                  Icons.calendar_today_rounded,
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  'วันสิ้นสุดการเช่าอาศัย',
                  ContractUtils.formatDateThai(
                    _contractData!['end_date']?.toString(),
                  ),
                  Icons.calendar_today_rounded,
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  'ค่าน้ำ (ต่อหน่วย)',
                  '${_contractData!['water_rate_per_unit'] ?? 0} บาท',
                  Icons.water_drop_outlined,
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  'ค่าไฟ (ต่อหน่วย)',
                  '${_contractData!['electric_rate_per_unit'] ?? 0} บาท',
                  Icons.bolt_outlined,
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  'ชื่อเจ้าของหอ',
                  _contractData!['owner_name']?.toString() ?? 'แอดมินหอพัก',
                  Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  'ค่าเช่าต่อเดือน',
                  '${Formatter.formatNumber(int.tryParse(_contractData!['monthly_rent']?.toString() ?? '0'))} บาท',
                  Icons.monetization_on_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ปุ่ม Download PDF (กดไม่ได้ชั่วคราว)
          // ใช้ปุ่มสำเร็จรูปที่เรายกยอดมาไว้ใน url_util.dart เรียบร้อยแล้ว
          // ประหยัดพื้นที่โค้ดและดูแลง่ายขึ้นในที่เดียวครับ
          AppContractPdfButton(
            url: _contractData?['contractfile_url']?.toString(),
            fileName: 'Contract_${_contractData?['contracts_id'] ?? 'unknown'}',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return SectionCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: AppColors.divider, height: 1),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.textSecondary.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
