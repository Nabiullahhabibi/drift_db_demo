class User {
  final int id;
  final String name;
  final String email;
  final int? age;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.createdAt,
  });
}