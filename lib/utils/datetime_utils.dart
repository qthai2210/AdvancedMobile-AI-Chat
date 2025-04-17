/// Utility functions for working with dates and times

/// Converts an ISO 8601 timestamp string to a DateTime object.
///
/// Handles ISO 8601 strings like "2025-04-11T16:07:34.996693" and returns
/// a proper DateTime object. The function is null-safe and will return
/// the current time if the input is null or invalid.
///
/// Example:
/// ```dart
/// final dateTime = parseIsoDateTime("2025-04-11T16:07:34.996693");
/// print(dateTime.year); // 2025
/// ```
///
/// @param isoString The ISO 8601 timestamp string to parse
/// @return The parsed DateTime, or DateTime.now() if the input is invalid
DateTime parseIsoDateTime(String? isoString) {
  if (isoString == null || isoString.isEmpty) {
    return DateTime.now();
  }

  try {
    return DateTime.parse(isoString);
  } catch (e) {
    // If there's an error parsing, return current time
    return DateTime.now();
  }
}

/// Converts an ISO 8601 timestamp string to Unix milliseconds since epoch.
///
/// This is useful when you need a numerical representation of a timestamp
/// from an ISO 8601 string.
///
/// Example:
/// ```dart
/// final timestamp = isoToMilliseconds("2025-04-11T16:07:34.996693");
/// print(timestamp); // e.g., 1744629654996
/// ```
///
/// @param isoString The ISO 8601 timestamp string to convert
/// @return The timestamp in milliseconds since epoch, or current time in milliseconds if invalid
int isoToMilliseconds(String? isoString) {
  return parseIsoDateTime(isoString).millisecondsSinceEpoch;
}

/// Formats a given timestamp (milliseconds since epoch) to a readable date string.
///
/// @param milliseconds Milliseconds since epoch
/// @param format Optional format specification (not implemented yet, would require intl package)
/// @return A formatted date string
String formatDateTime(int milliseconds, {String format = 'yyyy-MM-dd HH:mm'}) {
  final dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
  // For more advanced formatting, consider adding the 'intl' package
  // For now, return a simple format
  return '${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)} '
      '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
}

/// Helper function to ensure two digits in date/time components
String _twoDigits(int n) {
  if (n >= 10) return '$n';
  return '0$n';
}
