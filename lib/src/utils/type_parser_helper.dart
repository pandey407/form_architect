import 'package:form_architect/src/utils/string_ext.dart';

/// Helper class for parsing and type conversion utilities, especially used for
/// parsing JSON or dynamic values into specific Dart types for form elements.
class TypeParserHelper {
  TypeParserHelper._();

  /// Attempts to parse a dynamic value as a num.
  /// Returns null if unable to parse.
  static num? parseNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }

  /// Attempts to parse a dynamic value as a DateTime.
  /// Returns null if unable to parse.
  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      if (value.isWhiteSpace) return null;
      // DateTime.tryParse handles many standard strings.
      return DateTime.tryParse(value);
    }
    return null;
  }

  /// Attempts to parse a value as a String.
  /// Returns null if value is null.
  static String? parseString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }
}
