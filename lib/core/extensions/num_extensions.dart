import 'package:intl/intl.dart';

extension NumX on num {
  String get toCurrency {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return 'ETB ${formatter.format(this)}';
  }

  String get toPercent => '${(this * 100).toStringAsFixed(1)}%';

  double clamped(double min, double max) =>
      this < min ? min : (this > max ? max : toDouble());
}
