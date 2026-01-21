import 'package:intl/intl.dart';

/// Utility class for formatting currency and numbers
class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat('#,###', 'id_ID');

  /// Format number with thousand separators (e.g., 1000000 -> 1.000.000)
  static String format(String amount) {
    if (amount.isEmpty || amount == '0') {
      return '0';
    }

    // Remove any existing separators
    final cleanAmount = amount.replaceAll('.', '').replaceAll(',', '');

    // Parse to integer
    final number = int.tryParse(cleanAmount);
    if (number == null) {
      return amount;
    }

    // Format with thousand separators
    return _formatter.format(number);
  }

  /// Format number to Rupiah string (e.g., 1000000 -> Rp 1.000.000)
  static String formatRupiah(String amount) {
    return 'Rp ${format(amount)}';
  }

  /// Parse formatted string back to raw number string (e.g., 1.000.000 -> 1000000)
  static String parse(String formattedAmount) {
    return formattedAmount.replaceAll('.', '').replaceAll(',', '');
  }
}
