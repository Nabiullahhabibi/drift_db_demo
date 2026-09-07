import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../local/drift_local_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  final DriftLocalDataSource localDataSource;

  UserRepositoryImpl(this.localDataSource);

  @override
  Future<int> createUser({
    required String name,
    required String email,
    int? age,
  }) {
    return localDataSource.createUser(
      name: name,
      email: email,
      age: age,
    );
  }

  @override
  Future<User?> getUserById(int id) async {
    final user = await localDataSource.getUserById(id);

    if (user == null) {
      return null;
    }

    return _mapUser(user);
  }

  @override
  Future<List<User>> getUsers() async {
    final users = await localDataSource.getUsers();

    return users.map(_mapUser).toList();
  }

  @override
  Future<List<User>> searchUsers(String query) async {
    final users = await localDataSource.searchUsers(query);

    return users.map(_mapUser).toList();
  }

  @override
  Future<List<User>> getUsersPaginated({
    required int limit,
    required int offset,
  }) async {
    final users = await localDataSource.getUsersPaginated(
      limit: limit,
      offset: offset,
    );

    return users.map(_mapUser).toList();
  }

  @override
  Future<bool> updateUser(User user) {
    return localDataSource.updateUser(
      id: user.id,
      name: user.name,
      email: user.email,
      age: user.age,
      createdAt: user.createdAt,
    );
  }

  @override
  Future<int> deleteUser(int id) {
    return localDataSource.deleteUser(id);
  }

  @override
  Stream<List<User>> watchUsers() {
    return localDataSource.watchUsers().map(
          (users) => users.map(_mapUser).toList(),
    );
  }

  User _mapUser(dynamic user) {
    return User(
      id: user.id,
      name: user.name,
      email: user.email,
      age: user.age,
      createdAt: user.createdAt,
    );
  }
}