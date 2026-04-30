class DateFormatter {
  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  /// Formats a [DateTime] into a human-readable string.
  /// - Today     → "Today"
  /// - Yesterday → "Yesterday"
  /// - Otherwise → "Month Day"  (e.g. "April 29")
  static String format(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) return 'Today';
    if (target == yesterday) return 'Yesterday';

    return '${_monthNames[date.month - 1]} ${date.day}';
  }
}
