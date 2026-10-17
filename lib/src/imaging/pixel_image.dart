import 'dart:typed_data';

/// Tightly packed RGBA image. Four bytes per pixel, row-major.
class PixelImage {
  PixelImage({required this.width, required this.height, required this.rgba}) {
    if (width <= 0 || height <= 0) {
      throw ArgumentError('Image dimensions must be positive.');
    }
    final expected = width * height * 4;
    if (rgba.length != expected) {
      throw ArgumentError(
        'RGBA length ${rgba.length} does not match ${width}x$height.',
      );
    }
  }

  factory PixelImage.filled(
    int width,
    int height, {
    int r = 0,
    int g = 0,
    int b = 0,
    int a = 255,
  }) {
    final bytes = Uint8List(width * height * 4);
    for (var i = 0; i < width * height; i++) {
      final offset = i * 4;
      bytes[offset] = r;
      bytes[offset + 1] = g;
      bytes[offset + 2] = b;
      bytes[offset + 3] = a;
    }
    return PixelImage(width: width, height: height, rgba: bytes);
  }

  final int width;
  final int height;
  final Uint8List rgba;

  int red(int x, int y) => rgba[_offset(x, y)];
  int green(int x, int y) => rgba[_offset(x, y) + 1];
  int blue(int x, int y) => rgba[_offset(x, y) + 2];
  int alpha(int x, int y) => rgba[_offset(x, y) + 3];

  void setPixel(int x, int y, int r, int g, int b, [int a = 255]) {
    final offset = _offset(x, y);
    rgba[offset] = r;
    rgba[offset + 1] = g;
    rgba[offset + 2] = b;
    rgba[offset + 3] = a;
  }

  int _offset(int x, int y) {
    if (x < 0 || y < 0 || x >= width || y >= height) {
      throw RangeError('Pixel ($x, $y) is outside ${width}x$height.');
    }
    return (y * width + x) * 4;
  }
}
