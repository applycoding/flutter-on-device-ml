import 'package:flutter/material.dart';

import 'package:flutter_on_device_ml/src/detection/object_detector.dart';
import 'package:flutter_on_device_ml/src/history/history_entry.dart';
import 'package:flutter_on_device_ml/src/imaging/image_gateway.dart';
import 'package:flutter_on_device_ml/src/ocr/text_reader.dart';
import 'package:flutter_on_device_ml/src/theme.dart';
import 'package:flutter_on_device_ml/src/ui/guide_page.dart';
import 'package:flutter_on_device_ml/src/ui/history_page.dart';
import 'package:flutter_on_device_ml/src/ui/scan_page.dart';
import 'package:flutter_on_device_ml/src/ui/scan_session.dart';

class AppDependencies {
  const AppDependencies({
    required this.detector,
    required this.reader,
    required this.images,
    required this.history,
    required this.imageStore,
  });

  final ObjectDetector detector;
  final TextReader reader;
  final ImageGateway images;
  final HistoryRepository history;
  final ImageStore imageStore;
}

class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.dependencies,
    required super.child,
  });

  final AppDependencies dependencies;

  static AppDependencies of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    if (scope == null) {
      throw StateError('Stillframe dependencies are missing.');
    }
    return scope.dependencies;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) {
    return dependencies != oldWidget.dependencies;
  }
}

class StillframeApp extends StatefulWidget {
  const StillframeApp({
    super.key,
    required this.detector,
    required this.reader,
    required this.images,
    required this.history,
    required this.imageStore,
  });

  final ObjectDetector detector;
  final TextReader reader;
  final ImageGateway images;
  final HistoryRepository history;
  final ImageStore imageStore;

  @override
  State<StillframeApp> createState() => _StillframeAppState();
}

class _StillframeAppState extends State<StillframeApp> {
  @override
  void dispose() {
    widget.detector.close();
    widget.reader.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      dependencies: AppDependencies(
        detector: widget.detector,
        reader: widget.reader,
        images: widget.images,
        history: widget.history,
        imageStore: widget.imageStore,
      ),
      child: MaterialApp(
        title: 'Stillframe',
        debugShowCheckedModeBanner: false,
        theme: stillframeTheme(Brightness.light),
        darkTheme: stillframeTheme(Brightness.dark),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<HistoryEntry> _history = const [];
  bool _loadingHistory = true;
  bool? _modelReady;
  String? _startupError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    await _loadHistory();
    await _loadModel();
    await _recoverLostPhoto();
  }

  Future<void> _loadHistory() async {
    final history = AppScope.of(context).history;
    final entries = await history.loadAll();
    if (!mounted) return;
    setState(() {
      _history = entries;
      _loadingHistory = false;
    });
  }

  Future<void> _loadModel() async {
    final ready = await AppScope.of(context).detector.isModelReady();
    if (!mounted) return;
    setState(() => _modelReady = ready);
  }

  Future<void> _recoverLostPhoto() async {
    final PickedPhoto? recovered;
    try {
      recovered = await AppScope.of(context).images.recoverLost();
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _startupError = error.toString());
      return;
    }
    if (!mounted || recovered == null) return;
    final kind = await showDialog<ScanKind>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Photo recovered'),
          content: const Text(
            'A photo was still open when the app restarted. Run it on this phone, or dismiss it.',
          ),
          actions: [
            TextButton(
              key: const Key('recovered-dismiss'),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Dismiss'),
            ),
            TextButton(
              key: const Key('recovered-text'),
              onPressed: () =>
                  Navigator.of(context).pop(ScanKind.textRecognition),
              child: const Text('Read text'),
            ),
            FilledButton(
              key: const Key('recovered-detect'),
              onPressed: () =>
                  Navigator.of(context).pop(ScanKind.objectDetection),
              child: const Text('Detect objects'),
            ),
          ],
        );
      },
    );
    if (!mounted || kind == null) return;
    await _openScan(kind, recovered: recovered);
  }

  Future<void> _openScan(ScanKind kind, {PickedPhoto? recovered}) async {
    final deps = AppScope.of(context);
    final session = ScanSession(
      kind: kind,
      detector: deps.detector,
      reader: deps.reader,
      images: recovered == null
          ? deps.images
          : _SinglePhotoGateway(recovered, deps.images),
      history: deps.history,
      imageStore: deps.imageStore,
    );
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ScanPage(session: session, autostart: recovered != null),
      ),
    );
    session.dispose();
    if (mounted) await _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recent = _history.take(3).toList(growable: false);
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Stillframe',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const _OfflinePill(),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Object detection and text recognition run on this phone. Photos are not uploaded.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                _ModelStatus(ready: _modelReady),
                if (_startupError != null) ...[
                  const SizedBox(height: 12),
                  Text(_startupError!, key: const Key('startup-error')),
                ],
                const SizedBox(height: 20),
                _TaskCard(
                  key: const Key('detect-objects'),
                  icon: Icons.center_focus_strong,
                  title: 'Detect objects',
                  body: 'SSD MobileNet or EfficientDet-Lite through TensorFlow Lite.',
                  onPressed: () => _openScan(ScanKind.objectDetection),
                ),
                const SizedBox(height: 12),
                _TaskCard(
                  key: const Key('read-text'),
                  icon: Icons.article_outlined,
                  title: 'Read text',
                  body: 'Latin script through ML Kit, on device.',
                  onPressed: () => _openScan(ScanKind.textRecognition),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'On this phone',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    TextButton(
                      key: const Key('open-history'),
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const HistoryPage(),
                          ),
                        );
                        if (mounted) await _loadHistory();
                      },
                      child: const Text('History'),
                    ),
                  ],
                ),
                if (_loadingHistory)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Loading history'),
                  )
                else if (recent.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No scans yet. A detection or a text reading will be kept on this phone.',
                      key: Key('empty-history'),
                    ),
                  )
                else
                  for (final entry in recent)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      key: ValueKey('home-${entry.id}'),
                      title: Text(entry.summary),
                      subtitle: Text(
                        '${scanKindLabel(entry.kind)} · ${formatTimestamp(entry.createdAt)}',
                      ),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => HistoryDetailPage(entry: entry),
                          ),
                        );
                        if (mounted) await _loadHistory();
                      },
                    ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  key: const Key('open-guide'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const GuidePage()),
                    );
                  },
                  icon: const Icon(Icons.menu_book_outlined),
                  label: const Text('Model setup'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OfflinePill extends StatelessWidget {
  const _OfflinePill();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          'Offline',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}

class _ModelStatus extends StatelessWidget {
  const _ModelStatus({required this.ready});

  final bool? ready;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final known = ready;
    final text = switch (known) {
      null => 'Checking for a detection model',
      true => 'Detection model found on this phone.',
      false => 'Detection model not installed.',
    };
    return Text(text, key: const Key('model-status'), style: theme.textTheme.bodyMedium);
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(body, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

/// Feeds one recovered photo to the next pick, then defers to [fallback].
class _SinglePhotoGateway implements ImageGateway {
  _SinglePhotoGateway(this.photo, this.fallback);

  final PickedPhoto photo;
  final ImageGateway fallback;
  bool _used = false;

  @override
  Future<PickedPhoto?> pick(ImageOrigin origin) async {
    if (!_used) {
      _used = true;
      return photo;
    }
    return fallback.pick(origin);
  }

  @override
  Future<PickedPhoto?> recoverLost() => fallback.recoverLost();
}
