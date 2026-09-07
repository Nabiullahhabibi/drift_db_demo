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

  test('create user and post relationship', () async {
    final userId = await database.into(database.users).insert(
      UsersCompanion.insert(
        name: 'Habibi',
        email: 'habibi@example.com',
        age: const Value(25),
      ),
    );

    final postId = await database.into(database.posts).insert(
      PostsCompanion.insert(
        userId: userId,
        title: 'My First Post',
        content: 'Hello Drift',
      ),
    );

    final post = await (database.select(database.posts)
      ..where((table) => table.id.equals(postId)))
        .getSingle();

    expect(post.userId, userId);
    expect(post.title, 'My First Post');
  });

  test('join posts with users', () async {
    final userId = await database.into(database.users).insert(
      UsersCompanion.insert(
        name: 'Habibi',
        email: 'habibi@example.com',
      ),
    );

    await database.into(database.posts).insert(
      PostsCompanion.insert(
        userId: userId,
        title: 'Drift Post',
        content: 'Learning Drift relationships',
      ),
    );

    final query = database.select(database.posts).join([
      innerJoin(
        database.users,
        database.users.id.equalsExp(database.posts.userId),
      ),
    ]);

    final rows = await query.get();

    expect(rows.length, 1);

    final post = rows.first.readTable(database.posts);
    final user = rows.first.readTable(database.users);

    expect(post.title, 'Drift Post');
    expect(user.name, 'Habibi');
  });

  test('get posts for specific user', () async {
    final user1 = await database.into(database.users).insert(
      UsersCompanion.insert(
        name: 'Habibi',
        email: 'habibi@example.com',
      ),
    );

    final user2 = await database.into(database.users).insert(
      UsersCompanion.insert(
        name: 'Ahmad',
        email: 'ahmad@example.com',
      ),
    );

    await database.into(database.posts).insert(
      PostsCompanion.insert(
        userId: user1,
        title: 'Habibi Post',
        content: 'Post content',
      ),
    );

    await database.into(database.posts).insert(
      PostsCompanion.insert(
        userId: user2,
        title: 'Ahmad Post',
        content: 'Post content',
      ),
    );

    final posts = await (database.select(database.posts)
      ..where((table) => table.userId.equals(user1)))
        .get();

    expect(posts.length, 1);
    expect(posts.first.title, 'Habibi Post');
  });
}