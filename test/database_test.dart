import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/core/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(
      NativeDatabase.memory(),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('insert and read user', () async {
    final id = await database.into(database.users).insert(
      UsersCompanion.insert(
        name: 'Habibi',
        email: 'habibi@example.com',
        age: const Value(25),
      ),
    );

    final user = await (database.select(database.users)
      ..where((table) => table.id.equals(id)))
        .getSingle();

    expect(user.name, 'Habibi');
    expect(user.email, 'habibi@example.com');
    expect(user.age, 25);
  });

  test('update user', () async {
    final id = await database.into(database.users).insert(
      UsersCompanion.insert(
        name: 'Old Name',
        email: 'old@example.com',
        age: const Value(20),
      ),
    );

    final updated = await (database.update(database.users)
      ..where((table) => table.id.equals(id)))
        .write(
      const UsersCompanion(
        name: Value('New Name'),
      ),
    );

    expect(updated, 1);

    final user = await (database.select(database.users)
      ..where((table) => table.id.equals(id)))
        .getSingle();

    expect(user.name, 'New Name');
  });

  test('delete user', () async {
    final id = await database.into(database.users).insert(
      UsersCompanion.insert(
        name: 'Delete Me',
        email: 'delete@example.com',
      ),
    );

    final deleted = await (database.delete(database.users)
      ..where((table) => table.id.equals(id)))
        .go();

    expect(deleted, 1);

    final user = await (database.select(database.users)
      ..where((table) => table.id.equals(id)))
        .getSingleOrNull();

    expect(user, isNull);
  });

  test('search users', () async {
    await database.batch(
          (batch) {
        batch.insertAll(
          database.users,
          [
            UsersCompanion.insert(
              name: 'Ali',
              email: 'ali@example.com',
            ),
            UsersCompanion.insert(
              name: 'Ahmad',
              email: 'ahmad@example.com',
            ),
            UsersCompanion.insert(
              name: 'John',
              email: 'john@example.com',
            ),
          ],
        );
      },
    );

    final users = await (database.select(database.users)
      ..where(
            (table) => table.name.like('%Ahmad%'),
      ))
        .get();

    expect(users.length, 1);
    expect(users.first.name, 'Ahmad');
  });
}