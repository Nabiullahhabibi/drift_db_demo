import '../entities/user.dart';

abstract class UserRepository {
  Future<int> createUser({
    required String name,
    required String email,
    int? age,
  });

  Future<User?> getUserById(int id);

  Future<List<User>> getUsers();

  Future<List<User>> searchUsers(String query);

  Future<List<User>> getUsersPaginated({
    required int limit,
    required int offset,
  });

  Future<bool> updateUser(User user);

  Future<int> deleteUser(int id);

  Stream<List<User>> watchUsers();
}