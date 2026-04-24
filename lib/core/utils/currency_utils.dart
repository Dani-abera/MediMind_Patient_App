import 'package:intl/intl.dart';

class CurrencyUtils {
  CurrencyUtils._();

  static final _formatter = NumberFormat('#,##0.00', 'en_US');

  static String formatETB(num amount) => 'ETB ${_formatter.format(amount)}';

  static double? parseETB(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned);
  }
}
