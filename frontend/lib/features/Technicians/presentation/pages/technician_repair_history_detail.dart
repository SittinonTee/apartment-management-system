import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/repair_model.dart';

class TechnicianRepairHistoryDetailPage extends StatefulWidget {
  final RepairRequest repair;

  const TechnicianRepairHistoryDetailPage({super.key, required this.repair});

  @override
  State<TechnicianRepairHistoryDetailPage> createState() =>
      _TechnicianRepairHistoryDetailPageState();
}

class _TechnicianRepairHistoryDetailPageState
    extends State<TechnicianRepairHistoryDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildInfoCard(context),
                    const SizedBox(height: 16),
                    _buildImageCard(context),
                    const SizedBox(height: 16),
                    _buildTenantCard(context),
                    const SizedBox(height: 16),
                    _buildTechnicianCard(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // กล่องข้อมูลช่างผู้รับงาน
  Widget _buildTechnicianCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            'ช่างผู้รับงาน :',
            Text(
              widget.repair.mechanicName ?? 'รอมอบหมาย',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ส่วนหัว: ปุ่มปิด และหัวข้อ
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'รายละเอียดประวัติ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 40), // เพื่อให้หัวข้ออยู่ตรงกลาง
        ],
      ),
    );
  }

  // กล่องข้อมูลหลัก (หัวข้อ, สถานะ, รายละเอียด)
  Widget _buildInfoCard(BuildContext context) {
    final statusColor = widget.repair.statusTextColor;
    final statusBgColor = widget.repair.statusColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.repair.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.repair.statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.repair.description,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
          const Divider(height: 32, color: Color(0xFFF2F2F2)),
          _buildDetailRow(
            'รหัสแจ้งซ่อม :',
            Text(
              '#${widget.repair.id}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            'หมวดหมู่ :',
            Text(
              widget.repair.categoryName ?? 'อื่นๆ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            'วันที่แจ้ง :',
            Text(
              '${widget.repair.date.day}/${widget.repair.date.month}/${widget.repair.date.year + 543}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // กล่องแสดงรูปภาพ (ถ้ามี)
  Widget _buildImageCard(BuildContext context) {
    if (widget.repair.repairsImageUrl == null || widget.repair.repairsImageUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'รูปภาพประกอบ :',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              widget.repair.repairsImageUrl!,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // กล่องข้อมูลผู้เช่า
  Widget _buildTenantCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            'ผู้เช่า :',
            Text(
              '${widget.repair.tenantName ?? '-'} (${widget.repair.tenantPhone ?? '-'})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 24, color: Color(0xFFF2F2F2)),
          _buildDetailRow(
            'วันที่สะดวก :',
            Text(
              widget.repair.preferredTime ?? 'ไม่ระบุ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, Widget value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(child: value),
      ],
    );
  }
}
