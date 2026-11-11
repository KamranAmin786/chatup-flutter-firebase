import 'package:intl/intl.dart';

String chatTime(DateTime? time) {
  if (time == null) return '';
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(time.year, time.month, time.day);
  if (day == today) return DateFormat('HH:mm').format(time);
  if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
  return DateFormat('dd/MM/yy').format(time);
}

String lastSeenText(DateTime? time) {
  if (time == null) return 'offline';
  final day = chatTime(time);
  final clock = DateFormat('HH:mm').format(time);
  if (day == clock) return 'last seen today at $clock';
  return 'last seen ${day.toLowerCase()} at $clock';
}

String dayLabel(DateTime time) {
  final label = chatTime(time);
  if (label.contains(':')) return 'Today';
  if (label == 'Yesterday') return label;
  return DateFormat('d MMMM yyyy').format(time);
}
