/// Year-first dates only; never guess ambiguous month/day ordering.
DateTime? parseFlexibleDate(String input) {
  final text = input.trim();
  final compact = RegExp(r'^(\d{4})(\d{2})(\d{2})$').firstMatch(text);
  final separated = RegExp(
    r'^(\d{4})\s*[-/.年\s]\s*(\d{1,2})\s*[-/.月\s]\s*(\d{1,2})\s*日?$',
  ).firstMatch(text);
  final match = compact ?? separated;
  if (match == null) return null;
  final year = int.parse(match[1]!);
  final month = int.parse(match[2]!);
  final day = int.parse(match[3]!);
  if (year < 1970 || year > 2100) return null;
  final date = DateTime.utc(year, month, day);
  return date.year == year && date.month == month && date.day == day
      ? date
      : null;
}

int? parseFlexibleTime(String input) {
  final text = input.trim();
  int hour, minute;
  if (RegExp(r'^\d{1,2}$').hasMatch(text)) {
    hour = int.parse(text);
    minute = 0;
  } else if (RegExp(r'^\d{3,4}$').hasMatch(text)) {
    hour = int.parse(text.substring(0, text.length - 2));
    minute = int.parse(text.substring(text.length - 2));
  } else {
    final match = RegExp(
      r'^(\d{1,2})\s*[:：时時\s]\s*(\d{1,2})\s*分?$',
    ).firstMatch(text);
    if (match == null) return null;
    hour = int.parse(match[1]!);
    minute = int.parse(match[2]!);
  }
  return hour < 24 && minute < 60 ? hour * 60 + minute : null;
}

String formatMinute(int minute) =>
    '${(minute ~/ 60).toString().padLeft(2, '0')}:${(minute % 60).toString().padLeft(2, '0')}';
