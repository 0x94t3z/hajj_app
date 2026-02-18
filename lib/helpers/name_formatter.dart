String toTitleCaseName(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) return normalized;
  return normalized.toLowerCase().split(RegExp(r'\s+')).map((word) {
    if (word.isEmpty) return word;
    return '${word[0].toUpperCase()}${word.substring(1)}';
  }).join(' ');
}
