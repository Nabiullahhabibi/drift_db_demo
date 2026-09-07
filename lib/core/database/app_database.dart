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

@DriftDatabase(
  tables: [
    Users,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  AppDatabase.forTesting(QueryExecutor executor)
      : super(executor);

  @override
  int get schemaVersion => 1;
}