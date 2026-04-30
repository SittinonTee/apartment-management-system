import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/widgets/custom_button.dart';
import 'package:frontend/core/widgets/custom_text_field.dart';
import 'package:frontend/features/admin/dashboard/presentation/dashboard_widgets/custom_dropdown_menu.dart';
import 'package:frontend/features/admin/dashboard/data/get_rate.dart';
import 'package:frontend/features/admin/dashboard/data/rate_manage_api.dart';

class RateManageTab extends StatefulWidget {
  final List<RateTemplate> rates;
  final bool isLoading;
  final VoidCallback onRefresh;

  const RateManageTab({
    super.key,
    required this.rates,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  State<RateManageTab> createState() => _RateManageTabState();
}

class _RateManageTabState extends State<RateManageTab> {
  final TextEditingController _rateSelectionController =
      TextEditingController();
  final TextEditingController _rateRoomController = TextEditingController();
  final TextEditingController _rateWaterController = TextEditingController();
  final TextEditingController _rateElectricController = TextEditingController();
  RateTemplate? _selectedRate;

  @override
  void dispose() {
    _rateSelectionController.dispose();
    _rateRoomController.dispose();
    _rateWaterController.dispose();
    _rateElectricController.dispose();
    super.dispose();
  }

  void _onRateSelected(RateTemplate? rate) {
    if (rate != null) {
      setState(() {
        _selectedRate = rate;
        _rateRoomController.text = rate.rateRoom;
        _rateWaterController.text = rate.rateWater;
        _rateElectricController.text = rate.rateElectric;
      });
    }
  }

  void _showAddRateDialog() {
    final TextEditingController newRateRoomController = TextEditingController();
    final TextEditingController newRateWaterController =
        TextEditingController();
    final TextEditingController newRateElectricController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'เพิ่มเรทราคา',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                labelText: 'ราคาเช่าห้องพัก',
                controller: newRateRoomController,
                keyboardType: TextInputType.number,
                suffixIcon: _buildRateFieldSuffix('บาท/เดือน'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                labelText: 'ค่าน้ำประปา',
                controller: newRateWaterController,
                keyboardType: TextInputType.number,
                suffixIcon: _buildRateFieldSuffix('บาท/หน่วย'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                labelText: 'ค่าไฟฟ้า',
                controller: newRateElectricController,
                keyboardType: TextInputType.number,
                suffixIcon: _buildRateFieldSuffix('บาท/หน่วย'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'ยกเลิก',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            CustomButton(
              text: 'บันทึก',
              width: 100,
              height: 40,
              onPressed: () async {
                if (newRateRoomController.text.isEmpty ||
                    newRateWaterController.text.isEmpty ||
                    newRateElectricController.text.isEmpty) {
                  return;
                }
                final result = await RateManageApi().addRate({
                  'rate_room': newRateRoomController.text.trim(),
                  'rate_water': newRateWaterController.text.trim(),
                  'rate_electric': newRateElectricController.text.trim(),
                });
                if (result['status'] == 'success') {
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                  if (mounted) {
                    widget.onRefresh();
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildRateFieldSuffix(String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'จัดการเรทราคา',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              CustomButton(
                text: 'เพิ่มเรทใหม่',
                icon: const Icon(Icons.add_circle_outline, size: 18),
                width: 120,
                height: 38,
                onPressed: _showAddRateDialog,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                CustomDropdownMenu<RateTemplate>(
                  label: 'เลือกเรทที่ต้องการแก้ไข',
                  hintText: 'เลือกเรทราคา',
                  controller: _rateSelectionController,
                  dropdownMenuEntries: widget.rates.map((rate) {
                    return DropdownMenuEntry<RateTemplate>(
                      value: rate,
                      label: 'เรทราคา ${rate.rateRoom} บาท',
                    );
                  }).toList(),
                  onSelected: _onRateSelected,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  readOnly: _selectedRate == null,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  labelText: 'ราคาเช่าห้องพัก',
                  controller: _rateRoomController,
                  suffixIcon: _buildRateFieldSuffix('บาท/เดือน'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        readOnly: _selectedRate == null,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        labelText: 'ค่าน้ำประปา',
                        controller: _rateWaterController,
                        suffixIcon: _buildRateFieldSuffix('บาท/หน่วย'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        readOnly: _selectedRate == null,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        labelText: 'ค่าไฟฟ้า',
                        controller: _rateElectricController,
                        suffixIcon: _buildRateFieldSuffix('บาท/หน่วย'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'บันทึกการแก้ไข',
                  width: double.infinity,
                  height: 50,
                  onPressed: () async {
                    if (_selectedRate == null) {
                      return;
                    }
                    final result = await RateManageApi()
                        .updateRate(_selectedRate!.id, {
                          'rate_room': _rateRoomController.text.trim(),
                          'rate_water': _rateWaterController.text.trim(),
                          'rate_electric': _rateElectricController.text.trim(),
                        });
                    if (result['status'] == 'success') {
                      if (mounted) {
                        widget.onRefresh();
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('อัปเดตเรทราคาสำเร็จ')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
