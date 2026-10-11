import 'package:intl/intl.dart';

/// Indian-format money and date helpers used across the app.
class Formatters {
  Formatters._();

  static final NumberFormat _inr = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final DateFormat _date = DateFormat('d MMM yyyy');

  /// 20000 -> "₹20,000"
  static String rupees(num value) => _inr.format(value.round());

  /// 2026-11-09 -> "9 Nov 2026"
  static String date(DateTime value) => _date.format(value);

  /// Masks all but the last four digits: "•••• 4521"
  static String maskAccount(String account) {
    if (account.length <= 4) return account;
    return '•••• ${account.substring(account.length - 4)}';
  }

  /// "9876543210" -> "98765 43210"
  static String mobile(String digits) {
    if (digits.length != 10) return digits;
    return '${digits.substring(0, 5)} ${digits.substring(5)}';
  }
}
