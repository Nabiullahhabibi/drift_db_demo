import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';

class DriftLocalDataSource {
  final AppDatabase database;

  DriftLocalDataSource(this.database);

  // CREATE
  Future<int> createUser({
    required String name,
    required String email,
    int? age,
  }) {
    return database.into(database.users).insert(
      UsersCompanion.insert(
        name: name,
        email: email,
        age: Value(age),
      ),
    );
  }

  // READ ONE
  Future<User?> getUserById(int id) {
    return (database.select(database.users)
      ..where((table) => table.id.equals(id)))
        .getSingleOrNull();
  }

  // READ ALL
  Future<List<User>> getUsers() {
    return database.select(database.users).get();
  }

  // SEARCH
  Future<List<User>> searchUsers(String query) {
    return (database.select(database.users)
      ..where(
            (table) =>
        table.name.like('%$query%') |
        table.email.like('%$query%'),
      )
      ..orderBy([
            (table) => OrderingTerm.asc(table.name),
      ]))
        .get();
  }

  // PAGINATION
  Future<List<User>> getUsersPaginated({
    required int limit,
    required int offset,
  }) {
    return (database.select(database.users)
      ..orderBy([
            (table) => OrderingTerm.asc(table.id),
      ])
      ..limit(limit, offset: offset))
        .get();
  }

  // UPDATE
  Future<bool> updateUser({
    required int id,
    required String name,
    required String email,
    required int? age,
    required DateTime createdAt,
  }) async {
    final rowsUpdated = await (database.update(database.users)
      ..where((table) => table.id.equals(id)))
        .write(
      UsersCompanion(
        name: Value(name),
        email: Value(email),
        age: Value(age),
        createdAt: Value(createdAt),
      ),
    );

    return rowsUpdated > 0;
  }

  // DELETE
  Future<int> deleteUser(int id) {
    return (database.delete(database.users)
      ..where((table) => table.id.equals(id)))
        .go();
  }

  // REACTIVE QUERY
  Stream<List<User>> watchUsers() {
    return database.select(database.users).watch();
  }
}