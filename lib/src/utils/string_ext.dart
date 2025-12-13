extension StringExt on String {
  /// Returns the number of words in the string.
  /// If [treatConsecutiveWhitespaceAsSingle] is true, it counts words by splitting on one or more spaces.
  int wordCount({bool treatConsecutiveWhitespaceAsSingle = true}) {
    if (isEmpty) return 0;

    final trimmedText = trim();
    if (trimmedText.isEmpty) return 0;

    final words = treatConsecutiveWhitespaceAsSingle
        ? trimmedText.split(RegExp(r'\s+'))
        : trimmedText.split(' ').where((word) => word.isNotEmpty).toList();

    return words.length;
  }
}
