import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/widgets/parcel_card.dart';
import 'package:frontend/features/tenant/packages/presentation/pages/packages_detail.dart';
import 'package:frontend/features/tenant/packages/data/packages_provider.dart';

class PackagesHistoryPage extends StatefulWidget {
  const PackagesHistoryPage({super.key});

  @override
  State<PackagesHistoryPage> createState() => _PackagesHistoryPageState();
}

class _PackagesHistoryPageState extends State<PackagesHistoryPage> {
  final TenantPackagesProvider _provider = TenantPackagesProvider();

  String _getThaiMonth(int month) {
    List<String> months = [
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
    return months[month];
  }

  @override
  void initState() {
    super.initState();
    if (_provider.parcels.isEmpty) {
      _provider.fetchParcels();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          "ประวัติการรับพัสดุ",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: ListenableBuilder(
        listenable: _provider,
        builder: (context, _) {
          if (_provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = _provider.parcels.where((p) {
            return p["status"] == "PICKED_UP" || p["status"] == "สำเร็จ";
          }).toList();

          if (list.isEmpty) {
            return const Center(child: Text("ไม่มีประวัติการรับพัสดุ"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];

              String rawDate = item["received_at"]?.toString() ?? "";
              try {
                DateTime d = DateTime.parse(rawDate).toLocal();
                rawDate =
                    "${d.day.toString().padLeft(2, '0')} ${_getThaiMonth(d.month)} ${d.year + 543} / ${d.hour.toString().padLeft(2, '0')}.${d.minute.toString().padLeft(2, '0')} น.";
              } catch (_) {}

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TenantPackagesDetail(
                        id: item["parcels_id"] ?? 0,
                        date: rawDate,
                        name: item["name"] ?? "",
                        room: item["room_number"] ?? "",
                        status: "สำเร็จ",
                        receivedBy: item["received_by"] ?? "ไม่ทราบชื่อ",
                      ),
                    ),
                  );
                },
                child: ParcelCard(
                  date: rawDate,
                  name: item["name"] ?? "",
                  room: item["room_number"] ?? "",
                  status: "สำเร็จ",
                ),
              );
            },
          );
        },
      ),
    );
  }
}
