import '../entities/post.dart';
import '../entities/post_with_user.dart';

abstract class PostRepository {
  Future<int> createPost({
    required int userId,
    required String title,
    required String content,
  });

  Future<Post?> getPostById(int id);

  Future<List<Post>> getPosts();

  Future<List<Post>> getPostsByUserId(int userId);

  Future<List<Post>> searchPosts(String query);

  Future<List<Post>> getPostsPaginated({
    required int limit,
    required int offset,
  });

  Future<List<PostWithUser>> getPostsWithUsers();

  Future<List<PostWithUser>> getPostsWithUsersPaginated({
    required int limit,
    required int offset,
  });

  Future<bool> updatePost(Post post);

  Future<int> deletePost(int id);

  Stream<List<Post>> watchPosts();

  Stream<List<PostWithUser>> watchPostsWithUsers();
}