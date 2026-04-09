import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:universal_html/html.dart' as html;
import '../constants/app_colors.dart';

class UrlUtil {
  /// คอมโบ: โหลดเซฟลงเครื่อง และ เด้งเปิดโชว์อัตโนมัติ (รองรับทั้ง Web และ Mobile)
  static Future<void> downloadAndOpenPdf(
    BuildContext context,
    String? urlString,
    String fileName,
  ) async {
    if (urlString == null || urlString.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ไม่พบลิงก์ไฟล์หรือข้อมูลเอกสารไม่สมบูรณ์'),
          ),
        );
      }
      return;
    }

    // ระบบฉลาดสกัดนามสกุลไฟล์จาก URL อัตโนมัติ (เช่นดึง .jpg หรือ .png ออกมา)
    String extension = '.pdf'; // ให้ค่าเริ่มต้นเป็น PDF ไว้กันเหนียว
    try {
      final uri = Uri.parse(urlString);
      final segment = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
      if (segment.contains('.')) {
        extension = '.${segment.split('.').last.toLowerCase()}';
      }
    } catch (_) {}

    // --------------------------------------------------
    // 🖥️ สายที่ 1: การทำงานบน Web
    // --------------------------------------------------
    if (kIsWeb) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('กำลังสั่งดาวน์โหลดไฟล์ลงคอมพิวเตอร์...'),
          ),
        );
      }
      try {
        // ท่าไม้ตายสำหรับ Web: ใช้ Dio ดูดไฟล์มาเป็นก้อนไบต์ (Bytes) เข้าเมมโมรี่แอปก่อน
        // (เพื่อแก้ปัญหาลิงก์อยู่คนละเซิร์ฟเวอร์ Chrome เลยดื้อดึงเปิดแท็บใหม่)
        final response = await Dio().get(
          urlString,
          options: Options(responseType: ResponseType.bytes),
        );

        // นำก้อนข้อมูลแปลงเป็นไฟล์เสมือน (Blob)
        final blob = html.Blob([response.data]);
        final blobUrl = html.Url.createObjectUrlFromBlob(blob);

        // สั่งสร้าง Anchor แล้วกดลิงก์เสมือนที่อยู่ในเว็บเราเอง (บีบคอให้ดาวน์โหลด 100%)
        final html.AnchorElement anchor = html.AnchorElement(href: blobUrl)
          ..setAttribute("download", "$fileName$extension");
        anchor.click();

        // ทำลายลิงก์ทิ้งเพื่อคืนพื้นที่แรม
        html.Url.revokeObjectUrl(blobUrl);

        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }
      } catch (e) {
        if (context.mounted) {
          _showError(
            context,
            'ดาวน์โหลดล้มเหลว (หากขึ้น Error มักจะเกิดจากเซิร์ฟเวอร์ตั้งค่าติด CORS ครับ): $e',
          );
        }
      }
      return;
    }

    // --------------------------------------------------
    // 📱 สายที่ 2: การทำงานบน Mobile (Android/iOS)
    // --------------------------------------------------
    try {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Text('กำลังดาวน์โหลดไฟล์...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // 1. ขอสิทธิ์ Storage (สำคัญมากสำหรับ Android รุ่นเก่า)
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }

      // 2. หาโฟลเดอร์สำหรับเซฟ (ใช้ Documents ปกปิดไฟล์ไม่ให้รกแกลลอรี่ภาพ)
      final directory = await getApplicationDocumentsDirectory();

      // ป้องกันชื่อไฟล์มีอักขระแปลกปลอม
      final safeFileName = fileName.replaceAll(RegExp(r'[\\/:*?"<>| ]'), '_');
      final filePath = '${directory.path}/$safeFileName$extension';

      // 3. ใช้ Dio ดูดไฟล์มาเก็บ
      await Dio().download(urlString, filePath);

      if (context.mounted) {
        // ลบตัวโหลด และแจ้งเตือนเสร็จสิ้น
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ดาวน์โหลดสำเร็จ ✓ กำลังเปิดโชว์ไฟล์...'),
          ),
        );
      }

      // 4. สั่งเด้งเปิดไฟล์ด้วยแอปอ่าน PDF ในมือถือ
      final result = await OpenFilex.open(filePath);

      if (result.type != ResultType.done && context.mounted) {
        _showError(
          context,
          'ไม่สามารถโชว์ไฟล์ได้ เครื่องของคุณอาจไม่มีแอปอ่าน PDF',
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'เกิดข้อผิดพลาดในการโหลดไฟล์สลิป/สัญญา');
      }
    }
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // เผื่อเพื่อนเรียกคอมสั่งเก่า
  static Future<void> openPdf(BuildContext context, String? urlString) async {
    await downloadAndOpenPdf(context, urlString, 'document_file');
  }
}

/// Widget ปุ่ม 'Download PDF' สำเร็จรูป (ดีไซน์เดิมจากหน้ารายละเอียดสัญญา)
/// เรียกใช้ง่ายๆ แค่ส่ง URL และชื่อไฟล์มาให้ครับ
class AppContractPdfButton extends StatelessWidget {
  final String? url;      // ลิงก์ไฟล์ PDF
  final String fileName; // ชื่อที่จะให้เซฟลงเครื่อง (เช่น 'Contract_101')
  final String label;    // ข้อความบนปุ่ม (ค่าเริ่มต้นคือ 'Download PDF')

  const AppContractPdfButton({
    super.key,
    required this.url,
    required this.fileName,
    this.label = 'Download PDF',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        // พอกดปุ่มปุ๊บ จะไปเรียกใช้ฟังก์ชันอัจฉริยะที่คุณทำไว้ทันที
        onPressed: () => UrlUtil.downloadAndOpenPdf(context, url, fileName),
        icon: const Icon(
          Icons.download_outlined,
          color: AppColors.textPrimary,
        ),
        label: Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: AppColors.border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
