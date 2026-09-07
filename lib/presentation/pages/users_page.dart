import 'package:flutter/material.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/repositories/user_repository.dart';
import 'user_details_page.dart';

class UsersPage extends StatelessWidget {
  final UserRepository repository;
  final PostRepository postRepository;

  const UsersPage({
    super.key,
    required this.repository,
    required this.postRepository,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: StreamBuilder<List<User>>(
        stream: repository.watchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return const Center(
              child: Text('No users found.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final user = users[index];

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      user.name.isNotEmpty
                          ? user.name[0].toUpperCase()
                          : '?',
                    ),
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => UserDetailsPage(
                          user: user,
                          postRepository: postRepository,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}