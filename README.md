# Drift SQLite Demo

A practical Flutter project demonstrating how to use **Drift** as a type-safe SQLite persistence layer.

This project goes beyond basic CRUD and demonstrates real-world database concepts such as:

* SQLite database integration
* Type-safe queries with Drift
* CRUD operations
* Search
* Real pagination
* Reactive queries with Streams
* Users and Posts relationships
* Foreign keys
* Cascade delete
* SQL JOIN queries
* JOIN pagination
* Repository pattern
* Local data source abstraction
* Domain entities
* Database migrations
* In-memory database testing
* Transaction-ready architecture
* Database integration testing

The project is structured using a lightweight **Clean Architecture-inspired approach** to keep database concerns separated from business/domain concerns.

---

## 📚 Table of Contents

* [Overview](#-overview)
* [Why Drift](#-why-drift)
* [Features](#-features)
* [Architecture](#-architecture)
* [Project Structure](#-project-structure)
* [Database Schema](#-database-schema)
* [Users](#-users)
* [Posts](#-posts)
* [Relationships](#-relationships)
* [JOIN Queries](#-join-queries)
* [Pagination](#-pagination)
* [Reactive Queries](#-reactive-queries)
* [CRUD Operations](#-crud-operations)
* [Foreign Keys and Cascade Delete](#-foreign-keys-and-cascade-delete)
* [Database Migrations](#-database-migrations)
* [Testing](#-testing)
* [Code Generation](#-code-generation)
* [Installation](#-installation)
* [Running the Project](#-running-the-project)
* [Learning Goals](#-learning-goals)
* [Future Improvements](#-future-improvements)
* [Useful Commands](#-useful-commands)
* [Conclusion](#-conclusion)

---

# 🚀 Overview

Drift is a reactive persistence library for Dart and Flutter built on top of SQLite.

Instead of writing raw SQL for every operation, Drift provides:

* Type-safe tables
* Type-safe queries
* Generated Dart database classes
* Reactive streams
* JOIN support
* Transactions
* Migrations
* Custom SQL
* Testing support

This project demonstrates how Drift can be integrated into a Flutter application using a maintainable architecture.

---

# 🤔 Why Drift?

SQLite is an excellent choice for structured local data.

However, working directly with SQLite can become difficult as the application grows.

For example:

```text
Raw SQLite
    ↓
SQL strings
    ↓
Manual mapping
    ↓
Manual error handling
    ↓
Manual query management
```

Drift improves this workflow:

```text
Flutter
   ↓
Repository
   ↓
Local Data Source
   ↓
Drift
   ↓
SQLite
```

Drift provides compile-time type safety while still allowing access to SQL when needed.

---

# ✨ Features

## Database

* SQLite database
* Drift ORM/query builder
* Type-safe queries
* Background database connection
* Foreign key support

## User Management

* Create users
* Read users
* Update users
* Delete users
* Search users
* Paginate users
* Reactive user queries

## Post Management

* Create posts
* Read posts
* Update posts
* Delete posts
* Search posts
* Paginate posts
* Filter posts by user
* Reactive post queries

## Relationships

```text
User
 │
 ├── Post
 ├── Post
 └── Post
```

Implemented using:

```text
Users 1 ─────────── * Posts
```

## Advanced Database Features

* INNER JOIN
* LEFT OUTER JOIN
* JOIN pagination
* Foreign keys
* Cascade delete
* Reactive JOIN queries
* Database migrations
* In-memory testing

---

# 🏗 Architecture

The project follows a simplified Clean Architecture structure.

```text
Presentation
     ↓
Domain
     ↓
Data
     ↓
Drift
     ↓
SQLite
```

### Presentation

Responsible for:

* UI
* User interaction
* Navigation
* Loading states
* Error states

### Domain

Contains:

* Entities
* Repository contracts

The domain does not depend directly on Drift.

### Data

Contains:

* Repository implementations
* Local data sources
* Drift-specific database operations

### Core

Contains:

* Database configuration
* Database connection
* Drift database definition
* Generated database code

---

# 📁 Project Structure

```text
drift_demo/
│
├── docs/
│   └── drift.md
│
├── lib/
│   │
│   ├── core/
│   │   └── database/
│   │       ├── app_database.dart
│   │       ├── app_database.g.dart
│   │       └── database_connection.dart
│   │
│   ├── data/
│   │   │
│   │   ├── local/
│   │   │   ├── drift_local_data_source.dart
│   │   │   ├── post_local_data_source.dart
│   │   │   └── user_with_posts_local_data_source.dart
│   │   │
│   │   └── repositories/
│   │       ├── user_repository_impl.dart
│   │       └── post_repository_impl.dart
│   │
│   ├── domain/
│   │   │
│   │   ├── entities/
│   │   │   ├── user.dart
│   │   │   ├── post.dart
│   │   │   ├── user_with_posts.dart
│   │   │   └── post_with_user.dart
│   │   │
│   │   └── repositories/
│   │       ├── user_repository.dart
│   │       └── post_repository.dart
│   │
│   ├── presentation/
│   │   └── pages/
│   │       ├── drift_demo_page.dart
│   │       ├── users_page.dart
│   │       ├── user_details_page.dart
│   │       └── posts_page.dart
│   │
│   └── main.dart
│
├── test/
│   ├── database_test.dart
│   ├── relationship_test.dart
│   ├── post_pagination_test.dart
│   └── reactive_query_test.dart
│
├── pubspec.yaml
└── README.md
```

---

# 🗄 Database Schema

The application currently contains two main tables.

## Users

```text
Users
--------------------------------
id          INTEGER PRIMARY KEY
name        TEXT
email       TEXT UNIQUE
age         INTEGER NULL
createdAt   DATETIME
```

## Posts

```text
Posts
--------------------------------
id          INTEGER PRIMARY KEY
userId      INTEGER
title       TEXT
content     TEXT
createdAt   DATETIME
```

The relationship is:

```text
Users
  │
  │ 1
  │
  │
  │ *
Posts
```

Each post belongs to one user.

A user can have many posts.

---

# 👤 Users

The user feature demonstrates standard CRUD operations.

## Create

```dart
await repository.createUser(
  name: 'John',
  email: 'john@example.com',
  age: 25,
);
```

## Read

```dart
final user = await repository.getUserById(id);
```

## Read All

```dart
final users = await repository.getUsers();
```

## Update

```dart
await repository.updateUser(
  user,
);
```

## Delete

```dart
await repository.deleteUser(id);
```

## Search

```dart
final users = await repository.searchUsers(
  'john',
);
```

---

# 📝 Posts

Posts belong to users through `userId`.

Example:

```text
User
id = 1
name = John

Post
id = 10
userId = 1
title = My First Post
```

The post references the user through:

```text
posts.userId → users.id
```

---

# 🔗 Relationships

The database uses a one-to-many relationship:

```text
User
 ├── Post 1
 ├── Post 2
 └── Post 3
```

This allows the application to:

* Find all posts for a user
* Display a user with their posts
* Display posts together with their users
* Delete a user and automatically delete their posts

---

# 🔍 JOIN Queries

Drift supports SQL JOIN operations.

For example, posts can be joined with users:

```dart
final query = database.select(
  database.posts,
).join([
  innerJoin(
    database.users,
    database.users.id.equalsExp(
      database.posts.userId,
    ),
  ),
]);
```

This produces the equivalent SQL concept:

```sql
SELECT *
FROM posts
INNER JOIN users
ON users.id = posts.user_id;
```

The result can then be mapped into:

```dart
PostWithUser
```

This is useful when the UI needs:

```text
Post
+
User information
```

without making a separate database query for every post.

---

# ⚡ Avoiding N+1 Queries

A common database performance problem is the **N+1 query problem**.

Bad approach:

```text
Get 20 posts
     ↓
Query user for post 1
Query user for post 2
Query user for post 3
...
Query user for post 20
```

This can result in:

```text
1 + 20 = 21 database queries
```

A JOIN can retrieve the required information in one database query:

```text
Posts
   +
Users
   ↓
One JOIN query
```

This project demonstrates JOIN-based data retrieval to avoid unnecessary database calls.

---

# 📄 Pagination

Pagination is implemented using SQLite's:

```sql
LIMIT
OFFSET
```

For example:

```dart
await repository.getUsersPaginated(
  limit: 5,
  offset: 10,
);
```

This means:

```text
limit  = 5
offset = 10
```

The database returns:

```text
User 11
User 12
User 13
User 14
User 15
```

The UI keeps track of:

```dart
currentPage
pageSize
```

and calculates:

```text
offset = currentPage × pageSize
```

This prevents the application from loading the entire table into memory.

---

# 🔄 Reactive Queries

One of Drift's most useful features is reactive queries.

Example:

```dart
Stream<List<User>> watchUsers() {
  return database
      .select(database.users)
      .watch();
}
```

The UI can subscribe using:

```dart
StreamBuilder<List<User>>(
  stream: repository.watchUsers(),
  builder: ...
)
```

When the database changes:

```text
INSERT
UPDATE
DELETE
```

Drift can automatically notify the stream.

The UI can therefore react to database changes without manually refreshing the entire screen.

---

# ✏️ CRUD Operations

The project demonstrates the complete CRUD lifecycle.

```text
CREATE
  ↓
READ
  ↓
UPDATE
  ↓
DELETE
```

### Create

```dart
database.into(database.users).insert(
  UsersCompanion.insert(
    name: name,
    email: email,
  ),
);
```

### Read

```dart
database.select(
  database.users,
).get();
```

### Update

```dart
database.update(
  database.users,
)
```

### Delete

```dart
database.delete(
  database.users,
)
```

---

# 🔐 Foreign Keys and Cascade Delete

The `Posts` table uses a foreign key:

```dart
IntColumn get userId => integer().references(
  Users,
  #id,
  onDelete: KeyAction.cascade,
)();
```

This means:

```text
User
  ↓
Delete User
  ↓
Database automatically deletes
that user's posts
```

For example:

```text
User 1
 ├── Post 1
 ├── Post 2
 └── Post 3
```

After:

```sql
DELETE FROM users WHERE id = 1;
```

the posts are also removed.

The database connection enables foreign keys using:

```sql
PRAGMA foreign_keys = ON;
```

This is important because SQLite foreign-key enforcement should be explicitly enabled for the connection.

---

# 🔄 Database Migrations

Database schemas change as applications evolve.

The project uses:

```dart
@override
int get schemaVersion => 2;
```

Version 1 contained:

```text
Users
```

Version 2 added:

```text
Posts
```

The migration handles this:

```dart
if (from < 2) {
  await m.createTable(posts);
}
```

The general migration process is:

```text
Version 1
   ↓
Schema change
   ↓
Version 2
   ↓
Migration
   ↓
Existing database preserved
```

This is essential in production applications because users already have databases on their devices.

---

# 🧪 Testing

The project includes database tests using an in-memory SQLite database.

Example:

```dart
final executor = NativeDatabase.memory();

final database = AppDatabase.forTesting(
  executor,
);
```

This provides a fast isolated database for tests.

## Current Test Areas

### User CRUD

Tests:

* Insert
* Read
* Update
* Delete
* Search

### Relationships

Tests:

* User/Post relationship
* JOIN queries
* Users with posts

### Pagination

Tests:

* LIMIT
* OFFSET
* Multiple pages

### Reactive Queries

Tests:

* Stream creation
* Database changes
* Reactive updates

---

# 🏭 Production Database

The application uses:

```dart
NativeDatabase.createInBackground(file)
```

The database is stored inside the application's documents directory.

Example:

```text
Application Documents
        │
        └── drift_demo.sqlite
```

Using `LazyDatabase` means the database is opened lazily instead of immediately during application startup.

---

# ⚙️ Code Generation

Drift generates Dart code based on the database definition.

The generated file is:

```text
app_database.g.dart
```

You should not manually edit this file.

Generate it with:

```bash
dart run build_runner build --delete-conflicting-outputs
```

During development, you can use:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

Whenever you modify:

```text
app_database.dart
```

regenerate the generated code.

---

# 📦 Dependencies

Main dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter

  drift: ^2.28.1
  sqlite3_flutter_libs: ^0.5.39
  path_provider: ^2.1.5
  path: ^1.9.1
```

Development dependencies:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter

  flutter_lints: ^5.0.0
  drift_dev: ^2.28.1
  build_runner: ^2.4.15
```

---

# 🛠 Installation

Clone the repository:

```bash
git clone <your-repository-url>
```

Move into the project:

```bash
cd drift_demo
```

Install Flutter dependencies:

```bash
flutter pub get
```

Generate Drift code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

# ▶️ Running the Project

Run the application:

```bash
flutter run
```

Run tests:

```bash
flutter test
```

---

# 🧭 Application Navigation

The application contains several demonstrations.

```text
Drift Demo
│
├── User CRUD
│   ├── Create
│   ├── Read
│   ├── Update
│   ├── Delete
│   ├── Search
│   └── Pagination
│
├── Users
│   │
│   └── User Details
│       └── User Posts
│
└── Posts + Users JOIN
    ├── JOIN
    ├── Search
    ├── Pagination
    └── Reactive queries
```

---

# 🧠 Learning Goals

This project was created to understand Drift beyond simple database CRUD.

The main learning objectives are:

### Beginner

* Understand SQLite
* Create tables
* Insert data
* Read data
* Update data
* Delete data

### Intermediate

* Repository pattern
* Data source abstraction
* Search
* Pagination
* Streams
* Relationships
* Foreign keys

### Advanced

* JOIN queries
* JOIN pagination
* Reactive JOIN queries
* Database migrations
* In-memory database testing
* Query performance
* N+1 query prevention
* Transaction design

---

# 🚧 Future Improvements

The project can be extended with additional production-level features.

## Transactions

For example:

```text
Create User
     +
Create First Post
     ↓
Transaction
```

If the post creation fails:

```text
Rollback
```

so neither record remains in the database.

---

## Indexes

Add indexes for frequently queried columns:

```text
Posts.userId
Posts.createdAt
Users.email
```

This becomes increasingly important as the database grows.

---

## Full-Text Search

SQLite FTS can be introduced for more advanced searching:

```text
FTS5
```

This is more suitable than simple:

```sql
LIKE '%query%'
```

for large text datasets.

---

## Offline-First Architecture

The project can eventually evolve into:

```text
UI
 ↓
Repository
 ↓
Local Database
 ↓
Network API
 ↓
Synchronization
```

This would allow the application to work even without an internet connection.

---

## Conflict Resolution

For offline-first applications, synchronization can be extended with:

```text
Local changes
      ↓
Sync queue
      ↓
Server
      ↓
Conflict detection
      ↓
Conflict resolution
```

---

# 🧰 Useful Commands

## Install dependencies

```bash
flutter pub get
```

## Generate Drift code

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Watch generated files

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Run tests

```bash
flutter test
```

## Analyze project

```bash
flutter analyze
```

## Format code

```bash
dart format lib test
```

## Run the application

```bash
flutter run
```

---

# 📚 Recommended Learning Order

If you are studying Drift, I recommend learning the concepts in this order:

```text
1. SQLite fundamentals
        ↓
2. Drift tables
        ↓
3. CRUD
        ↓
4. Queries
        ↓
5. Filtering & Search
        ↓
6. Pagination
        ↓
7. Relationships
        ↓
8. JOINs
        ↓
9. Reactive queries
        ↓
10. Transactions
        ↓
11. Migrations
        ↓
12. Indexes & performance
        ↓
13. Testing
        ↓
14. Offline-first architecture
```

---

# 🏆 What This Project Demonstrates

This is not only a CRUD demo.

It demonstrates how a Flutter application can use Drift as a real local persistence layer:

```text
                 Flutter UI
                     │
                     ▼
              Repository API
                     │
                     ▼
             Repository Impl
                     │
                     ▼
             Local Data Source
                     │
                     ▼
                   Drift
                     │
                     ▼
                  SQLite
```

The architecture keeps the database implementation isolated from the domain layer and makes the database easier to test and evolve.

---

# 📌 Key Takeaways

After completing this project, you should understand:

* What Drift is
* Why Drift can be preferable to raw SQLite in Dart applications
* How Drift generates database code
* How to define tables
* How to perform CRUD operations
* How to build type-safe queries
* How to search local data
* How to implement pagination
* How to create relationships
* How to use foreign keys
* How cascade deletion works
* How to perform JOIN queries
* How to avoid N+1 queries
* How reactive queries work
* How database migrations work
* How to test Drift databases
* How to separate database code from domain logic

---

# 👨‍💻 Author

**Habibi**

Flutter Developer focused on building production-quality Flutter applications and mastering local persistence, architecture, performance, and offline-first development.

---

# ⭐ Support

If this project helped you understand Drift and SQLite in Flutter, consider giving the repository a ⭐ on GitHub.

---

# 📄 License

This project is available for educational and learning purposes.
