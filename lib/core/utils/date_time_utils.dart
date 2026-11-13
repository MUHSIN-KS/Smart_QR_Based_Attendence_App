import 'package:intl/intl.dart';

class DateTimeUtils {
  static String formatFullDate(DateTime dateTime) {
    return DateFormat('EEEE, MMMM d, y').format(dateTime);
  }

  static String formatShortDate(DateTime dateTime) {
    return DateFormat('MMM d, y').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  static String formatIsoTimeString(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '--:--';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return isoString;
    }
  }

  static String formatIsoDateString(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '---';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('MMM d, y').format(dt);
    } catch (_) {
      return isoString;
    }
  }

  static String calculateDuration(String? checkInIso, String? checkOutIso) {
    if (checkInIso == null || checkOutIso == null) return '--';
    try {
      final inTime = DateTime.parse(checkInIso);
      final outTime = DateTime.parse(checkOutIso);
      final diff = outTime.difference(inTime);
      final hours = diff.inHours;
      final minutes = diff.inMinutes.remainder(60);
      return '${hours}h ${minutes}m';
    } catch (_) {
      return '--';
    }
  }
}

