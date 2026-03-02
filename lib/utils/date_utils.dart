import 'package:intl/intl.dart';

class AppDateUtils {
  // Format date as dd MMM yyyy
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  // Format date as MMM yyyy (Month Year)
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMM yyyy').format(date);
  }

  // Format date as yyyy-MM (for filtering)
  static String formatMonthKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  // Get current month in yyyy-MM format
  static String getCurrentMonthKey() {
    final now = DateTime.now();
    return formatMonthKey(now);
  }

  // Get first day of month
  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // Get last day of month
  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  // Check if two dates are in the same month
  static bool isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  // Get number of days in month
  static int getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  // Get list of months for the year
  static List<DateTime> getMonthsInYear(int year) {
    return List.generate(12, (index) => DateTime(year, index + 1, 1));
  }

  // Format time ago (e.g., "2 hours ago")
  static String getTimeAgo(DateTime dateTime) {
    final Duration diff = DateTime.now().difference(dateTime);

    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  // Parse month string (YYYY-MM) to DateTime
  static DateTime parseMonthString(String monthString) {
    final parts = monthString.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]));
  }
}