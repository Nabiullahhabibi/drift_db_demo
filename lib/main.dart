import 'package:flutter/material.dart';

import 'core/database/app_database.dart';
import 'data/local/drift_local_data_source.dart';
import 'data/repositories/user_repository_impl.dart';
import 'presentation/pages/drift_demo_page.dart';

void main() {
  final database = AppDatabase();

  final localDataSource = DriftLocalDataSource(
    database,
  );

  final repository = UserRepositoryImpl(
    localDataSource,
  );

  runApp(
    DriftDemoApp(
      repository: repository,
      database: database,
    ),
  );
}

class DriftDemoApp extends StatelessWidget {
  final UserRepositoryImpl repository;
  final AppDatabase database;

  const DriftDemoApp({
    super.key,
    required this.repository,
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
      home: DriftDemoPage(
        repository: repository,
      ),
    );
  }
}