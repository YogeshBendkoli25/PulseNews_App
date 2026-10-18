import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDisplayDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'Recent';
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      return DateFormat('MMM dd, yyyy • h:mm a').format(dateTime);
    } catch (_) {
      return isoString;
    }
  }

  static String timeAgo(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      final difference = DateTime.now().difference(dateTime);

      if (difference.inSeconds < 60) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        final minutes = difference.inMinutes;
        return '$minutes ${minutes == 1 ? "minute" : "minutes"} ago';
      } else if (difference.inHours < 24) {
        final hours = difference.inHours;
        return '$hours ${hours == 1 ? "hour" : "hours"} ago';
      } else if (difference.inDays < 7) {
        final days = difference.inDays;
        return '$days ${days == 1 ? "day" : "days"} ago';
      } else {
        return DateFormat('MMM dd, yyyy').format(dateTime);
      }
    } catch (_) {
      return '';
    }
  }
}
