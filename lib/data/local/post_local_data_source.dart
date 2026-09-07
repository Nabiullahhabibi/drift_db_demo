import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';

class PostLocalDataSource {
  final AppDatabase database;

  PostLocalDataSource(this.database);

  // ----------------------------------------------------------
  // CREATE
  // ----------------------------------------------------------

  Future<int> createPost({
    required int userId,
    required String title,
    required String content,
  }) {
    return database.into(database.posts).insert(
      PostsCompanion.insert(
        userId: userId,
        title: title,
        content: content,
      ),
    );
  }

  // ----------------------------------------------------------
  // GET BY ID
  // ----------------------------------------------------------

  Future<Post?> getPostById(int id) {
    return (database.select(database.posts)
      ..where((table) => table.id.equals(id)))
        .getSingleOrNull();
  }

  // ----------------------------------------------------------
  // GET ALL
  // ----------------------------------------------------------

  Future<List<Post>> getPosts() {
    return (database.select(database.posts)
      ..orderBy([
            (table) => OrderingTerm.desc(table.createdAt),
      ]))
        .get();
  }

  // ----------------------------------------------------------
  // GET POSTS BY USER
  // ----------------------------------------------------------

  Future<List<Post>> getPostsByUserId(int userId) {
    return (database.select(database.posts)
      ..where((table) => table.userId.equals(userId))
      ..orderBy([
            (table) => OrderingTerm.desc(table.createdAt),
      ]))
        .get();
  }

  // ----------------------------------------------------------
  // SEARCH
  // ----------------------------------------------------------

  Future<List<Post>> searchPosts(String query) {
    return (database.select(database.posts)
      ..where(
            (table) =>
        table.title.like('%$query%') |
        table.content.like('%$query%'),
      )
      ..orderBy([
            (table) => OrderingTerm.desc(table.createdAt),
      ]))
        .get();
  }

  // ----------------------------------------------------------
  // PAGINATION
  // ----------------------------------------------------------

  Future<List<Post>> getPostsPaginated({
    required int limit,
    required int offset,
  }) {
    return (database.select(database.posts)
      ..orderBy([
            (table) => OrderingTerm.desc(table.id),
      ])
      ..limit(
        limit,
        offset: offset,
      ))
        .get();
  }

  // ----------------------------------------------------------
  // UPDATE
  // ----------------------------------------------------------

  Future<bool> updatePost({
    required int id,
    required int userId,
    required String title,
    required String content,
    required DateTime createdAt,
  }) async {
    final rowsUpdated = await (database.update(database.posts)
      ..where((table) => table.id.equals(id)))
        .write(
      PostsCompanion(
        userId: Value(userId),
        title: Value(title),
        content: Value(content),
        createdAt: Value(createdAt),
      ),
    );

    return rowsUpdated > 0;
  }

  // ----------------------------------------------------------
  // DELETE
  // ----------------------------------------------------------

  Future<int> deletePost(int id) {
    return (database.delete(database.posts)
      ..where((table) => table.id.equals(id)))
        .go();
  }

  // ----------------------------------------------------------
  // WATCH
  // ----------------------------------------------------------

  Stream<List<Post>> watchPosts() {
    return (database.select(database.posts)
      ..orderBy([
            (table) => OrderingTerm.desc(table.createdAt),
      ]))
        .watch();
  }

  // ----------------------------------------------------------
  // JOIN POSTS + USERS
  // ----------------------------------------------------------
/*
One correction to the files I gave you previously

In post_local_data_source.dart, the following is currently fine:

innerJoin(
  database.users,
  database.users.id.equalsExp(database.posts.userId),
)

But for:

User → Posts

we intentionally use:

leftOuterJoin(...)

because we want users who have zero posts to still appear.

So:

INNER JOIN

means:

Only users/posts that have a match

while:

LEFT OUTER JOIN

means:

Give me every user,
even if they don't have any posts.

That's an important real-world SQL concept.
 */
  Future<List<PostWithUserRow>> getPostsWithUsers() async {
    final query = database.select(database.posts).join([

      // innerJoin(
        leftOuterJoin(
        database.users,
        database.users.id.equalsExp(database.posts.userId),
      ),
    ]);

    final rows = await query.get();

    return rows.map((row) {
      return PostWithUserRow(
        post: row.readTable(database.posts),
        user: row.readTable(database.users),
      );
    }).toList();
  }

  // ----------------------------------------------------------
  // JOIN + PAGINATION
  // ----------------------------------------------------------

  Future<List<PostWithUserRow>> getPostsWithUsersPaginated({
    required int limit,
    required int offset,
  }) async {
    final query = database.select(database.posts).join([
      innerJoin(
        database.users,
        database.users.id.equalsExp(database.posts.userId),
      ),
    ])
      ..orderBy([
        OrderingTerm.desc(database.posts.id),
      ])
      ..limit(
        limit,
        offset: offset,
      );

    final rows = await query.get();

    return rows.map((row) {
      return PostWithUserRow(
        post: row.readTable(database.posts),
        user: row.readTable(database.users),
      );
    }).toList();
  }

  // ----------------------------------------------------------
  // REACTIVE JOIN
  // ----------------------------------------------------------

  Stream<List<PostWithUserRow>> watchPostsWithUsers() {
    final query = database.select(database.posts).join([
      innerJoin(
        database.users,
        database.users.id.equalsExp(database.posts.userId),
      ),
    ])
      ..orderBy([
        OrderingTerm.desc(database.posts.createdAt),
      ]);

    return query.watch().map(
          (rows) {
        return rows.map((row) {
          return PostWithUserRow(
            post: row.readTable(database.posts),
            user: row.readTable(database.users),
          );
        }).toList();
      },
    );
  }
}

/// Internal data model used between Drift and repository.
class PostWithUserRow {
  final Post post;
  final User user;

  const PostWithUserRow({
    required this.post,
    required this.user,
  });
}