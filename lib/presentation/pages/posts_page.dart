import 'package:flutter/material.dart';

import '../../domain/entities/post_with_user.dart';
import '../../domain/repositories/post_repository.dart';

class PostsPage extends StatefulWidget {
  final PostRepository repository;

  const PostsPage({
    super.key,
    required this.repository,
  });

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  final searchController = TextEditingController();

  int currentPage = 1;
  final int pageSize = 5;

  bool isSearching = false;
  List<PostWithUser> searchResults = [];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> searchPosts() async {
    final query = searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        isSearching = false;
        searchResults = [];
      });

      return;
    }

    setState(() {
      isSearching = true;
    });

    try {
      final posts = await widget.repository.searchPosts(query);

      final results = <PostWithUser>[];

      for (final post in posts) {
        final joinedPosts =
        await widget.repository.getPostsWithUsers();

        final match = joinedPosts.where(
              (item) => item.post.id == post.id,
        );

        if (match.isNotEmpty) {
          results.add(match.first);
        }
      }

      if (!mounted) return;

      setState(() {
        searchResults = results;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Search failed: $e'),
        ),
      );
    }
  }

  Future<void> loadNextPage() async {
    final posts = await widget.repository.getPostsWithUsersPaginated(
      limit: pageSize,
      offset: currentPage * pageSize,
    );

    if (posts.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No more posts.'),
        ),
      );

      return;
    }

    if (!mounted) return;

    setState(() {
      currentPage++;
    });
  }

  void loadPreviousPage() {
    if (currentPage <= 1) {
      return;
    }

    setState(() {
      currentPage--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts + Users JOIN'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onSubmitted: (_) => searchPosts(),
              decoration: InputDecoration(
                labelText: 'Search posts',
                hintText: 'Search by title or content',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: searchPosts,
                  icon: const Icon(Icons.search),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),

          Expanded(
            child: isSearching
                ? _buildSearchResults()
                : _buildPosts(),
          ),

          if (!isSearching)
            _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildPosts() {
    return StreamBuilder<List<PostWithUser>>(
      stream: widget.repository.watchPostsWithUsers(),
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
            ),
          );
        }

        final posts = snapshot.data ?? [];

        if (posts.isEmpty) {
          return const Center(
            child: Text('No posts found.'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: posts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            return _PostCard(
              item: posts[index],
            );
          },
        );
      },
    );
  }

  Widget _buildSearchResults() {
    if (searchResults.isEmpty) {
      return const Center(
        child: Text('No matching posts found.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: searchResults.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _PostCard(
          item: searchResults[index],
        );
      },
    );
  }

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: currentPage > 1
                ? loadPreviousPage
                : null,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Previous'),
          ),
          const SizedBox(width: 16),
          Text(
            'Page $currentPage',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: loadNextPage,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Next'),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final PostWithUser item;

  const _PostCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.post.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(item.post.content),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.person,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  item.user.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'User #${item.user.id}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}