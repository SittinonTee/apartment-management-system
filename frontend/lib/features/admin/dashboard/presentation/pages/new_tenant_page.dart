import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/widgets/custom_button.dart';
import 'package:frontend/features/admin/dashboard/presentation/admin_widgets/card.dart';
import 'package:go_router/go_router.dart';

class NewTenantPage extends StatefulWidget {
  const NewTenantPage({super.key});

  @override
  State<NewTenantPage> createState() => _NewTenantPageState();
}

class _NewTenantPageState extends State<NewTenantPage> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _roomNumberController = TextEditingController();
  final _initialPasswordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _roomNumberController.dispose();
    _initialPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back_ios, color: AppColors.primary, size: 18),
              Text('ย้อนกลับ', style: TextStyle(color: AppColors.primary)),
            ],
          ),
        ),
        leadingWidth: 100,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(textTheme),
                const SizedBox(height: 32),

                _buildSectionTitle('ข้อมูลส่วนตัว', Icons.person_outline),
                const SizedBox(height: 12),
                _buildPersonalInfoSection(),

                const SizedBox(height: 24),

                _buildSectionTitle('ข้อมูลที่พัก', Icons.meeting_room_outlined),
                const SizedBox(height: 12),
                _buildRoomInfoSection(),

                const SizedBox(height: 24),

                _buildSectionTitle('การตั้งค่าบัญชี', Icons.lock_outline),
                const SizedBox(height: 12),
                _buildAccountSettingsSection(),

                const SizedBox(height: 40),

                CustomButton(
                  text: 'สร้างบัญชีผู้เช่า',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: Implement create tenant logic
                    }
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme) {
    return Column(
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
          style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
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
    );
  }

  Widget _buildPersonalInfoSection() {
    return CustomCard(
      height: null,
      shadow: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'ชื่อจริง',
                  controller: _firstNameController,
                  hint: 'เช่น สมชาย',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  label: 'นามสกุล',
                  controller: _lastNameController,
                  hint: 'เช่น ใจดี',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'เบอร์โทรศัพท์',
            controller: _phoneController,
            hint: '081-XXX-XXXX',
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_android,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'อีเมล',
            controller: _emailController,
            hint: 'email@example.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildRoomInfoSection() {
    return CustomCard(
      height: null,
      shadow: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTextField(
            label: 'เลขห้อง',
            controller: _roomNumberController,
            hint: 'เช่น A101',
            prefixIcon: Icons.grid_view,
          ),
          const SizedBox(height: 16),
          // You could add a Dropdown for room type here if needed
          _buildTextField(
            label: 'ประเภทห้อง (ตัวเลือก)',
            hint: 'เช่น Studio, 1 Bedroom',
            prefixIcon: Icons.category_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettingsSection() {
    return CustomCard(
      height: null,
      shadow: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTextField(
            label: 'รหัสผ่านเริ่มต้น',
            controller: _initialPasswordController,
            hint: 'อย่างน้อย 6 ตัวอักษร',
            obscureText: true,
            prefixIcon: Icons.password,
          ),
          const SizedBox(height: 8),
          const Text(
            'ผู้เช่าจะสามารถเปลี่ยนรหัสผ่านเองได้ภายหลังจากการเข้าสู่ระบบครั้งแรก',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    String? hint,
    TextEditingController? controller,
    bool obscureText = false,
    TextInputType? keyboardType,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 20, color: AppColors.textSecondary)
                : null,
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              if (label.contains('(ตัวเลือก)')) return null;
              return 'กรุณากรอก$label';
            }
            return null;
          },
        ),
      ],
    );
  }
}
