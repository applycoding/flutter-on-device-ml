import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_on_device_ml/app.dart';
import 'package:flutter_on_device_ml/src/history/history_entry.dart';
import 'package:flutter_on_device_ml/src/imaging/pixel_codec.dart';
import 'package:flutter_on_device_ml/src/imaging/pixel_image.dart';
import 'package:flutter_on_device_ml/src/ui/detection_overlay.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<HistoryEntry> _entries = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final entries = await AppScope.of(context).history.loadAll();
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Future<void> _delete(String id) async {
    await AppScope.of(context).history.delete(id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: _loading
                ? const Center(child: Text('Loading history'))
                : _entries.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No scans yet. A detection or a text reading will be kept on this phone.',
                        key: Key('empty-history'),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _entries.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final entry = _entries[index];
                      return ListTile(
                        key: ValueKey('history-${entry.id}'),
                        title: Text(entry.summary),
                        subtitle: Text(
                          '${scanKindLabel(entry.kind)} · ${formatTimestamp(entry.createdAt)}',
                        ),
                        trailing: IconButton(
                          key: ValueKey('delete-${entry.id}'),
                          tooltip: 'Delete',
                          onPressed: () => _delete(entry.id),
                          icon: const Icon(Icons.delete_outline),
                        ),
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => HistoryDetailPage(entry: entry),
                            ),
                          );
                          if (context.mounted) await _load();
                        },
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class HistoryDetailPage extends StatefulWidget {
  const HistoryDetailPage({super.key, required this.entry});

  final HistoryEntry entry;

  @override
  State<HistoryDetailPage> createState() => _HistoryDetailPageState();
}

class _HistoryDetailPageState extends State<HistoryDetailPage> {
  PixelImage? _pixels;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final path = widget.entry.imagePath;
    if (path == null) return;
    final file = File(path);
    if (!await file.exists()) return;
    final image = decodeToPixelImage(await file.readAsBytes());
    if (!mounted) return;
    setState(() => _pixels = image);
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(scanKindLabel(entry.kind)),
        actions: [
          IconButton(
            key: const Key('delete-detail'),
            tooltip: 'Delete',
            onPressed: () async {
              await AppScope.of(context).history.delete(entry.id);
              if (context.mounted) Navigator.of(context).pop();
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                Text(entry.summary, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(formatTimestamp(entry.createdAt)),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: DetectionOverlay(
                    imageWidth: entry.imageWidth,
                    imageHeight: entry.imageHeight,
                    pixels: _pixels,
                    detections: entry.detections,
                    regions: entry.textRegions,
                  ),
                ),
                const SizedBox(height: 16),
                if (entry.kind == ScanKind.objectDetection)
                  for (var i = 0; i < entry.detections.length; i++)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(entry.detections[i].label),
                      trailing: Text(
                        entry.detections[i].score.toStringAsFixed(2),
                      ),
                    ),
                if (entry.kind == ScanKind.textRecognition &&
                    entry.recognizedText.isNotEmpty)
                  SelectableText(
                    entry.recognizedText,
                    key: const Key('recognized-text'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
