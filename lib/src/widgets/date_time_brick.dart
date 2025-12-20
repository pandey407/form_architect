import 'package:collection/collection.dart';
import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_architect/form_architect.dart';
import 'package:form_architect/src/models/form_validation_rule.dart';
import 'package:form_architect/src/utils/date_time_ext.dart';
import 'package:form_architect/src/utils/type_parser_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeBrick extends StatefulWidget {
  const DateTimeBrick({super.key, required this.brick});
  final FormBrick brick;

  @override
  State<DateTimeBrick> createState() => _DateTimeBrickState();
}

class _DateTimeBrickState extends State<DateTimeBrick> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey _pickerKey = GlobalKey();
  DateTime? selectedDateTime;

  DateTime? get initialDateTime {
    final val = widget.brick.value;
    return TypeParserHelper.parseDateTime(val);
  }

  /// Returns the minimum [DateTime] that can be selected by this brick.
  ///
  /// If a `MIN` validation rule exists, its value is parsed as a [DateTime] and used.
  /// Otherwise, defaults to one year before the [initialDateTime] or [DateTime.now].
  DateTime get minDateTime {
    final usableInitialDateTime = initialDateTime ?? DateTime.now();
    final defaultMinDateTime = usableInitialDateTime.subtract(
      const Duration(days: 365),
    );
    final minDateRule = widget.brick.validation?.firstWhereOrNull(
      (rule) => rule.type == FormValidationRuleType.min,
    );

    final minDate = minDateRule != null
        ? TypeParserHelper.parseDateTime(minDateRule.value)
        : null;

    return minDate ?? defaultMinDateTime;
  }

  /// Returns the maximum [DateTime] that can be selected by this brick.
  ///
  /// If a `MAX` validation rule exists, its value is parsed as a [DateTime] and used.
  /// Otherwise, defaults to one year after the [initialDateTime].
  DateTime get maxDateTime {
    final usableInitialDateTime = initialDateTime ?? DateTime.now();
    final defaultMaxDateTime = usableInitialDateTime.add(
      const Duration(days: 365),
    );
    final maxDateRule = widget.brick.validation?.firstWhereOrNull(
      (rule) => rule.type == FormValidationRuleType.max,
    );

    final maxDate = maxDateRule != null
        ? TypeParserHelper.parseDateTime(maxDateRule.value)
        : null;

    return maxDate ?? defaultMaxDateTime;
  }

  /// Returns the pattern format string from validation rules if exists.
  ///
  /// This pattern is used to format the DateTime value when transforming it for form submission.
  /// For example: "yyyy-MM-ddTHH:mm:ss" or "yyyy-MM-dd"
  String get outputPattern {
    final patternRule = widget.brick.validation?.firstWhereOrNull(
      (rule) => rule.type == FormValidationRuleType.pattern,
    );

    if (patternRule?.value != null) {
      return patternRule!.value as String;
    }

    // Default patterns based on brick type
    switch (widget.brick.type) {
      case FormBrickType.date:
        return 'yyyy-MM-dd';
      case FormBrickType.time:
        return 'HH:mm:ss';
      case FormBrickType.dateTime:
        return 'yyyy-MM-ddTHH:mm:ss';
      default:
        return 'yyyy-MM-ddTHH:mm:ss';
    }
  }

  @override
  void initState() {
    super.initState();
    selectedDateTime = initialDateTime;
    _updateControllerText(selectedDateTime);
  }

  void _updateControllerText(DateTime? dateTime) {
    if (dateTime != null) {
      _controller.text = dateTime.defaultFormattedDateTime(
        type: widget.brick.type,
      );
    } else {
      _controller.text = "";
    }
  }

  Future<void> _pickDateTime() async {
    final renderBox =
        _pickerKey.currentContext?.findRenderObject() as RenderBox?;

    if (widget.brick.type == FormBrickType.date ||
        widget.brick.type == FormBrickType.dateTime) {
      await showCupertinoCalendarPicker(
        context,
        widgetRenderBox: renderBox,
        minimumDateTime: minDateTime,
        initialDateTime: selectedDateTime ?? initialDateTime,
        maximumDateTime: maxDateTime,
        mode: widget.brick.type == FormBrickType.date
            ? CupertinoCalendarMode.date
            : CupertinoCalendarMode.dateTime,
        timeLabel: 'Time',
        use24hFormat: false,
        onDateTimeChanged: (dateTime) {
          setState(() {
            selectedDateTime = dateTime;
          });
          _updateControllerText(dateTime);
        },
      );
    } else if (widget.brick.type == FormBrickType.time) {
      await showCupertinoTimePicker(
        context,
        initialTime: selectedDateTime?.timeOfDay,
        use24hFormat: false,
        widgetRenderBox: renderBox,
        onTimeChanged: (time) {
          final now = DateTime.now();
          final dateTime = DateTime(
            now.year,
            now.month,
            now.day,
            time.hour,
            time.minute,
          );
          setState(() {
            selectedDateTime = dateTime;
          });
          _updateControllerText(dateTime);
        },
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      key: _pickerKey,
      name: widget.brick.key,
      controller: _controller,
      enabled: widget.brick.isEnabled,
      decoration: InputDecoration(
        labelText: widget.brick.label,
        hintText: widget.brick.hint,
      ),
      onTap: _pickDateTime,
      readOnly: true,
      validator: (value) => widget.brick.validate(value: selectedDateTime),
      valueTransformer: (value) {
        if (selectedDateTime == null) return null;
        try {
          return DateFormat(outputPattern).format(selectedDateTime!.toUtc());
        } catch (e) {
          // If pattern is invalid, return null
          return null;
        }
      },
    );
  }
}
