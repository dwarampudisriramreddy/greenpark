import 'package:intl/intl.dart';

/// Formats a price in Indian Rupees.
String formatINR(num amount) {
  final f = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: amount == amount.roundToDouble() ? 0 : 2,
  );
  return f.format(amount);
}

/// Human-friendly relative date ("3 days ago") for post timelines.
String timeAgo(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hr ago';
  if (diff.inDays < 7) return '${diff.inDays} days ago';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
  return DateFormat('d MMM yyyy').format(time);
}

/// "12 Aug 2026"
String formatDate(DateTime time) => DateFormat('d MMM yyyy').format(time);

/// "Aug 2026"
String formatMonthYear(DateTime time) => DateFormat('MMM yyyy').format(time);

/// "12:30 PM" for a time string like "12:30".
String formatTime(String time) {
  try {
    return DateFormat('h:mm a').format(DateFormat('HH:mm').parse(time));
  } catch (_) {
    return time;
  }
}
