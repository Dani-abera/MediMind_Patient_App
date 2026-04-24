import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String phone(String digits) {
    final clean = digits.replaceAll(RegExp(r'\D'), '');
    if (clean.length < 9) return '+251 $clean';
    final part1 = clean.substring(0, 3);
    final part2 = clean.substring(3, 6);
    final part3 = clean.substring(6);
    return '+251 $part1 $part2 $part3';
  }

  static String currency(num amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return 'ETB ${formatter.format(amount)}';
  }

  static String date(DateTime dt) => DateFormat('MMM dd, yyyy').format(dt);

  static String dateTime(DateTime dt) =>
      DateFormat("MMM dd, yyyy '·' h:mm a").format(dt);

  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
    if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    if (diff.inDays < 7) return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    }
    if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    }
    final years = (diff.inDays / 365).floor();
    return '$years year${years == 1 ? '' : 's'} ago';
  }
}
