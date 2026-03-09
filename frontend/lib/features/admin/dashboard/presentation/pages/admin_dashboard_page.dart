import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/widgets/choicechip_filter.dart';
import 'package:frontend/features/admin/dashboard/presentation/admin_widgets/card.dart';
import 'package:frontend/features/admin/dashboard/presentation/admin_widgets/searchbar.dart';
import 'package:frontend/core/widgets/custom_button.dart';
import 'package:frontend/features/admin/dashboard/presentation/data/get_users.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  // ---------------- data จาก api ----------------
  late Future<List<UserTemplate>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = Provider.of<AdminService>(
      context,
      listen: false,
    ).getUserData();
  }

  // ---------------- filter & search ----------------
  int selectedFilterIndex = 0;
  final List<String> fillterList = ['ทั้งหมด', 'ADMIN', 'TENANT', 'TECHNICIAN'];

  String searchQuery = '';
  TextEditingController searchController = TextEditingController();

  List<UserTemplate> filteredUsers(List<UserTemplate> users) {
    var result = users;
    if (selectedFilterIndex != 0) {
      final role = fillterList[selectedFilterIndex];
      result = result.where((user) => user.role == role).toList();
    }
    if (searchQuery.isNotEmpty) {
      result = result
          .where((user) => user.firstname.contains(searchQuery))
          .toList();
    }
    return result;
  }

  // คืน memory เมื่อไม่ใช้งาน TextEditingController
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Admin',
                style: textTheme.displayLarge?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              CustomButton(
                text: 'ผู้เช่าใหม่',
                textStyle: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textInverse,
                ),
                onPressed: () => context.push('/admin/newTenant'),
                icon: const Icon(Icons.person_add),
                width: 100,
                borderRadius: BorderRadius.circular(30),
              ),
            ],
          ),
          Text(
            "สรุปข้อมูลหอพักและสถานะปัจจุบัน",
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          SearchWidget(
            controller: searchController,
            onSearch: () {
              setState(() {
                searchQuery = searchController.text.trim();
              });
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 40,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: fillterList.length,
              itemBuilder: (context, i) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChipFilter(
                    label: fillterList[i],
                    selected: selectedFilterIndex == i,
                    onSelected: (_) => setState(() => selectedFilterIndex = i),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<List<UserTemplate>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('ไม่พบข้อมูลผู้ใช้งาน'));
                }

                final users = filteredUsers(snapshot.data!);

                return ScrollConfiguration(
                  behavior: ScrollConfiguration.of(
                    context,
                  ).copyWith(scrollbars: false),
                  child: ListView.separated(
                    itemCount: users.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, i) {
                      final user = users[i];
                      return CustomCard(
                        height: 100,
                        shadow: false,
                        borderColor: AppColors.border,
                        padding: EdgeInsets.zero,
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () => Navigator.pushNamed(context, '/'),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    user.firstname,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        user.email,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF9AAFAF),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right,
                                        color: Color(0xFFC8D8D8),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "เป็น  ${user.role}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFB0B0B0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
