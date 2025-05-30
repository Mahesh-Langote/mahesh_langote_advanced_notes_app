import 'package:intl/intl.dart';
import '../constants/constants.dart';

/// Utility class for date and time formatting
/// Provides consistent date formatting throughout the application
class DateUtils {
  DateUtils._(); // Private constructor to prevent instantiation

  // Date formatters
  static final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
  static final DateFormat _timeFormatter = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormatter =
      DateFormat('MMM dd, yyyy at HH:mm');
  static final DateFormat _shortDateFormatter = DateFormat('MMM dd');
  static final DateFormat _yearFormatter = DateFormat('yyyy');

  /// Format date to display format (e.g., "Jan 15, 2024")
  static String formatDate(DateTime date) {
    return _dateFormatter.format(date);
  }

  /// Format time to display format (e.g., "14:30")
  static String formatTime(DateTime date) {
    return _timeFormatter.format(date);
  }

  /// Format date and time to display format (e.g., "Jan 15, 2024 at 14:30")
  static String formatDateTime(DateTime date) {
    return _dateTimeFormatter.format(date);
  }

  /// Format date with relative time (e.g., "Today at 14:30", "Yesterday at 10:15")
  static String formatRelativeDateTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final inputDate = DateTime(date.year, date.month, date.day);

    if (inputDate == today) {
      return '${AppStrings.todayAt} ${formatTime(date)}';
    } else if (inputDate == yesterday) {
      return '${AppStrings.yesterdayAt} ${formatTime(date)}';
    } else {
      return formatDateTime(date);
    }
  }

  /// Format date for note display (short format)
  static String formatNoteDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final inputDate = DateTime(date.year, date.month, date.day);

    if (inputDate == today) {
      return formatTime(date);
    } else if (inputDate == yesterday) {
      return 'Yesterday';
    } else if (date.year == now.year) {
      return _shortDateFormatter.format(date);
    } else {
      return formatDate(date);
    }
  }

  /// Get time ago string (e.g., "2 hours ago", "3 days ago")
  static String getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    }
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final inputDate = DateTime(date.year, date.month, date.day);
    return inputDate == today;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final inputDate = DateTime(date.year, date.month, date.day);
    return inputDate == yesterday;
  }

  /// Check if date is this week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return date.isAfter(weekAgo);
  }

  /// Check if date is this month
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Check if date is this year
  static bool isThisYear(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year;
  }

  /// Parse date from string (handles various formats)
  static DateTime? parseDate(String dateString) {
    try {
      // Try different date formats
      final formats = [
        'yyyy-MM-dd HH:mm:ss',
        'yyyy-MM-dd',
        'MMM dd, yyyy',
        'dd/MM/yyyy',
        'MM/dd/yyyy',
      ];

      for (final format in formats) {
        try {
          final formatter = DateFormat(format);
          return formatter.parse(dateString);
        } catch (e) {
          // Continue to next format
        }
      }

      // If all formats fail, try DateTime.parse
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Get start of week (Monday)
  static DateTime startOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return startOfDay(date.subtract(Duration(days: daysFromMonday)));
  }

  /// Get end of week (Sunday)
  static DateTime endOfWeek(DateTime date) {
    final daysUntilSunday = 7 - date.weekday;
    return endOfDay(date.add(Duration(days: daysUntilSunday)));
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }
}
