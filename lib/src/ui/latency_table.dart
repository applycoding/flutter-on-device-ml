import 'package:flutter/material.dart';

/// Latency cells are placeholders. This demo does not ship measurements.
class LatencyTable extends StatelessWidget {
  const LatencyTable({super.key});

  static const rows = <(String, String)>[
    ('Letterbox', 'placeholder'),
    ('Interpreter invoke', 'placeholder'),
    ('NMS and coordinate mapping', 'placeholder'),
    ('End to end on a phone', 'placeholder'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      key: const Key('latency-table'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Latency', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'These cells are placeholders. Nothing here has been measured.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(child: Text(row.$1)),
                    Text(
                      row.$2,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.tertiary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
