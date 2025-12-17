import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';

extension CustomDropdownThemeExtension on ThemeData {
  /// Converts the current theme's [inputDecorationTheme] and [colorScheme]
  /// to a [CustomDropdownDecoration].
  ///
  /// Usage:
  ///   Theme.of(context).customDropdownDecoration()
  CustomDropdownDecoration get customDropdownDecoration {
    final inputTheme = inputDecorationTheme;
    final inputBorder = inputTheme.border is OutlineInputBorder
        ? inputTheme.border as OutlineInputBorder
        : null;

    final enabledBorder = inputTheme.enabledBorder is OutlineInputBorder
        ? inputTheme.enabledBorder as OutlineInputBorder
        : null;

    final focusedBorder = inputTheme.focusedBorder is OutlineInputBorder
        ? inputTheme.focusedBorder as OutlineInputBorder
        : null;

    final errorBorder = inputTheme.errorBorder is OutlineInputBorder
        ? inputTheme.errorBorder as OutlineInputBorder
        : null;

    return CustomDropdownDecoration(
      closedFillColor: inputTheme.fillColor ?? Colors.white,
      expandedFillColor: inputTheme.fillColor ?? Colors.white,

      // Suffix icons
      closedSuffixIcon: Icon(
        Icons.keyboard_arrow_down,
        color: inputTheme.iconColor,
      ),
      expandedSuffixIcon: Icon(
        Icons.keyboard_arrow_up,
        color: inputTheme.iconColor,
      ),

      // Closed state borders
      closedBorder: enabledBorder?.borderSide != null
          ? Border.all(
              color: enabledBorder!.borderSide.color,
              width: enabledBorder.borderSide.width,
            )
          : inputBorder?.borderSide != null
          ? Border.all(
              color: inputBorder!.borderSide.color,
              width: inputBorder.borderSide.width,
            )
          : null,

      closedBorderRadius:
          enabledBorder?.borderRadius ??
          inputBorder?.borderRadius ??
          BorderRadius.circular(8),

      // Error state borders
      closedErrorBorder: errorBorder?.borderSide != null
          ? Border.all(
              color: errorBorder!.borderSide.color,
              width: errorBorder.borderSide.width,
            )
          : null,

      closedErrorBorderRadius:
          errorBorder?.borderRadius ?? BorderRadius.circular(8),

      // Expanded state borders
      expandedBorder: focusedBorder?.borderSide != null
          ? Border.all(
              color: focusedBorder!.borderSide.color,
              width: focusedBorder.borderSide.width,
            )
          : null,

      expandedBorderRadius:
          focusedBorder?.borderRadius ?? BorderRadius.circular(8),

      // Text styles from input theme
      hintStyle: inputTheme.hintStyle,
      headerStyle: inputTheme.labelStyle,
      errorStyle: inputTheme.errorStyle,
      listItemStyle: inputTheme.labelStyle,
      noResultFoundStyle: inputTheme.hintStyle,

      // Search field decoration
      searchFieldDecoration: SearchFieldDecoration(
        fillColor: inputTheme.fillColor,
        border: enabledBorder,
        focusedBorder: focusedBorder,
        hintStyle: inputTheme.hintStyle,
        textStyle: inputTheme.labelStyle,
      ),

      // List item decoration, either parameter or themed fallback
      listItemDecoration: colorScheme.listItemDecoration,
    );
  }
}

/// Extension on ColorScheme to create a ListItemDecoration.
/// If called on null, falls back to sensible Material defaults.
extension ListItemDecorationColorSchemeExtension on ColorScheme? {
  ListItemDecoration get listItemDecoration {
    final Color? selectedColor = this?.surfaceContainerHighest;
    final Color? highlightColor = this?.surfaceContainerHigh;
    final Color? splashColor = this?.surfaceContainerLow;

    return ListItemDecoration(
      selectedColor: selectedColor,
      highlightColor: highlightColor,
      splashColor: splashColor,
    );
  }
}

class EmptyInputDecorator extends StatelessWidget {
  const EmptyInputDecorator({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
          border: const OutlineInputBorder(borderSide: BorderSide.none),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none),
          errorBorder: const OutlineInputBorder(borderSide: BorderSide.none),
          disabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
          filled: false,
          fillColor: Colors.transparent,
        ),
      ),
      child: child,
    );
  }
}
