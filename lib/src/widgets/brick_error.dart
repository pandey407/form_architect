import 'package:flutter/material.dart';

/// A widget that displays its [child], and, if present, the error text from the given [FormFieldState].
///
/// If there is no error, only the [child] is shown.
/// You can use this widget below form inputs to automatically show validation errors.
class BrickError extends StatelessWidget {
  final FormFieldState<dynamic> field;
  final TextStyle? style;
  final Widget child;

  const BrickError({
    super.key,
    required this.field,
    this.style,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final error = field.errorText;
    final errorColor =
        style?.color ??
        Theme.of(context).inputDecorationTheme.errorStyle?.color ??
        Theme.of(context).colorScheme.error;
    final errorStyle =
        style ??
        Theme.of(context).inputDecorationTheme.errorStyle ??
        TextStyle(color: errorColor);

    // Get content padding from InputDecorationTheme to match TextFormField error spacing
    final contentPadding =
        Theme.of(
          context,
        ).inputDecorationTheme.contentPadding?.resolve(TextDirection.ltr) ??
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0);
    final leftPadding = contentPadding.left;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        child,
        if (error != null && error.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 4.0, left: leftPadding),
            child: DefaultTextStyle(style: errorStyle, child: Text(error)),
          ),
      ],
    );
  }
}
