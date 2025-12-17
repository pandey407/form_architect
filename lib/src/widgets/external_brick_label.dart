import 'package:flutter/material.dart';
import 'package:form_architect/src/models/form_brick.dart';

/// A widget that displays a field label, optional hint text, and a required asterisk indicator, using a [FormBrick].
///
/// [BrickLabel] renders the label, optional required asterisk, and hint from a [FormBrick] instance.
/// The label is styled with [bodyLarge], the asterisk with theme error color, and hint with [bodySmall] and [hintColor].
///
/// Example usage:
/// ```dart
/// BrickLabel(
///   brick: myFormBrick,
/// )
/// ```
class BrickLabel extends StatelessWidget {
  /// The [FormBrick] instance providing label, hint, and required information.
  final FormBrick brick;

  /// Creates a [BrickLabel] widget from a [FormBrick] instance.
  const BrickLabel({super.key, required this.brick});

  @override
  Widget build(BuildContext context) {
    final String? label = brick.label;
    final String? hint = brick.hint;

    if ((label == null || label.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        if (hint != null && hint.isNotEmpty)
          Padding(padding: const EdgeInsets.only(top: 2.0), child: Text(hint)),
      ],
    );
  }
}
