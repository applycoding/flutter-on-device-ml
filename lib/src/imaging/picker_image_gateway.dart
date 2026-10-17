import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_on_device_ml/src/imaging/image_gateway.dart';
import 'package:flutter_on_device_ml/src/imaging/pixel_codec.dart';

/// Camera and gallery through `image_picker`, decoded to RGBA on device.
class PickerImageGateway implements ImageGateway {
  PickerImageGateway({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<PickedPhoto?> pick(ImageOrigin origin) async {
    final file = await _picker.pickImage(source: _source(origin));
    if (file == null) return null;
    return _decode(file);
  }

  @override
  Future<PickedPhoto?> recoverLost() async {
    final lost = await _picker.retrieveLostData();
    if (lost.isEmpty) return null;
    final exception = lost.exception;
    if (exception != null) {
      throw FormatException(
        exception.message ?? 'The camera returned an error.',
      );
    }
    final file = lost.file;
    if (file == null) return null;
    return _decode(file);
  }

  Future<PickedPhoto> _decode(XFile file) async {
    final bytes = await file.readAsBytes();
    final image = decodeToPixelImage(bytes);
    if (image == null) {
      throw const FormatException('That file is not a readable image.');
    }
    return PickedPhoto(image: image, path: file.path);
  }
}

ImageSource _source(ImageOrigin origin) {
  switch (origin) {
    case ImageOrigin.camera:
      return ImageSource.camera;
    case ImageOrigin.gallery:
      return ImageSource.gallery;
  }
}

/// Writes a PNG under the application support `scans` directory.
class FileImageStore implements ImageStore {
  @override
  Future<String?> persist(PickedPhoto photo, String id) async {
    final support = await getApplicationSupportDirectory();
    final folder = Directory('${support.path}/scans');
    await folder.create(recursive: true);
    final file = File('${folder.path}/$id.png');
    await file.writeAsBytes(encodePngBytes(photo.image), flush: true);
    return file.path;
  }
}
