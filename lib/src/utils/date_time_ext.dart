import 'package:flutter/material.dart';
import 'package:form_architect/src/models/form_brick.dart';
import 'package:intl/intl.dart';

extension DateTimeExt on DateTime {
  /// Returns a TimeOfDay (hour and minute) extracted from this DateTime.
  /// Note: Requires importing 'package:flutter/material.dart' where used.
  TimeOfDay get timeOfDay => TimeOfDay(hour: hour, minute: minute);

  /// Returns a formatted date/time string for this [DateTime] instance,
  /// based on the given [FormBrickType].
  ///
  /// - If [type] is [FormBrickType.date], the output is a localized date (e.g. Jan 20, 2022).
  /// - If [type] is [FormBrickType.time], the output is a localized time (e.g. 2:34 PM).
  /// - If [type] is [FormBrickType.dateTime] or any other value, the output includes both
  ///   date and time (e.g. Jan 20, 2022, 2:34 PM).
  ///
  /// Uses the `intl` package's [DateFormat] for formatting.
  ///
  /// Example:
  /// ```dart
  /// DateTime dt = DateTime(2022, 1, 20, 14, 34);
  /// dt.defaultFormattedDateTime(type: FormBrickType.date);      // 'Jan 20, 2022'
  /// dt.defaultFormattedDateTime(type: FormBrickType.time);      // '2:34 PM'
  /// dt.defaultFormattedDateTime(type: FormBrickType.dateTime);  // 'Jan 20, 2022 2:34 PM'
  /// ```
  String defaultFormattedDateTime({required FormBrickType type}) {
    switch (type) {
      case FormBrickType.date:
        return DateFormat.yMMMd().format(this);
      case FormBrickType.time:
        return DateFormat.jm().format(this);
      case FormBrickType.dateTime:
      default:
        return DateFormat.yMMMd().add_jm().format(this);
    }
  }
}
