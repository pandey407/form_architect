import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import 'package:form_architect/form_architect.dart';
import 'package:flutter/cupertino.dart';
import 'package:form_architect/src/utils/date_time_ext.dart';
import 'package:intl/intl.dart';

class DateTimeBrick extends StatefulWidget {
  const DateTimeBrick({super.key, required this.brick});
  final FormBrick brick;

  @override
  State<DateTimeBrick> createState() => _DateTimeBrickState();
}

class _DateTimeBrickState extends State<DateTimeBrick> {
  DateTime? selectedDateTime;

  /// Utility to parse a DateTime or String date; returns null if parsing fails.
  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  DateTime get initialDateTime {
    final val = widget.brick.value;
    return _parseDateTime(val) ?? DateTime.now();
  }

  DateTime get minDateTime {
    final defaultMinDateTime = initialDateTime.subtract(Duration(days: 365));
    final range = widget.brick.range;
    if (range != null && range.length == 2) {
      return _parseDateTime(range[0]) ?? defaultMinDateTime;
    }
    return defaultMinDateTime;
  }

  DateTime get maxDateTime {
    final defaultMaxDateTime = initialDateTime.subtract(Duration(days: 365));
    final range = widget.brick.range;
    if (range != null && range.length == 2) {
      return _parseDateTime(range[1]) ?? defaultMaxDateTime;
    }
    return defaultMaxDateTime;
  }

  String get displayValue {
    final dt = selectedDateTime ?? initialDateTime;
    switch (widget.brick.type) {
      case FormBrickType.date:
        return DateFormat.yMMMMd().format(dt);
      case FormBrickType.time:
        return DateFormat.jm().format(dt);
      case FormBrickType.dateTime:
        return DateFormat.yMMMMd().add_jm().format(dt);
      default:
        return dt.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wrapped with FormField for form integration
    return FormField<DateTime>(
      initialValue: initialDateTime,
      builder: (field) {
        DateTime? value = selectedDateTime ?? field.value ?? initialDateTime;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.brick.label != null) Text(widget.brick.label!),
            if (widget.brick.type == FormBrickType.date ||
                widget.brick.type == FormBrickType.dateTime)
              CupertinoCalendarPickerButton(
                minimumDateTime: minDateTime,
                initialDateTime: value,
                use24hFormat: false,
                maximumDateTime: maxDateTime,
                mode: widget.brick.type == FormBrickType.date
                    ? CupertinoCalendarMode.date
                    : CupertinoCalendarMode.dateTime,
                actions: [
                  CancelCupertinoCalendarAction(),
                  ConfirmCupertinoCalendarAction(),
                ],
                timeLabel: "Time",
                onCompleted: (DateTime? dt) {
                  setState(() {
                    selectedDateTime = dt;
                  });
                  field.didChange(dt);
                },
              ),
            if (widget.brick.type == FormBrickType.time)
              CupertinoTimePickerButton(
                use24hFormat: false,
                initialTime: value.timeOfDay,
                onTimeChanged: (timeOfDay) {
                  final now = value;
                  final newDateTime = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    timeOfDay.hour,
                    timeOfDay.minute,
                  );
                  setState(() {
                    selectedDateTime = newDateTime;
                  });
                  field.didChange(newDateTime);
                },
              ),
          ],
        );
      },
    );
  }
}
