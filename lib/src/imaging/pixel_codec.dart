import 'dart:typed_data';

import 'package:image/image.dart' as im;

import 'package:flutter_on_device_ml/src/imaging/pixel_image.dart';

/// Decodes a PNG, JPEG, or other image the `image` package understands.
PixelImage? decodeToPixelImage(Uint8List bytes) {
  final decoded = im.decodeImage(bytes);
  if (decoded == null) return null;
  final rgba = decoded.getBytes(order: im.ChannelOrder.rgba);
  if (rgba.length != decoded.width * decoded.height * 4) {
    throw const FormatException('Decoded image has an unexpected channel layout.');
  }
  return PixelImage(width: decoded.width, height: decoded.height, rgba: rgba);
}

/// Encodes [image] as a PNG. The byte buffer is copied so views stay valid.
Uint8List encodePngBytes(PixelImage image) {
  final tight = Uint8List.fromList(image.rgba);
  final encoded = im.Image.fromBytes(
    width: image.width,
    height: image.height,
    bytes: tight.buffer,
    numChannels: 4,
    order: im.ChannelOrder.rgba,
  );
  return im.encodePng(encoded);
}
