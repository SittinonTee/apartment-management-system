import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/widgets/choicechip_filter.dart';
import 'package:frontend/features/admin/dashboard/presentation/dashboard_widgets/users_info_card.dart';
import 'package:frontend/core/widgets/searchbar.dart';
import 'package:frontend/core/widgets/custom_button.dart';
import 'package:frontend/features/admin/dashboard/data/get_users.dart';
import 'package:frontend/features/admin/dashboard/presentation/dashboard_widgets/dashboard_summary.dart';
import 'package:frontend/features/admin/dashboard/data/get_vailable_room.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/services/auth_service.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  // ---------------- data จาก api ----------------
  late Future<List<UserTemplate>> _usersFuture;
  late Future<List<RoomTemplate>> _vacantRoomsFuture;
  late Future<List<dynamic>> _dashboardSummaryFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _usersFuture = Provider.of<AdminService>(
      context,
      listen: false,
    ).getUserData();
    _vacantRoomsFuture = GetAvailableRoom().getAvailableRooms();
    _dashboardSummaryFuture = Future.wait([_usersFuture, _vacantRoomsFuture]);
  }

  // ---------------- filter & search ----------------
  int selectedFilterIndex = 1;
  final List<String> filterList = [
    'ทั้งหมด',
    'ACTIVE',
    'INACTIVE',
    'TERMINATED',
  ];

  String searchQuery = '';

  List<UserTemplate> filteredUsers(List<UserTemplate> users) {
    var result = users.where((user) => user.role == 'TENANT').toList();
    if (selectedFilterIndex != 0) {
      final status = filterList[selectedFilterIndex];
      result = result
          .where(
            (user) =>
                user.contractStatus == status || user.userStatus == status,
          )
          .toList();
    }
    if (searchQuery.isNotEmpty) {
      result = result
          .where(
            (user) =>
                user.firstname.contains(searchQuery) ||
                user.lastname.contains(searchQuery) ||
                (user.roomNumber != null &&
                    user.roomNumber!.contains(searchQuery)),
          )
          .toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0),
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
              Row(
                children: [
                  CustomButton(
                    text: 'ผู้เช่าใหม่',
                    textStyle: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textInverse,
                    ),
                    onPressed: () async {
                      await context.push('/admin/newTenant');
                      setState(() {
                        _loadData();
                      });
                    },
                    icon: const Icon(Icons.person_add),
                    width: 100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  const SizedBox(width: 12),
                  CustomButton(
                    isPrimary: false,
                    isOutlined: true,
                    onPressed: () {
                      context.read<AuthService>().logout();
                    },
                    icon: const Icon(
                      Icons.logout,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    width: 34,
                    height: 34,
                    padding: const EdgeInsets.only(left: 6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ],
              ),
            ],
          ),
          Text(
            "หน้าจัดการของผู้ดูแล",
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder(
            future: _dashboardSummaryFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 72,
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return const SizedBox(height: 72);
              }

              final users = snapshot.data![0] as List<UserTemplate>;
              final vacantRooms = snapshot.data![1] as List<RoomTemplate>;

              final totalTenants = users
                  .where((u) => u.role == 'TENANT')
                  .length;
              final totalAdmins = users.where((u) => u.role == 'ADMIN').length;

              return DashboardSummary(
                totalTenants: totalTenants,
                vacantRooms: vacantRooms.length,
                totalAdmins: totalAdmins,
              );
            },
          ),
          const SizedBox(height: 16),
          SearchWidget(
            onSearch: (value) => setState(() => searchQuery = value),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 40,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: filterList.length,
              itemBuilder: (context, i) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChipFilter(
                    label: filterList[i],
                    selected: selectedFilterIndex == i,
                    onSelected: (_) => setState(() => selectedFilterIndex = i),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "ผู้ใช้งานทั้งหมดในระบบ",
            style: textTheme.titleLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<UserTemplate>>(
              future: _usersFuture, // งานที่กำลังรอผล
              builder: (context, snapshot) {
                // UI ระหว่างรอ snapshot(ข้อมูลที่ได้)
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('ไม่พบข้อมูลผู้ใช้งาน'));
                }
                // ใส่ไว้ใน users
                final users = filteredUsers(snapshot.data!);

                return ScrollConfiguration(
                  behavior: ScrollConfiguration.of(
                    context,
                  ).copyWith(scrollbars: false),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 18),
                    itemCount: users.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, i) {
                      final user = users[i];
                      return UsersInfoCard(
                        user: user,
                        onTap: () async {
                          await context.push(
                            '/admin/userInfomation',
                            extra: user,
                          );
                          setState(() {
                            _loadData();
                          });
                        },
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
