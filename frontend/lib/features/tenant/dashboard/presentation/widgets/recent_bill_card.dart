import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/section_card.dart';
import '../../../../../core/widgets/status_badge.dart';

class RecentBillCard extends StatefulWidget {
  final String month; // เดือนระบุในบิล
  final double amount; // ยอดรวม
  final BadgeStatus status; // สถานะ
  final String statusText; // ข้อความสถานะ
  final String roomNumber; // เลขห้อง
  final String tenantName; // ชื่อผู้เช่า
  final String dueDate; // กำหนดชำระ
  final String? paymentDate; // วันที่ชำระ
  final String? paymentMethod; // วิธีชำระ

  const RecentBillCard({
    super.key,
    required this.month,
    required this.amount,
    required this.status,
    required this.statusText,
    required this.roomNumber,
    required this.tenantName,
    required this.dueDate,
    this.paymentDate,
    this.paymentMethod,
  });

  @override
  State<RecentBillCard> createState() => _RecentBillCardState();
}

class _RecentBillCardState extends State<RecentBillCard> {
  bool _isExpanded = false;

  Color _getStatusColor() {
    switch (widget.status) {
      case BadgeStatus.completed:
        return AppColors.success;
      case BadgeStatus.pending:
        return AppColors.warning;
      case BadgeStatus.urgent:
        return AppColors.error;
      case BadgeStatus.info:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return SectionCard(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              // ไอคอนฝั่งซ้ายพร้อมพื้นหลังสีตามสถานะ
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  color: statusColor,
                  size: 28,
                ),
              ),

              const SizedBox(width: 16),
              // ข้อมูลบิล (เดือน และ ยอดรวม)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'บิลเดือน ${widget.month}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ยอดรวม ${NumberFormat.decimalPattern().format(widget.amount)} บาท',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // สถานะและปุ่มขยาย
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusBadge(text: widget.statusText, status: widget.status),
                  const SizedBox(height: 8),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textSecondary,
                    size: 24,
                  ),
                ],
              ),
            ],
          ),
          // ข้อมูลเพิ่มเติมเมื่อขยาย
          if (_isExpanded) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: AppColors.divider),
            ),
            _buildDetailRow('ห้อง', widget.roomNumber, isMain: true),
            const SizedBox(height: 8),
            _buildDetailRow(
              'ผู้เช่า',
              widget.tenantName,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildDetailValueRow(
              'จำนวนเงินที่ต้องชำระ',
              '${NumberFormat.decimalPattern().format(widget.amount)} บาท',
              isHighlight: true,
            ),
            const SizedBox(height: 8),
            _buildDetailValueRow('กำหนดชำระ', widget.dueDate),
            if (widget.paymentDate != null) ...[
              const SizedBox(height: 8),
              _buildDetailValueRow('ชำระเมื่อ', widget.paymentDate!),
            ],
            if (widget.paymentMethod != null) ...[
              const SizedBox(height: 8),
              _buildDetailValueRow(
                'วิธีชำระ',
                widget.paymentMethod!,
                icon: Icons.credit_card,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isMain = false,
    IconData? icon,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
        ],
        Text(
          isMain ? '$label $value' : '$label: $value',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: isMain ? FontWeight.bold : FontWeight.normal,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailValueRow(
    String label,
    String value, {
    bool isHighlight = false,
    IconData? icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: AppColors.textPrimary),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                fontSize: isHighlight ? 20 : 16,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
