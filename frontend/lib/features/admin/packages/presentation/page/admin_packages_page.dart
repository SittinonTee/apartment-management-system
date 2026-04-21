import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/widgets/parcel_card.dart';
import 'package:frontend/core/widgets/parcel_filter_bar.dart';
import 'package:frontend/core/widgets/searchbar.dart';
import 'package:frontend/features/admin/packages/presentation/page/admin_packages_detail.dart';
import 'package:frontend/features/admin/packages/presentation/page/admin_packages_add.dart';
import 'package:frontend/features/admin/packages/data/admin_packages_provider.dart';

class AdminPackagesPage extends StatefulWidget {
  const AdminPackagesPage({super.key});

  @override
  State<AdminPackagesPage> createState() => _AdminPackagesPageState();
}

class _AdminPackagesPageState extends State<AdminPackagesPage> {
  int selectedFilter = 0;
  String searchText = '';

  final filters = ["ทั้งหมด", "สำเร็จ", "รอรับ", "ตกค้าง"];

  final AdminPackagesProvider _provider = AdminPackagesProvider();

  String _formatThaiDateTime(String rawDate) {
    if (rawDate.isEmpty) return "";
    try {
      DateTime parsedDate = DateTime.parse(rawDate).toLocal();
      List<String> thaiMonths = [
        "",
        "ม.ค.",
        "ก.พ.",
        "มี.ค.",
        "เม.ย.",
        "พ.ค.",
        "มิ.ย.",
        "ก.ค.",
        "ส.ค.",
        "ก.ย.",
        "ต.ค.",
        "พ.ย.",
        "ธ.ค.",
      ];
      String day = parsedDate.day.toString().padLeft(2, '0');
      String month = thaiMonths[parsedDate.month];
      String year = (parsedDate.year + 543).toString();
      String hour = parsedDate.hour.toString().padLeft(2, '0');
      String minute = parsedDate.minute.toString().padLeft(2, '0');
      return "$day $month $year / $hour.$minute น.";
    } catch (e) {
      return rawDate;
    }
  }

  String _getMappedStatus(Map<String, dynamic> item) {
    if (item["status"] == "PICKED_UP") return "สำเร็จ";
    if (item["status"] == "PENDING") return "ตกค้าง"; // Backend updated status
    if (item["status"] == "RECEIVED") {
      String rawDate = item["received_at"]?.toString() ?? "";
      try {
        DateTime receivedDate = DateTime.parse(rawDate).toLocal();
        if (DateTime.now().difference(receivedDate).inDays >= 7) {
          return "ตกค้าง";
        }
      } catch (e) {
        // Fallback
      }
      return "รอรับ";
    }
    return "ไม่ทราบสถานะ";
  }

  @override
  void initState() {
    super.initState();
    // โหลดข้อมูลเมื่อเปิดหน้า
    _provider.fetchParcels();
  }

  List<Map<String, dynamic>> get filteredList {
    return _provider.parcels.where((item) {
      final name = item["name"]?.toString().toLowerCase() ?? "";
      final room = item["room_number"]?.toString().toLowerCase() ?? "";
      final searchLower = searchText.toLowerCase();

      final matchSearch =
          name.contains(searchLower) || room.contains(searchLower);

      // แปลง status ของ Backend เป็นข้อความภาษาไทยเพื่อจับคู่กับ Filter
      String mappedStatus = _getMappedStatus(item);

      final matchFilter =
          selectedFilter == 0 || mappedStatus == filters[selectedFilter];

      return matchSearch && matchFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AdminPackagesAdd()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "รายการพัสดุ",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              SearchWidget(
                onSearch: (value) {
                  setState(() => searchText = value);
                },
              ),

              const SizedBox(height: 16),

              ParcelFilterBar(
                filters: filters,
                selectedIndex: selectedFilter,
                onChanged: (index) {
                  setState(() => selectedFilter = index);
                },
              ),

              const SizedBox(height: 16),

              Expanded(
                child: ListenableBuilder(
                  listenable: _provider,
                  builder: (context, child) {
                    if (_provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final list = filteredList;

                    if (list.isEmpty) {
                      return const Center(child: Text("ไม่มีข้อมูลพัสดุ"));
                    }

                    return ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final item = list[index];

                        String displayStatus = _getMappedStatus(item);

                        String rawDate = item["received_at"]?.toString() ?? "";
                        String displayDate = _formatThaiDateTime(rawDate);

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminPackagesDetail(
                                  // ส่งไอดี หรือข้อมูลอื่นๆ ตามต้องการหน้า detail
                                  id: item["parcels_id"] is int
                                      ? item["parcels_id"]
                                      : int.tryParse(
                                              item["parcels_id"].toString(),
                                            ) ??
                                            0,
                                  date: displayDate,
                                  name: item["name"]?.toString() ?? "",
                                  room: item["room_number"]?.toString() ?? "",
                                  status: displayStatus,
                                  receivedBy:
                                      item["received_by"]?.toString() ??
                                      "ไม่ทราบชื่อ",
                                  imageUrl: item['parcelsimage_url']?.toString() ?? "",
                                ),
                              ),
                            );
                          },
                          child: ParcelCard(
                            date: displayDate,
                            name: item["name"]?.toString() ?? "",
                            room: item["room_number"]?.toString() ?? "",
                            status: displayStatus,
                          ),
                        );
                      },
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
