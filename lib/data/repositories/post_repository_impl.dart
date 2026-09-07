import '../../core/database/app_database.dart' as db;
import '../../domain/entities/post.dart';
import '../../domain/entities/post_with_user.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/repositories/post_repository.dart';
import '../local/post_local_data_source.dart';

class PostRepositoryImpl implements PostRepository {
  final PostLocalDataSource localDataSource;

  PostRepositoryImpl(this.localDataSource);

  Post _mapPost(db.Post post) {
    return Post(
      id: post.id,
      userId: post.userId,
      title: post.title,
      content: post.content,
      createdAt: post.createdAt,
    );
  }

  domain.User _mapUser(db.User user) {
    return domain.User(
      id: user.id,
      name: user.name,
      email: user.email,
      age: user.age,
      createdAt: user.createdAt,
    );
  }

  PostWithUser _mapPostWithUser(PostWithUserRow row) {
    return PostWithUser(
      post: _mapPost(row.post),
      user: _mapUser(row.user),
    );
  }

  @override
  Future<int> createPost({
    required int userId,
    required String title,
    required String content,
  }) {
    return localDataSource.createPost(
      userId: userId,
      title: title,
      content: content,
    );
  }

  @override
  Future<Post?> getPostById(int id) async {
    final post = await localDataSource.getPostById(id);

    return post == null ? null : _mapPost(post);
  }

  @override
  Future<List<Post>> getPosts() async {
    final posts = await localDataSource.getPosts();

    return posts.map(_mapPost).toList();
  }

  @override
  Future<List<Post>> getPostsByUserId(int userId) async {
    final posts = await localDataSource.getPostsByUserId(userId);

    return posts.map(_mapPost).toList();
  }

  @override
  Future<List<Post>> searchPosts(String query) async {
    final posts = await localDataSource.searchPosts(query);

    return posts.map(_mapPost).toList();
  }

  @override
  Future<List<Post>> getPostsPaginated({
    required int limit,
    required int offset,
  }) async {
    final posts = await localDataSource.getPostsPaginated(
      limit: limit,
      offset: offset,
    );

    return posts.map(_mapPost).toList();
  }

  @override
  Future<List<PostWithUser>> getPostsWithUsers() async {
    final rows = await localDataSource.getPostsWithUsers();

    return rows.map(_mapPostWithUser).toList();
  }

  @override
  Future<List<PostWithUser>> getPostsWithUsersPaginated({
    required int limit,
    required int offset,
  }) async {
    final rows = await localDataSource.getPostsWithUsersPaginated(
      limit: limit,
      offset: offset,
    );

    return rows.map(_mapPostWithUser).toList();
  }

  @override
  Future<bool> updatePost(Post post) {
    return localDataSource.updatePost(
      id: post.id,
      userId: post.userId,
      title: post.title,
      content: post.content,
      createdAt: post.createdAt,
    );
  }

  @override
  Future<int> deletePost(int id) {
    return localDataSource.deletePost(id);
  }

  @override
  Stream<List<Post>> watchPosts() {
    return localDataSource
        .watchPosts()
        .map((posts) => posts.map(_mapPost).toList());
  }

  @override
  Stream<List<PostWithUser>> watchPostsWithUsers() {
    return localDataSource
        .watchPostsWithUsers()
        .map((rows) => rows.map(_mapPostWithUser).toList());
  }
}