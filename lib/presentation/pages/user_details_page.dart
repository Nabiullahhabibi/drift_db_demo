import 'package:flutter/material.dart';

import '../../domain/entities/post.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/post_repository.dart';

class UserDetailsPage extends StatelessWidget {
  final User user;
  final PostRepository postRepository;

  const UserDetailsPage({
    super.key,
    required this.user,
    required this.postRepository,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
      ),
      body: FutureBuilder<List<Post>>(
        future: postRepository.getPostsByUserId(
          user.id,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          }

          final posts = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ------------------------------------------------
              // USER INFORMATION
              // ------------------------------------------------

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall,
                      ),

                      const SizedBox(height: 8),

                      Text(user.email),

                      const SizedBox(height: 8),

                      Text(
                        user.age == null
                            ? 'Age: Unknown'
                            : 'Age: ${user.age}',
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'User ID: ${user.id}',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ------------------------------------------------
              // POSTS
              // ------------------------------------------------

              Text(
                'Posts (${posts.length})',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall,
              ),

              const SizedBox(height: 12),

              if (posts.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'This user has no posts.',
                    ),
                  ),
                ),

              ...posts.map(
                    (post) {
                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.article),
                      ),
                      title: Text(post.title),
                      subtitle: Text(
                        post.content,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}