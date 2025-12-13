import 'package:flutter/material.dart';

extension DateTimeExt on DateTime {
  /// Returns a TimeOfDay (hour and minute) extracted from this DateTime.
  /// Note: Requires importing 'package:flutter/material.dart' where used.
  TimeOfDay get timeOfDay => TimeOfDay(hour: hour, minute: minute);
}
