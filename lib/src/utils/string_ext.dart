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

  /// Returns true if the string is null, empty, or contains only whitespace characters.
  bool get isWhiteSpace => trim().isEmpty;

  /// Returns the extension of the file name, or null if there is none.
  /// Example: 'photo.jpg'.extension => 'jpg', 'archive.tar.gz'.extension => 'gz'
  String? get extension {
    final segments = split('.');
    if (segments.length < 2) return null;
    final ext = segments.last.trim();
    return ext.isEmpty ? null : ext.toLowerCase();
  }
}

extension NullableStringExt on String? {
  /// Returns true if the string is null, empty, or contains only whitespace characters.
  bool get isWhiteSpace => this == null || this!.isWhiteSpace;
}
