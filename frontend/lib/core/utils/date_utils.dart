class AppDateUtils {
  static const _thaiMonthsShort = [
    '',
    'ม.ค.',
    'ก.พ.',
    'มี.ค.',
    'เม.ย.',
    'พ.ค.',
    'มิ.ย.',
    'ก.ค.',
    'ส.ค.',
    'ก.ย.',
    'ต.ค.',
    'พ.ย.',
    'ธ.ค.',
  ];

  static const _thaiMonthsMap = {
    '01': 'ม.ค.',
    '02': 'ก.พ.',
    '03': 'มี.ค.',
    '04': 'เม.ย.',
    '05': 'พ.ค.',
    '06': 'มิ.ย.',
    '07': 'ก.ค.',
    '08': 'ส.ค.',
    '09': 'ก.ย.',
    '10': 'ต.ค.',
    '11': 'พ.ย.',
    '12': 'ธ.ค.',
  };

  static const _thaiMonthsFullMap = {
    '01': 'มกราคม',
    '02': 'กุมภาพันธ์',
    '03': 'มีนาคม',
    '04': 'เมษายน',
    '05': 'พฤษภาคม',
    '06': 'มิถุนายน',
    '07': 'กรกฎาคม',
    '08': 'สิงหาคม',
    '09': 'กันยายน',
    '10': 'ตุลาคม',
    '11': 'พฤศจิกายน',
    '12': 'ธันวาคม',
  };

  /// แปลง ISO date string → "1 ม.ค. 2568"
  /// เช่น "2025-01-01T00:00:00Z" → "1 ม.ค. 2568"
  static String formatDateThai(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return '${date.day} ${_thaiMonthsShort[date.month]} ${date.year + 543}';
    } catch (_) {
      return dateStr;
    }
  }

  /// แปลง ISO date string → "01 ม.ค. 2568" (zero-padded day)
  /// เช่น "2025-01-01T00:00:00Z" → "01 ม.ค. 2568"
  static String formatDateThaiPadded(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return '${date.day.toString().padLeft(2, '0')} ${_thaiMonthsShort[date.month]} ${date.year + 543}';
    } catch (_) {
      return dateStr;
    }
  }

  /// แปลง "YYYY-MM" → "ม.ค. 68" (ย่อ)
  /// เช่น "2025-01" → "ม.ค. 25"
  static String formatMonthYearShort(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    final parts = raw.split('-');
    if (parts.length != 2) return raw;
    final year = (int.tryParse(parts[0]) ?? 0) + 543;
    final shortYear = year.toString().substring(2);
    return '${_thaiMonthsMap[parts[1]] ?? raw} $shortYear';
  }

  /// แปลง "YYYY-MM" → "มกราคม" (ชื่อเต็ม ไม่มีปี)
  /// เช่น "2025-01" → "มกราคม"
  static String formatMonthFull(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final parts = raw.split('-');
    if (parts.length != 2) return raw;
    return _thaiMonthsFullMap[parts[1]] ?? raw;
  }

  /// แปลง DateTime → "ม.ค. 2568" (เดือน + ปีเต็ม)
  static String formatMonthYearFull(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    final parts = raw.split('-');
    if (parts.length != 2) return raw;
    final year = (int.tryParse(parts[0]) ?? 0) + 543;
    return '${_thaiMonthsMap[parts[1]] ?? raw} $year';
  }
}
