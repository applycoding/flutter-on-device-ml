// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_database.dart';

// ignore_for_file: type=lint
class $ScanRecordsTable extends ScanRecords
    with TableInfo<$ScanRecordsTable, ScanRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMillisMeta = const VerificationMeta(
    'createdAtMillis',
  );
  @override
  late final GeneratedColumn<int> createdAtMillis = GeneratedColumn<int>(
    'created_at_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailsJsonMeta = const VerificationMeta(
    'detailsJson',
  );
  @override
  late final GeneratedColumn<String> detailsJson = GeneratedColumn<String>(
    'details_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageWidthMeta = const VerificationMeta(
    'imageWidth',
  );
  @override
  late final GeneratedColumn<int> imageWidth = GeneratedColumn<int>(
    'image_width',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageHeightMeta = const VerificationMeta(
    'imageHeight',
  );
  @override
  late final GeneratedColumn<int> imageHeight = GeneratedColumn<int>(
    'image_height',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAtMillis,
    kind,
    summary,
    detailsJson,
    imageWidth,
    imageHeight,
    imagePath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScanRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at_millis')) {
      context.handle(
        _createdAtMillisMeta,
        createdAtMillis.isAcceptableOrUnknown(
          data['created_at_millis']!,
          _createdAtMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMillisMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    } else if (isInserting) {
      context.missing(_summaryMeta);
    }
    if (data.containsKey('details_json')) {
      context.handle(
        _detailsJsonMeta,
        detailsJson.isAcceptableOrUnknown(
          data['details_json']!,
          _detailsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_detailsJsonMeta);
    }
    if (data.containsKey('image_width')) {
      context.handle(
        _imageWidthMeta,
        imageWidth.isAcceptableOrUnknown(data['image_width']!, _imageWidthMeta),
      );
    } else if (isInserting) {
      context.missing(_imageWidthMeta);
    }
    if (data.containsKey('image_height')) {
      context.handle(
        _imageHeightMeta,
        imageHeight.isAcceptableOrUnknown(
          data['image_height']!,
          _imageHeightMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_imageHeightMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScanRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_millis'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      detailsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details_json'],
      )!,
      imageWidth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}image_width'],
      )!,
      imageHeight: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}image_height'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
    );
  }

  @override
  $ScanRecordsTable createAlias(String alias) {
    return $ScanRecordsTable(attachedDatabase, alias);
  }
}

