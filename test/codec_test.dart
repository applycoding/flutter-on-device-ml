import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_on_device_ml/src/imaging/pixel_codec.dart';
import 'package:flutter_on_device_ml/src/imaging/pixel_image.dart';

void main() {
  test('png encode and decode keeps RGBA pixels', () {
    final source = PixelImage.filled(2, 2, r: 10, g: 20, b: 30, a: 255);
    source.setPixel(1, 0, 1, 2, 3, 255);
    final decoded = decodeToPixelImage(encodePngBytes(source));

    expect(decoded, isNotNull);
    expect(decoded!.width, 2);
    expect(decoded.height, 2);
    expect(decoded.red(0, 1), 10);
    expect(decoded.green(0, 1), 20);
    expect(decoded.blue(1, 0), 3);
    expect(decoded.red(1, 0), 1);
  });
}
