import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/widgets/parcel_card.dart';
import 'package:frontend/features/tenant/packages/presentation/pages/packages_detail.dart';
import 'package:frontend/features/tenant/packages/data/packages_provider.dart';

import 'package:frontend/features/tenant/packages/presentation/pages/packages_history.dart';

class PackagesPage extends StatefulWidget {
  const PackagesPage({super.key});

  @override
  State<PackagesPage> createState() => _PackagesPageState();
}

class _PackagesPageState extends State<PackagesPage> {
  final TenantPackagesProvider _provider = TenantPackagesProvider();

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
    if (item["status"] == "PENDING") return "ตกค้าง";
    if (item["status"] == "RECEIVED") {
      String rawDate = item["received_at"]?.toString() ?? "";
      try {
        DateTime receivedDate = DateTime.parse(rawDate).toLocal();
        if (DateTime.now().difference(receivedDate).inDays >= 7) {
          return "ตกค้าง";
        }
      } catch (e) {
        // Ignored or handle date parse error implicitly
      }
      return "รอรับ";
    }
    return "ไม่ทราบสถานะ";
  }

  @override
  void initState() {
    super.initState();
    _provider.fetchParcels();
  }

  List<Map<String, dynamic>> get filteredList {
    return _provider.parcels.where((item) {
      String mappedStatus = _getMappedStatus(item);
      return mappedStatus == "รอรับ" || mappedStatus == "ตกค้าง";
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== TITLE & HISTORY LINK =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "พัสดุ",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "ตรวจสอบพัสดุของคุณที่นี่",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PackagesHistoryPage(),
                        ),
                      );
                    },
                    child: const Row(
                      children: [
                        Text(
                          "ประวัติการรับพัสดุ",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Icon(Icons.chevron_right, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ===== GREEN NOTIFICATION BANNER =====
              ListenableBuilder(
                listenable: _provider,
                builder: (context, _) {
                  if (_provider.isLoading) return const SizedBox();

                  int activeCount = _provider.parcels.where((p) {
                    final status = _getMappedStatus(p);
                    return status == "รอรับ" || status == "ตกค้าง";
                  }).length;

                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9), // Light green
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.shade200,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC8E6C9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "มีพัสดุ $activeCount รายการส่งถึงคุณแล้ว",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              "ตรวจสอบพัสดุของคุณที่นี่",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
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

                    return RefreshIndicator(
                      onRefresh: () => _provider.fetchParcels(),
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
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
                                builder: (_) => TenantPackagesDetail(
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
                                  imageUrl: item["parcelsimage_url"]?.toString() ?? "",
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
                    ),
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
