import 'package:intl/intl.dart';

/// Utility class for formatting currency and numbers
class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat('#,###', 'id_ID');

  /// Format number with thousand separators (e.g., 1000000 -> 1.000.000)
  static String format(dynamic amount) {
    if (amount == null) return '0';

    final String amountStr = amount.toString();
    if (amountStr.isEmpty || amountStr == '0') {
      return '0';
    }

    // Remove any existing separators and handle decimals
    final cleanAmount = amountStr.replaceAll('.', '').replaceAll(',', '');

    // For numbers with decimals, use only the integer part for simple formatting
    // or we can handle it properly. Here, let's just use the number if it's dynamic
    if (amount is num) {
      return _formatter.format(amount.round());
    }

    // Parse to integer
    final number = int.tryParse(cleanAmount);
    if (number == null) {
      return amountStr;
    }

    // Format with thousand separators
    return _formatter.format(number);
  }

  /// Format number to Rupiah string (e.g., 1000000 -> Rp 1.000.000)
  static String formatRupiah(dynamic amount) {
    return 'Rp ${format(amount)}';
  }

  /// Parse formatted string back to raw number string (e.g., 1.000.000 -> 1000000)
  static String parse(String formattedAmount) {
    return formattedAmount.replaceAll('.', '').replaceAll(',', '');
  }
}
