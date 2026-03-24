import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/widgets/custom_button.dart';
import 'package:frontend/features/admin/dashboard/presentation/dashboard_widgets/confirm_dialog.dart';
import 'package:frontend/features/admin/dashboard/presentation/dashboard_widgets/contract_form.dart';
import 'package:frontend/features/admin/dashboard/presentation/dashboard_widgets/users_form.dart';
import 'package:frontend/features/admin/dashboard/presentation/data/admin_service_api.dart';
import 'package:go_router/go_router.dart';

class NewTenantPage extends StatefulWidget {
  const NewTenantPage({super.key});

  @override
  State<NewTenantPage> createState() => _NewTenantPageState();
}

class _NewTenantPageState extends State<NewTenantPage> {
  final _formKey = GlobalKey<FormState>();
  final _personalInfoKey = GlobalKey<UserFormState>();
  final _contractKey = GlobalKey<ContractFormState>();

  void _showConfirmation() {
    // ---------------- SnackBar validate ข้อมูล (ทำงานก่อนเลย) ----------------
    final isPersonalValid = _personalInfoKey.currentState?.validate() ?? false;
    final isContractValid = _contractKey.currentState?.validate() ?? false;

    if (!isPersonalValid || !isContractValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอกข้อมูลให้ครบถ้วนและถูกต้อง'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // ---------------- ดึงข้อมูลมาจาก form (ที่ map) ----------------
    final personalRaw = _personalInfoKey.currentState?.getRawData() ?? {};
    final contractRaw = _contractKey.currentState?.getRawData() ?? {};

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ConfirmDialog(
        personalInfo: personalRaw,
        contractInfo: contractRaw,
        onConfirm: (generatedData) async {
          Navigator.pop(dialogContext); // Close dialog

          // รวมข้อมูลทั้งหมด (รวมที่ format เวลาแล้ว)
          final combinedData = {
            ...personalRaw,
            ...contractRaw,
            ...generatedData, // invite_code, contract_no, start_date, end_date
          };

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('กำลังส่งข้อมูลเข้าสู่ระบบ...'),
              backgroundColor: AppColors.primary,
            ),
          );

          final result = await AdminServiceApi().addTenant(combinedData);

          if (!mounted) return;

          if (result['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('เพิ่มผู้เช่าและสร้างสัญญาสำเร็จ'),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop(); // กลับหน้าหลัก
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  result['message'] ?? 'เกิดข้อผิดพลาดในการบันทึกข้อมูล',
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        onCancel: () => Navigator.pop(dialogContext),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
        title: const Text(
          'เพิ่มผู้เช่ารายใหม่',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'เพิ่มผู้เช่าใหม่',
                      style: textTheme.displaySmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'กรอกรายละเอียดด้านล่างเพื่อสร้างบัญชีผู้เช่าใหม่ในระบบ',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                _buildSection(
                  icon: Icons.person_outline,
                  title: 'ข้อมูลส่วนตัว',
                  child: UserForm(key: _personalInfoKey),
                ),

                _buildSection(
                  icon: Icons.assignment_outlined,
                  title: 'รายละเอียดสัญญาเช่า',
                  child: ContractForm(key: _contractKey),
                ),

                const SizedBox(height: 16),
                CustomButton(
                  text: 'ยืนยันข้อมูลและสร้างสัญญา',
                  height: 56,
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  onPressed: _showConfirmation,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Column(
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
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
        const SizedBox(height: 24),
      ],
    );
  }
}
