import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_on_device_ml/src/detection/image_transform.dart';
import 'package:flutter_on_device_ml/src/imaging/pixel_image.dart';

void main() {
  test('letterbox of a 640x480 frame into 320x320 pads the short axis', () {
    final transform = computeTransform(
      srcWidth: 640,
      srcHeight: 480,
      dstWidth: 320,
      dstHeight: 320,
      letterbox: true,
    );

    expect(transform.contentWidth, 320);
    expect(transform.contentHeight, 240);
    expect(transform.padLeft, 0);
    expect(transform.padRight, 0);
    expect(transform.padTop, 40);
    expect(transform.padBottom, 40);
    expect(transform.letterbox, isTrue);
  });

  test('letterbox of a tall frame pads the left and right', () {
    final transform = computeTransform(
      srcWidth: 50,
      srcHeight: 100,
      dstWidth: 200,
      dstHeight: 200,
      letterbox: true,
    );

    expect(transform.contentWidth, 100);
    expect(transform.contentHeight, 200);
    expect(transform.padLeft, 50);
    expect(transform.padRight, 50);
    expect(transform.padTop, 0);
    expect(transform.padBottom, 0);
  });

  test('identity size has no padding', () {
    final source = PixelImage.filled(8, 8, r: 9, g: 8, b: 7, a: 255);
    source.setPixel(3, 4, 1, 2, 3, 4);
    final fitted = fitImage(
      source,
      dstWidth: 8,
      dstHeight: 8,
      letterbox: true,
    );

    expect(fitted.transform.padLeft, 0);
    expect(fitted.transform.padTop, 0);
    expect(fitted.image.red(3, 4), 1);
    expect(fitted.image.green(3, 4), 2);
    expect(fitted.image.blue(3, 4), 3);
    expect(fitted.image.alpha(3, 4), 4);
  });

  test('nearest-neighbor letterbox copies source pixels and pad color', () {
    final source = PixelImage.filled(2, 1, r: 0, g: 0, b: 255);
    source.setPixel(0, 0, 255, 0, 0);
    source.setPixel(1, 0, 0, 0, 255);
    final fitted = fitImage(
      source,
      dstWidth: 2,
      dstHeight: 2,
      letterbox: true,
      padR: 7,
      padG: 8,
      padB: 9,
    );

    expect(fitted.transform.contentHeight, 1);
    expect(fitted.transform.padTop, 0);
    expect(fitted.transform.padBottom, 1);
    expect(fitted.image.red(0, 0), 255);
    expect(fitted.image.blue(1, 0), 255);
    expect(fitted.image.red(0, 1), 7);
    expect(fitted.image.green(0, 1), 8);
    expect(fitted.image.blue(1, 1), 9);
  });

  test('2x upsample keeps the left half on the left source pixel', () {
    final source = PixelImage.filled(2, 1);
    source.setPixel(0, 0, 255, 0, 0);
    source.setPixel(1, 0, 0, 0, 255);
    final fitted = fitImage(
      source,
      dstWidth: 4,
      dstHeight: 2,
      letterbox: true,
    );

    expect(fitted.transform.padLeft, 0);
    expect(fitted.transform.padTop, 0);
    expect(fitted.image.red(0, 0), 255);
    expect(fitted.image.red(1, 1), 255);
    expect(fitted.image.blue(2, 0), 255);
    expect(fitted.image.blue(3, 1), 255);
  });

  test('stretch fills the destination without padding', () {
    final source = PixelImage.filled(2, 1, r: 4, g: 5, b: 6);
    final fitted = fitImage(
      source,
      dstWidth: 2,
      dstHeight: 2,
      letterbox: false,
      padR: 9,
    );

    expect(fitted.transform.padLeft, 0);
    expect(fitted.transform.padTop, 0);
    expect(fitted.transform.contentWidth, 2);
    expect(fitted.transform.contentHeight, 2);
    expect(fitted.image.red(0, 0), 4);
    expect(fitted.image.red(1, 1), 4);
    expect(fitted.image.green(0, 1), 5);
  });

  test('non-positive dimensions are rejected', () {
    expect(
      () => computeTransform(
        srcWidth: 0,
        srcHeight: 10,
        dstWidth: 10,
        dstHeight: 10,
        letterbox: true,
      ),
      throwsArgumentError,
    );
  });
}
