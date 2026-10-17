import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'history_database.g.dart';

class ScanRecords extends Table {
  TextColumn get id => text()();
  IntColumn get createdAtMillis => integer()();
  TextColumn get kind => text()();
  TextColumn get summary => text()();
  TextColumn get detailsJson => text()();
  IntColumn get imageWidth => integer()();
  IntColumn get imageHeight => integer()();
  TextColumn get imagePath => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [ScanRecords])
class HistoryDatabase extends _$HistoryDatabase {
  HistoryDatabase(super.executor);

  HistoryDatabase.defaults() : super(driftDatabase(name: 'stillframe_history'));

  @override
  int get schemaVersion => 1;
}
