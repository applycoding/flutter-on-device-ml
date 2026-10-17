import 'package:drift/drift.dart';

import 'package:flutter_on_device_ml/src/history/history_database.dart';
import 'package:flutter_on_device_ml/src/history/history_entry.dart';

/// On-device scan history in a Drift SQLite file.
class DriftHistoryRepository implements HistoryRepository {
  DriftHistoryRepository(this._database);

  final HistoryDatabase _database;

  @override
  Future<List<HistoryEntry>> loadAll() async {
    final query = _database.select(_database.scanRecords)
      ..orderBy([
        (row) => OrderingTerm(
          expression: row.createdAtMillis,
          mode: OrderingMode.desc,
        ),
      ]);
    final rows = await query.get();
    return [
      for (final row in rows)
        HistoryEntry.fromStorage(
          id: row.id,
          createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAtMillis),
          kindName: row.kind,
          summary: row.summary,
          imageWidth: row.imageWidth,
          imageHeight: row.imageHeight,
          imagePath: row.imagePath,
          detailsJson: row.detailsJson,
        ),
    ];
  }

  @override
  Future<void> save(HistoryEntry entry) async {
    await _database
        .into(_database.scanRecords)
        .insert(
          ScanRecordsCompanion.insert(
            id: entry.id,
            createdAtMillis: entry.createdAt.millisecondsSinceEpoch,
            kind: entry.kind.name,
            summary: entry.summary,
            detailsJson: entry.detailsJson,
            imageWidth: entry.imageWidth,
            imageHeight: entry.imageHeight,
            imagePath: Value(entry.imagePath),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  @override
  Future<void> delete(String id) async {
    await (_database.delete(
      _database.scanRecords,
    )..where((row) => row.id.equals(id))).go();
  }
}
