class Post {
  final int id;
  final int userId;
  final String title;
  final String content;
  final DateTime createdAt;

  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
  });
}