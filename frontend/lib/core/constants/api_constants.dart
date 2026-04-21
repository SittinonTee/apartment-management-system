class ApiConstants {
  // ดึงค่า URL จากตัวแปรสภาพแวดล้อมตอน Build (ใช้ --dart-define=API_URL=...)
  // หากไม่มีการกำหนด จะใช้ localhost:3000 เป็นค่าเริ่มต้น (สำหรับรันเทสในเครื่อง)
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3000/api',
  );
}
