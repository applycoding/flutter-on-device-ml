/// Splits a label file. A trailing newline does not add a class.
///
/// Internal lines are kept, including the `???` placeholders in the SSD
/// MobileNet label map, because the line index is the class id.
List<String> parseLabelFile(String raw) {
  final normalized = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final lines = normalized.split('\n');
  if (lines.isNotEmpty && lines.last.isEmpty) {
    return lines.sublist(0, lines.length - 1);
  }
  return lines;
}

/// Maps a model class id onto [labels].
///
/// [classIndexBase] is the model id of the first line. The bundled SSD label
/// map already has a placeholder at index 0, so the base is 0. Empty labels
/// and `???` become `class <id>` so a placeholder is not shown as a name.
String labelFor(List<String> labels, int classId, int classIndexBase) {
  final index = classId - classIndexBase;
  if (index < 0 || index >= labels.length) return 'class $classId';
  final raw = labels[index].trim();
  if (raw.isEmpty || raw == '???') return 'class $classId';
  return raw;
}
