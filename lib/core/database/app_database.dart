import 'package:drift/drift.dart';

import 'database_connection.dart';

part 'app_database.g.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(
    min: 1,
    max: 100,
  )();

  TextColumn get email => text().unique()();

  IntColumn get age => integer().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(
    currentDateAndTime,
  )();
}

class Posts extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get userId => integer().references(
    Users,
    #id,
    onDelete: KeyAction.cascade,
  )();

  TextColumn get title => text().withLength(
    min: 1,
    max: 200,
  )();

  TextColumn get content => text()();

  DateTimeColumn get createdAt => dateTime().withDefault(
    currentDateAndTime,
  )();

  @override
  List<Set<Column>> get uniqueKeys => [];
}

@DriftDatabase(
  tables: [
    Users,
    Posts,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  AppDatabase.forTesting(QueryExecutor executor)
      : super(executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },

    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(posts);
      }
    },

    beforeOpen: (details) async {
      await customStatement(
        'PRAGMA foreign_keys = ON',
      );
    },
  );
}