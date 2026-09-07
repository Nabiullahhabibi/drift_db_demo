import 'package:flutter/material.dart';

import 'core/database/app_database.dart';
import 'data/local/drift_local_data_source.dart';
import 'data/local/post_local_data_source.dart';
import 'data/repositories/post_repository_impl.dart';
import 'data/repositories/user_repository_impl.dart';
import 'presentation/pages/drift_demo_page.dart';
import 'presentation/pages/posts_page.dart';
import 'presentation/pages/users_page.dart';

void main() {
  final database = AppDatabase();

  // ----------------------------------------------------------
  // USER DEPENDENCIES
  // ----------------------------------------------------------

  final userLocalDataSource = DriftLocalDataSource(
    database,
  );

  final userRepository = UserRepositoryImpl(
    userLocalDataSource,
  );

  // ----------------------------------------------------------
  // POST DEPENDENCIES
  // ----------------------------------------------------------

  final postLocalDataSource = PostLocalDataSource(
    database,
  );

  final postRepository = PostRepositoryImpl(
    postLocalDataSource,
  );

  runApp(
    DriftDemoApp(
      userRepository: userRepository,
      postRepository: postRepository,
      database: database,
    ),
  );
}

class DriftDemoApp extends StatelessWidget {
  final UserRepositoryImpl userRepository;
  final PostRepositoryImpl postRepository;
  final AppDatabase database;

  const DriftDemoApp({
    super.key,
    required this.userRepository,
    required this.postRepository,
    required this.database,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Drift Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: DriftHomePage(
        userRepository: userRepository,
        postRepository: postRepository,
      ),
    );
  }
}

class DriftHomePage extends StatelessWidget {
  final UserRepositoryImpl userRepository;
  final PostRepositoryImpl postRepository;

  const DriftHomePage({
    super.key,
    required this.userRepository,
    required this.postRepository,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drift Demo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 20),

          const Icon(
            Icons.storage,
            size: 80,
          ),

          const SizedBox(height: 16),

          Text(
            'Drift SQLite Demo',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          const SizedBox(height: 8),

          Text(
            'Explore Drift database features',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),

          const SizedBox(height: 32),

          // --------------------------------------------------
          // BASIC CRUD
          // --------------------------------------------------

          _DemoNavigationCard(
            icon: Icons.people,
            title: 'User CRUD',
            description:
            'Create, read, update, delete, search and paginate users.',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DriftDemoPage(
                    repository: userRepository,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // --------------------------------------------------
          // USERS
          // --------------------------------------------------

          _DemoNavigationCard(
            icon: Icons.person,
            title: 'Users',
            description:
            'View users and open their posts.',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => UsersPage(
                    repository: userRepository,
                    postRepository: postRepository,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // --------------------------------------------------
          // POSTS + JOIN
          // --------------------------------------------------

          _DemoNavigationCard(
            icon: Icons.article,
            title: 'Posts + Users JOIN',
            description:
            'View posts together with their users using Drift JOIN queries.',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PostsPage(
                    repository: postRepository,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // --------------------------------------------------
          // FEATURES
          // --------------------------------------------------

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Implemented Drift Features',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _FeatureItem(
                    text: 'SQLite database',
                  ),
                  _FeatureItem(
                    text: 'CRUD operations',
                  ),
                  _FeatureItem(
                    text: 'Search',
                  ),
                  _FeatureItem(
                    text: 'Pagination',
                  ),
                  _FeatureItem(
                    text: 'Users + Posts',
                  ),
                  _FeatureItem(
                    text: 'Foreign keys',
                  ),
                  _FeatureItem(
                    text: 'Cascade delete',
                  ),
                  _FeatureItem(
                    text: 'JOIN queries',
                  ),
                  _FeatureItem(
                    text: 'Reactive queries',
                  ),
                  _FeatureItem(
                    text: 'Database migrations',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoNavigationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _DemoNavigationCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(description),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String text;

  const _FeatureItem({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}