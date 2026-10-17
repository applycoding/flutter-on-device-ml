/// One line of recognized text, in source-image pixels.
class TextRegion {
  const TextRegion({
    required this.text,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final String text;
  final double left;
  final double top;
  final double right;
  final double bottom;

  Map<String, Object> toJson() {
    return {
      'text': text,
      'left': left,
      'top': top,
      'right': right,
      'bottom': bottom,
    };
  }

  factory TextRegion.fromJson(Map<String, dynamic> json) {
    return TextRegion(
      text: json['text'] as String? ?? '',
      left: _double(json['left']),
      top: _double(json['top']),
      right: _double(json['right']),
      bottom: _double(json['bottom']),
    );
  }
}

class TextRead {
  const TextRead({required this.text, required this.regions});

  final String text;
  final List<TextRegion> regions;
}

double _double(Object? value) {
  if (value is num) return value.toDouble();
  throw const FormatException('A text box coordinate must be a number.');
}
