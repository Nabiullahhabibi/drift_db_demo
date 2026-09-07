import 'dart:async';

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

  test('watch posts reacts to database changes', () async {
    final userId = await database.into(database.users).insert(
      UsersCompanion.insert(
        name: 'Habibi',
        email: 'habibi@example.com',
      ),
    );

    final stream = database.select(database.posts).watch();

    final events = <List<Post>>[];

    final subscription = stream.listen(events.add);

    await Future<void>.delayed(
      const Duration(milliseconds: 50),
    );

    await database.into(database.posts).insert(
      PostsCompanion.insert(
        userId: userId,
        title: 'Reactive Post',
        content: 'Testing Drift watch',
      ),
    );

    await Future<void>.delayed(
      const Duration(milliseconds: 100),
    );

    expect(events.any((posts) => posts.length == 1), isTrue);

    await subscription.cancel();
  });
}