class ScanRecord extends DataClass implements Insertable<ScanRecord> {
  final String id;
  final int createdAtMillis;
  final String kind;
  final String summary;
  final String detailsJson;
  final int imageWidth;
  final int imageHeight;
  final String? imagePath;
  const ScanRecord({
    required this.id,
    required this.createdAtMillis,
    required this.kind,
    required this.summary,
    required this.detailsJson,
    required this.imageWidth,
    required this.imageHeight,
    this.imagePath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at_millis'] = Variable<int>(createdAtMillis);
    map['kind'] = Variable<String>(kind);
    map['summary'] = Variable<String>(summary);
    map['details_json'] = Variable<String>(detailsJson);
    map['image_width'] = Variable<int>(imageWidth);
    map['image_height'] = Variable<int>(imageHeight);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    return map;
  }

  ScanRecordsCompanion toCompanion(bool nullToAbsent) {
    return ScanRecordsCompanion(
      id: Value(id),
      createdAtMillis: Value(createdAtMillis),
      kind: Value(kind),
      summary: Value(summary),
      detailsJson: Value(detailsJson),
      imageWidth: Value(imageWidth),
      imageHeight: Value(imageHeight),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
    );
  }

  factory ScanRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanRecord(
      id: serializer.fromJson<String>(json['id']),
      createdAtMillis: serializer.fromJson<int>(json['createdAtMillis']),
      kind: serializer.fromJson<String>(json['kind']),
      summary: serializer.fromJson<String>(json['summary']),
      detailsJson: serializer.fromJson<String>(json['detailsJson']),
      imageWidth: serializer.fromJson<int>(json['imageWidth']),
      imageHeight: serializer.fromJson<int>(json['imageHeight']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAtMillis': serializer.toJson<int>(createdAtMillis),
      'kind': serializer.toJson<String>(kind),
      'summary': serializer.toJson<String>(summary),
      'detailsJson': serializer.toJson<String>(detailsJson),
      'imageWidth': serializer.toJson<int>(imageWidth),
      'imageHeight': serializer.toJson<int>(imageHeight),
      'imagePath': serializer.toJson<String?>(imagePath),
    };
  }

  ScanRecord copyWith({
    String? id,
    int? createdAtMillis,
    String? kind,
    String? summary,
    String? detailsJson,
    int? imageWidth,
    int? imageHeight,
    Value<String?> imagePath = const Value.absent(),
  }) => ScanRecord(
    id: id ?? this.id,
    createdAtMillis: createdAtMillis ?? this.createdAtMillis,
    kind: kind ?? this.kind,
    summary: summary ?? this.summary,
    detailsJson: detailsJson ?? this.detailsJson,
    imageWidth: imageWidth ?? this.imageWidth,
    imageHeight: imageHeight ?? this.imageHeight,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
  );
  ScanRecord copyWithCompanion(ScanRecordsCompanion data) {
    return ScanRecord(
      id: data.id.present ? data.id.value : this.id,
      createdAtMillis: data.createdAtMillis.present
          ? data.createdAtMillis.value
          : this.createdAtMillis,
      kind: data.kind.present ? data.kind.value : this.kind,
      summary: data.summary.present ? data.summary.value : this.summary,
      detailsJson: data.detailsJson.present
          ? data.detailsJson.value
          : this.detailsJson,
      imageWidth: data.imageWidth.present
          ? data.imageWidth.value
          : this.imageWidth,
      imageHeight: data.imageHeight.present
          ? data.imageHeight.value
          : this.imageHeight,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanRecord(')
          ..write('id: $id, ')
          ..write('createdAtMillis: $createdAtMillis, ')
          ..write('kind: $kind, ')
          ..write('summary: $summary, ')
          ..write('detailsJson: $detailsJson, ')
          ..write('imageWidth: $imageWidth, ')
          ..write('imageHeight: $imageHeight, ')
          ..write('imagePath: $imagePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAtMillis,
    kind,
    summary,
    detailsJson,
    imageWidth,
    imageHeight,
    imagePath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanRecord &&
          other.id == this.id &&
          other.createdAtMillis == this.createdAtMillis &&
          other.kind == this.kind &&
          other.summary == this.summary &&
          other.detailsJson == this.detailsJson &&
          other.imageWidth == this.imageWidth &&
          other.imageHeight == this.imageHeight &&
          other.imagePath == this.imagePath);
}

class ScanRecordsCompanion extends UpdateCompanion<ScanRecord> {
  final Value<String> id;
  final Value<int> createdAtMillis;
  final Value<String> kind;
  final Value<String> summary;
  final Value<String> detailsJson;
  final Value<int> imageWidth;
  final Value<int> imageHeight;
  final Value<String?> imagePath;
  final Value<int> rowid;
  const ScanRecordsCompanion({
    this.id = const Value.absent(),
    this.createdAtMillis = const Value.absent(),
    this.kind = const Value.absent(),
    this.summary = const Value.absent(),
    this.detailsJson = const Value.absent(),
    this.imageWidth = const Value.absent(),
    this.imageHeight = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScanRecordsCompanion.insert({
    required String id,
    required int createdAtMillis,
    required String kind,
    required String summary,
    required String detailsJson,
    required int imageWidth,
    required int imageHeight,
    this.imagePath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAtMillis = Value(createdAtMillis),
       kind = Value(kind),
       summary = Value(summary),
       detailsJson = Value(detailsJson),
       imageWidth = Value(imageWidth),
       imageHeight = Value(imageHeight);
  static Insertable<ScanRecord> custom({
    Expression<String>? id,
    Expression<int>? createdAtMillis,
    Expression<String>? kind,
    Expression<String>? summary,
    Expression<String>? detailsJson,
    Expression<int>? imageWidth,
    Expression<int>? imageHeight,
    Expression<String>? imagePath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAtMillis != null) 'created_at_millis': createdAtMillis,
      if (kind != null) 'kind': kind,
      if (summary != null) 'summary': summary,
      if (detailsJson != null) 'details_json': detailsJson,
      if (imageWidth != null) 'image_width': imageWidth,
      if (imageHeight != null) 'image_height': imageHeight,
      if (imagePath != null) 'image_path': imagePath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScanRecordsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAtMillis,
    Value<String>? kind,
    Value<String>? summary,
    Value<String>? detailsJson,
    Value<int>? imageWidth,
    Value<int>? imageHeight,
    Value<String?>? imagePath,
    Value<int>? rowid,
  }) {
    return ScanRecordsCompanion(
      id: id ?? this.id,
      createdAtMillis: createdAtMillis ?? this.createdAtMillis,
      kind: kind ?? this.kind,
      summary: summary ?? this.summary,
      detailsJson: detailsJson ?? this.detailsJson,
      imageWidth: imageWidth ?? this.imageWidth,
      imageHeight: imageHeight ?? this.imageHeight,
      imagePath: imagePath ?? this.imagePath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAtMillis.present) {
      map['created_at_millis'] = Variable<int>(createdAtMillis.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (detailsJson.present) {
      map['details_json'] = Variable<String>(detailsJson.value);
    }
    if (imageWidth.present) {
      map['image_width'] = Variable<int>(imageWidth.value);
    }
    if (imageHeight.present) {
      map['image_height'] = Variable<int>(imageHeight.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScanRecordsCompanion(')
          ..write('id: $id, ')
          ..write('createdAtMillis: $createdAtMillis, ')
          ..write('kind: $kind, ')
          ..write('summary: $summary, ')
          ..write('detailsJson: $detailsJson, ')
          ..write('imageWidth: $imageWidth, ')
          ..write('imageHeight: $imageHeight, ')
          ..write('imagePath: $imagePath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$HistoryDatabase extends GeneratedDatabase {
  _$HistoryDatabase(QueryExecutor e) : super(e);
  $HistoryDatabaseManager get managers => $HistoryDatabaseManager(this);
  late final $ScanRecordsTable scanRecords = $ScanRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [scanRecords];
}

typedef $$ScanRecordsTableCreateCompanionBuilder =
    ScanRecordsCompanion Function({
      required String id,
      required int createdAtMillis,
      required String kind,
      required String summary,
      required String detailsJson,
      required int imageWidth,
      required int imageHeight,
      Value<String?> imagePath,
      Value<int> rowid,
    });
typedef $$ScanRecordsTableUpdateCompanionBuilder =
    ScanRecordsCompanion Function({
      Value<String> id,
      Value<int> createdAtMillis,
      Value<String> kind,
      Value<String> summary,
      Value<String> detailsJson,
      Value<int> imageWidth,
      Value<int> imageHeight,
      Value<String?> imagePath,
      Value<int> rowid,
    });

class $$ScanRecordsTableFilterComposer
    extends Composer<_$HistoryDatabase, $ScanRecordsTable> {
  $$ScanRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get imageWidth => $composableBuilder(
    column: $table.imageWidth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get imageHeight => $composableBuilder(
    column: $table.imageHeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScanRecordsTableOrderingComposer
    extends Composer<_$HistoryDatabase, $ScanRecordsTable> {
  $$ScanRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get imageWidth => $composableBuilder(
    column: $table.imageWidth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get imageHeight => $composableBuilder(
    column: $table.imageHeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScanRecordsTableAnnotationComposer
    extends Composer<_$HistoryDatabase, $ScanRecordsTable> {
  $$ScanRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get imageWidth => $composableBuilder(
    column: $table.imageWidth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get imageHeight => $composableBuilder(
    column: $table.imageHeight,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);
}

class $$ScanRecordsTableTableManager
    extends
        RootTableManager<
          _$HistoryDatabase,
          $ScanRecordsTable,
          ScanRecord,
          $$ScanRecordsTableFilterComposer,
          $$ScanRecordsTableOrderingComposer,
          $$ScanRecordsTableAnnotationComposer,
          $$ScanRecordsTableCreateCompanionBuilder,
          $$ScanRecordsTableUpdateCompanionBuilder,
          (
            ScanRecord,
            BaseReferences<_$HistoryDatabase, $ScanRecordsTable, ScanRecord>,
          ),
          ScanRecord,
          PrefetchHooks Function()
        > {
  $$ScanRecordsTableTableManager(_$HistoryDatabase db, $ScanRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScanRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScanRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScanRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAtMillis = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<String> detailsJson = const Value.absent(),
                Value<int> imageWidth = const Value.absent(),
                Value<int> imageHeight = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScanRecordsCompanion(
                id: id,
                createdAtMillis: createdAtMillis,
                kind: kind,
                summary: summary,
                detailsJson: detailsJson,
                imageWidth: imageWidth,
                imageHeight: imageHeight,
                imagePath: imagePath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAtMillis,
                required String kind,
                required String summary,
                required String detailsJson,
                required int imageWidth,
                required int imageHeight,
                Value<String?> imagePath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScanRecordsCompanion.insert(
                id: id,
                createdAtMillis: createdAtMillis,
                kind: kind,
                summary: summary,
                detailsJson: detailsJson,
                imageWidth: imageWidth,
                imageHeight: imageHeight,
                imagePath: imagePath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScanRecordsTable, ScanRecord>(table),
                  BaseReferences<
                    _$HistoryDatabase,
                    $ScanRecordsTable,
                    ScanRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScanRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$HistoryDatabase,
      $ScanRecordsTable,
      ScanRecord,
      $$ScanRecordsTableFilterComposer,
      $$ScanRecordsTableOrderingComposer,
      $$ScanRecordsTableAnnotationComposer,
      $$ScanRecordsTableCreateCompanionBuilder,
      $$ScanRecordsTableUpdateCompanionBuilder,
      (
        ScanRecord,
        BaseReferences<_$HistoryDatabase, $ScanRecordsTable, ScanRecord>,
      ),
      ScanRecord,
      PrefetchHooks Function()
    >;

class $HistoryDatabaseManager {
  final _$HistoryDatabase _db;
  $HistoryDatabaseManager(this._db);
  $$ScanRecordsTableTableManager get scanRecords =>
      $$ScanRecordsTableTableManager(_db, _db.scanRecords);
}
