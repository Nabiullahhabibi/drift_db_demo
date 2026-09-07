import 'package:drift/drift.dart';
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

  test('post pagination works', () async {
    final userId = await database.into(database.users).insert(
      UsersCompanion.insert(
        name: 'Habibi',
        email: 'habibi@example.com',
      ),
    );

    for (var i = 1; i <= 10; i++) {
      await database.into(database.posts).insert(
        PostsCompanion.insert(
          userId: userId,
          title: 'Post $i',
          content: 'Content $i',
        ),
      );
    }

    final page1 = await (database.select(database.posts)
      ..orderBy([
            (table) => OrderingTerm.desc(table.id),
      ])
      ..limit(5, offset: 0))
        .get();

    final page2 = await (database.select(database.posts)
      ..orderBy([
            (table) => OrderingTerm.desc(table.id),
      ])
      ..limit(5, offset: 5))
        .get();

    expect(page1.length, 5);
    expect(page2.length, 5);

    expect(
      page1.map((post) => post.id).toSet().intersection(
        page2.map((post) => post.id).toSet(),
      ),
      isEmpty,
    );
  });
}