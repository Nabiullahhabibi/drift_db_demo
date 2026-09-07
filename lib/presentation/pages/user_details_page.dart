import 'package:flutter/material.dart';

import '../../domain/entities/post.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/post_repository.dart';

class UserDetailsPage extends StatefulWidget {
  final User user;
  final PostRepository postRepository;

  const UserDetailsPage({
    super.key,
    required this.user,
    required this.postRepository,
  });

  @override
  State<UserDetailsPage> createState() =>
      _UserDetailsPageState();
}

class _UserDetailsPageState
    extends State<UserDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.name),
      ),
      body: StreamBuilder<List<Post>>(
        stream: widget.postRepository.watchPosts(),
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

          final allPosts = snapshot.data ?? [];

          final posts = allPosts
              .where(
                (post) => post.userId == widget.user.id,
          )
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user.name,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(widget.user.email),
                      const SizedBox(height: 8),
                      Text(
                        widget.user.age == null
                            ? 'Age: Not provided'
                            : 'Age: ${widget.user.age}',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

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
                    (post) => Card(
                  margin: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: ListTile(
                    title: Text(post.title),
                    subtitle: Text(
                      post.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}