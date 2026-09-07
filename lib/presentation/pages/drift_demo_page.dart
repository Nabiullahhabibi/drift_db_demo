import 'package:flutter/material.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

class DriftDemoPage extends StatefulWidget {
  final UserRepository repository;

  const DriftDemoPage({
    super.key,
    required this.repository,
  });

  @override
  State<DriftDemoPage> createState() => _DriftDemoPageState();
}

class _DriftDemoPageState extends State<DriftDemoPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  int currentPage = 0;
  final int pageSize = 5;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    ageController.dispose();
    searchController.dispose();

    super.dispose();
  }

  Future<void> createUser() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final ageText = ageController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      showMessage('Name and email are required.');
      return;
    }

    final age = int.tryParse(ageText);

    try {
      await widget.repository.createUser(
        name: name,
        email: email,
        age: age,
      );

      nameController.clear();
      emailController.clear();
      ageController.clear();

      showMessage('User created successfully.');
    } catch (e) {
      showMessage('Error: $e');
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await widget.repository.deleteUser(id);

      showMessage('User deleted.');
    } catch (e) {
      showMessage('Error: $e');
    }
  }

  Future<void> editUser(User user) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return _EditUserDialog(
          user: user,
          repository: widget.repository,
        );
      },
    );

    if (!mounted) return;

    if (result == true) {
      showMessage('User updated.');
    }
  }

  Future<void> searchUsers() async {
    final query = searchController.text.trim();

    if (query.isEmpty) {
      setState(() {});
      return;
    }

    final users = await widget.repository.searchUsers(query);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];

            return ListTile(
              leading: CircleAvatar(
                child: Text(user.name[0].toUpperCase()),
              ),
              title: Text(user.name),
              subtitle: Text(user.email),
            );
          },
        );
      },
    );
  }

  Future<void> loadNextPage() async {
    final nextPage = currentPage + 1;

    final users = await widget.repository.getUsersPaginated(
      limit: pageSize,
      offset: nextPage * pageSize,
    );

    if (!mounted) return;

    if (users.isEmpty) {
      showMessage('No more users.');
      return;
    }

    setState(() {
      currentPage = nextPage;
    });
  }

  Future<void> loadPreviousPage() async {
    if (currentPage == 0) {
      showMessage('Already on first page.');
      return;
    }

    setState(() {
      currentPage--;
    });
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drift Demo'),
      ),
      body: StreamBuilder<List<User>>(
        stream: widget.repository.watchUsers(),
        builder: (context, snapshot) {
          final users = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Create User',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: createUser,
                child: const Text('Create User'),
              ),

              const SizedBox(height: 24),

              const Text(
                'Search Users',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search name or email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: searchUsers,
                    icon: const Icon(Icons.search),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Users',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Page ${currentPage + 1}',
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (users.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(
                    child: Text('No users found.'),
                  ),
                ),

              ...users.map(
                    (user) {
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          user.name[0].toUpperCase(),
                        ),
                      ),
                      title: Text(user.name),
                      subtitle: Text(
                        '${user.email}\nAge: ${user.age ?? 'Unknown'}',
                      ),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            editUser(user);
                          }

                          if (value == 'delete') {
                            deleteUser(user.id);
                          }
                        },
                        itemBuilder: (context) {
                          return const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ];
                        },
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: loadPreviousPage,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    onPressed: loadNextPage,
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EditUserDialog extends StatefulWidget {
  final User user;
  final UserRepository repository;

  const _EditUserDialog({
    required this.user,
    required this.repository,
  });

  @override
  State<_EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<_EditUserDialog> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController ageController;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.user.name,
    );

    emailController = TextEditingController(
      text: widget.user.email,
    );

    ageController = TextEditingController(
      text: widget.user.age?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    ageController.dispose();

    super.dispose();
  }

  Future<void> updateUser() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final age = int.tryParse(ageController.text.trim());

    if (name.isEmpty || email.isEmpty) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final updatedUser = User(
        id: widget.user.id,
        name: name,
        email: email,
        age: age,
        createdAt: widget.user.createdAt,
      );

      final success = await widget.repository.updateUser(
        updatedUser,
      );

      if (!mounted) return;

      Navigator.of(context).pop(success);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update user: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit User'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            enabled: !isSaving,
            decoration: const InputDecoration(
              labelText: 'Name',
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: emailController,
            enabled: !isSaving,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: ageController,
            enabled: !isSaving,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Age',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isSaving
              ? null
              : () {
            Navigator.of(context).pop(false);
          },
          child: const Text('Cancel'),
        ),

        ElevatedButton(
          onPressed: isSaving ? null : updateUser,
          child: isSaving
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
              : const Text('Update'),
        ),
      ],
    );
  }
}