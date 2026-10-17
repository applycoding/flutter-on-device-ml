import 'package:flutter_on_device_ml/src/imaging/pixel_image.dart';

/// Where a photo came from.
enum ImageOrigin { camera, gallery }

/// A decoded photo plus the file the picker handed back, when it has one.
class PickedPhoto {
  const PickedPhoto({required this.image, this.path});

  final PixelImage image;
  final String? path;
}

/// Camera and gallery access. Widget tests use a fake.
abstract class ImageGateway {
  Future<PickedPhoto?> pick(ImageOrigin origin);

  /// Android can destroy the activity while the camera app is open.
  /// The next launch should return that photo instead of dropping it.
  Future<PickedPhoto?> recoverLost();
}

/// Copies a picked photo into app storage so history survives cache cleanup.
abstract class ImageStore {
  Future<String?> persist(PickedPhoto photo, String id);
}

/// Used by tests and by any caller that should not touch the filesystem.
class MemoryImageStore implements ImageStore {
  @override
  Future<String?> persist(PickedPhoto photo, String id) async => null;
}
