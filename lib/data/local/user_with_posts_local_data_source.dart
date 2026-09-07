import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';

class UserWithPostsLocalDataSource {
  final AppDatabase database;

  UserWithPostsLocalDataSource(this.database);

  Future<List<UserWithPostsRow>> getUsersWithPosts() async {
    final query = database.select(database.users).join([
      leftOuterJoin(
        database.posts,
        database.posts.userId.equalsExp(database.users.id),
      ),
    ]);

    final rows = await query.get();

    final Map<int, UserWithPostsRow> result = {};

    for (final row in rows) {
      final user = row.readTable(database.users);
      final post = row.readTableOrNull(database.posts);

      final existing = result[user.id];

      if (existing == null) {
        result[user.id] = UserWithPostsRow(
          user: user,
          posts: post == null ? [] : [post],
        );
      } else if (post != null) {
        existing.posts.add(post);
      }
    }

    return result.values.toList();
  }

  Stream<List<UserWithPostsRow>> watchUsersWithPosts() {
    final query = database.select(database.users).join([
      leftOuterJoin(
        database.posts,
        database.posts.userId.equalsExp(database.users.id),
      ),
    ]);

    return query.watch().map((rows) {
      final Map<int, UserWithPostsRow> result = {};

      for (final row in rows) {
        final user = row.readTable(database.users);
        final post = row.readTableOrNull(database.posts);

        final existing = result[user.id];

        if (existing == null) {
          result[user.id] = UserWithPostsRow(
            user: user,
            posts: post == null ? [] : [post],
          );
        } else if (post != null) {
          existing.posts.add(post);
        }
      }

      return result.values.toList();
    });
  }
}

class UserWithPostsRow {
  final User user;
  final List<Post> posts;

  UserWithPostsRow({
    required this.user,
    required this.posts,
  });
}