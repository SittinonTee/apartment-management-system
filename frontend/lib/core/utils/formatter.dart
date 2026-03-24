import 'package:intl/intl.dart';

class Formatter {
  /// Formats a number with comma separators.
  /// Example: 1500 -> "1,500"
  static String formatNumber(num? value) {
    if (value == null) return '0';
    return NumberFormat.decimalPattern().format(value);
  }

  /// Formats a number with currency symbol (Baht) and comma separators.
  /// Example: 1500 -> "1,500 บาท"
  static String formatCurrency(num? value) {
    if (value == null) return '0 บาท';
    return '${formatNumber(value)} บาท';
  }

  /// Formats a string number with comma separators.
  /// Useful for values that come as strings from API or controllers.
  static String formatStringNumber(String? value) {
    if (value == null || value.isEmpty) return '0';
    final cleanValue = unformat(value);
    final parsedValue = num.tryParse(cleanValue);
    return formatNumber(parsedValue);
  }

  /// Removes commas from a formatted numeric string.
  /// Example: "1,500" -> "1500"
  static String unformat(String value) {
    return value.replaceAll(',', '');
  }

  /// Parses a potentially formatted string to a double.
  static double parseDouble(String? value) {
    if (value == null || value.isEmpty) return 0.0;
    return double.tryParse(unformat(value)) ?? 0.0;
  }
}
