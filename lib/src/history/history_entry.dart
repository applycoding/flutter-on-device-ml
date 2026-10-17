import 'dart:convert';

import 'package:flutter_on_device_ml/src/detection/detection_box.dart';
import 'package:flutter_on_device_ml/src/ocr/text_read.dart';

enum ScanKind { objectDetection, textRecognition }

/// One saved scan. Image pixels live in a file; this record holds the result.
class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.createdAt,
    required this.kind,
    required this.summary,
    required this.imageWidth,
    required this.imageHeight,
    required this.detections,
    required this.recognizedText,
    required this.textRegions,
    this.imagePath,
  });

  final String id;
  final DateTime createdAt;
  final ScanKind kind;
  final String summary;
  final int imageWidth;
  final int imageHeight;
  final String? imagePath;
  final List<DetectionBox> detections;
  final String recognizedText;
  final List<TextRegion> textRegions;

  Map<String, Object?> detailsMap() {
    return {
      'detections': [for (final box in detections) box.toJson()],
      'text': recognizedText,
      'regions': [for (final region in textRegions) region.toJson()],
    };
  }

  String get detailsJson => jsonEncode(detailsMap());

  factory HistoryEntry.fromStorage({
    required String id,
    required DateTime createdAt,
    required String kindName,
    required String summary,
    required int imageWidth,
    required int imageHeight,
    required String? imagePath,
    required String detailsJson,
  }) {
    final decoded = jsonDecode(detailsJson);
    if (decoded is! Map) {
      throw const FormatException('History details must be an object.');
    }
    final details = decoded.cast<String, dynamic>();
    final detections = <DetectionBox>[];
    final rawBoxes = details['detections'];
    if (rawBoxes is List) {
      for (final item in rawBoxes) {
        if (item is Map) {
          detections.add(DetectionBox.fromJson(item.cast<String, dynamic>()));
        }
      }
    }
    final regions = <TextRegion>[];
    final rawRegions = details['regions'];
    if (rawRegions is List) {
      for (final item in rawRegions) {
        if (item is Map) {
          regions.add(TextRegion.fromJson(item.cast<String, dynamic>()));
        }
      }
    }
    return HistoryEntry(
      id: id,
      createdAt: createdAt,
      kind: scanKindFromName(kindName),
      summary: summary,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      imagePath: imagePath,
      detections: detections,
      recognizedText: details['text'] as String? ?? '',
      textRegions: regions,
    );
  }
}

ScanKind scanKindFromName(String name) {
  for (final kind in ScanKind.values) {
    if (kind.name == name) return kind;
  }
  throw FormatException('Unknown scan kind: $name');
}

String scanKindLabel(ScanKind kind) {
  switch (kind) {
    case ScanKind.objectDetection:
      return 'Objects';
    case ScanKind.textRecognition:
      return 'Text';
  }
}

String summarizeDetections(List<DetectionBox> boxes) {
  if (boxes.isEmpty) return 'No objects above the score threshold';
  if (boxes.length == 1) return boxes.first.label;
  if (boxes.length == 2) return '${boxes[0].label}, ${boxes[1].label}';
  return '${boxes[0].label}, ${boxes[1].label} +${boxes.length - 2}';
}

String summarizeText(String text) {
  final lines = text.split(RegExp(r'\s*\n\s*'));
  String first = '';
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.isNotEmpty) {
      first = trimmed;
      break;
    }
  }
  if (first.isEmpty) return 'No text recognized';
  if (first.length <= 80) return first;
  return '${first.substring(0, 77)}...';
}

String formatTimestamp(DateTime time) {
  final local = time.toLocal();
  String two(int value) => value.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
}

abstract class HistoryRepository {
  Future<List<HistoryEntry>> loadAll();

  Future<void> save(HistoryEntry entry);

  Future<void> delete(String id);
}

class MemoryHistoryRepository implements HistoryRepository {
  final List<HistoryEntry> _entries = [];

  @override
  Future<List<HistoryEntry>> loadAll() async {
    return _entries.reversed.toList(growable: false);
  }

  @override
  Future<void> save(HistoryEntry entry) async {
    _entries.removeWhere((item) => item.id == entry.id);
    _entries.add(entry);
  }

  @override
  Future<void> delete(String id) async {
    _entries.removeWhere((item) => item.id == id);
  }
}
