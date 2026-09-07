# Drift in Flutter

## 1. Introduction

Drift is a reactive persistence library for Flutter and Dart applications built on top of SQLite.

It allows Flutter applications to store structured relational data locally while providing:

* Type-safe queries
* Compile-time query checking
* Reactive streams
* SQL support
* Relationships
* Transactions
* Migrations
* Database testing
* Generated database APIs

The basic architecture is:

```text
Flutter
   ↓
Drift
   ↓
SQLite
   ↓
Local Database File
```

Drift is especially useful when an application needs more than simple key-value storage.

For example:

```text
Users
Posts
Comments
Messages
Orders
Products
Transactions
```

can all be represented using relational database tables.

---

# 2. Why Drift Exists

Flutter applications often need local persistence.

Simple data can be stored with:

```text
SharedPreferences
```

But larger applications need:

```text
Tables
Relationships
Queries
Indexes
Transactions
Pagination
Sorting
Searching
Reactive updates
```

Writing raw SQLite code everywhere can become difficult to maintain.

Drift provides a Dart-friendly abstraction over SQLite.

Instead of manually managing SQL strings everywhere, you can write:

```dart
database.select(database.users)
```

or:

```dart
database.into(database.users).insert(...)
```

and Drift generates strongly typed APIs.

---

# 3. When to Use Drift

Drift is a good choice when your Flutter application needs structured relational data.

Use Drift for:

### Offline-first applications

Example:

```text
Mobile App
   ↓
Local Drift Database
   ↓
API Synchronization
```

The application can continue working without internet access.

### Complex local data

For example:

```text
Users
Posts
Comments
Likes
```

with relationships between them.

### Large local datasets

For example:

```text
10,000+
100,000+
```

rows where querying the database is more appropriate than loading everything into memory.

### Search

Drift can perform database-level searches.

### Pagination

Use:

```text
LIMIT
OFFSET
```

instead of loading every row.

### Transactions

Multiple database operations can be executed atomically.

### Reactive UI

Drift's `watch()` APIs allow UI components to react automatically when database data changes.

---

# 4. When NOT to Use Drift

Do not automatically use Drift for every local-storage requirement.

### Simple settings

For data such as:

```text
theme = dark
language = en
notifications = true
```

SharedPreferences is usually simpler.

### Sensitive credentials

Do not store authentication secrets directly in an ordinary SQLite database.

Use secure storage mechanisms for secrets.

### Server database

Drift is primarily for local application persistence.

It is not a replacement for:

```text
PostgreSQL
MySQL
MongoDB
```

on your backend.

### Tiny applications

If the application only needs a few preferences, Drift can introduce unnecessary complexity.

---

# 5. Core Concepts

## Database

The database is the main Drift object.

Example:

```dart
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());
}
```

---

## Table

A table represents a database table.

Example:

```dart
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  TextColumn get email => text().unique()();
}
```

Conceptually:

```text
Users
--------------------------------
id | name | email
--------------------------------
1  | Ali  | ali@example.com
2  | Ahmad| ahmad@example.com
```

---

## Column

Columns define the data stored in a table.

Examples:

```dart
IntColumn
TextColumn
BoolColumn
DateTimeColumn
RealColumn
```

---

## Companion

Companion objects are used when inserting or updating data.

Example:

```dart
UsersCompanion.insert(
  name: 'Ali',
  email: 'ali@example.com',
)
```

---

## Insert

```dart
database.into(database.users).insert(
  UsersCompanion.insert(
    name: 'Ali',
    email: 'ali@example.com',
  ),
);
```

---

## Select

Get all users:

```dart
database.select(database.users).get();
```

Get one user:

```dart
(database.select(database.users)
      ..where((user) => user.id.equals(1)))
    .getSingleOrNull();
```

---

## Update

```dart
(database.update(database.users)
      ..where((user) => user.id.equals(1)))
    .write(
      const UsersCompanion(
        name: Value('Updated Name'),
      ),
    );
```

---

## Delete

```dart
(database.delete(database.users)
      ..where((user) => user.id.equals(1)))
    .go();
```

---

## Watch

Drift can expose database queries as streams.

```dart
database.select(database.users).watch();
```

This allows the UI to react when the database changes.

---

## Transactions

A transaction allows multiple database operations to succeed or fail together.

Conceptually:

```text
BEGIN TRANSACTION

Create User
Create Post
Create Profile

COMMIT
```

If something fails:

```text
ROLLBACK
```

This is extremely important for operations where partial data would be dangerous.

---

# 6. Flutter Implementation

The basic implementation requires:

```text
Drift
SQLite
Database Connection
Database Tables
Generated Code
Repository
UI
```

Typical flow:

```text
UI
 ↓
Repository
 ↓
Local Data Source
 ↓
Drift
 ↓
SQLite
```

The database connection is responsible for opening SQLite.

The database class defines tables.

The local data source executes database operations.

The repository hides the database implementation from the domain layer.

---

# 7. Clean Architecture Integration

A good structure is:

```text
presentation
      ↓
domain
      ↓
data
      ↓
Drift
      ↓
SQLite
```

Example:

```text
presentation/
    pages/

domain/
    entities/
    repositories/

data/
    local/
    repositories/

core/
    database/
```

### Presentation

Responsible for:

```text
UI
User interaction
State
```

### Domain

Responsible for:

```text
Entities
Repository contracts
Business rules
```

The domain layer should not depend on Drift.

### Data

Responsible for:

```text
Drift
SQLite
Data sources
Repository implementations
```

### Core

Responsible for database infrastructure:

```text
AppDatabase
Database connection
Database configuration
```

---

# 8. Real-World Example

Consider a social media application.

The database might contain:

```text
Users
Posts
Comments
Likes
```

Relationships:

```text
User
 ↓
Posts
 ↓
Comments
 ↓
Likes
```

Example:

```text
users
----------------
id
name
email


posts
----------------
id
user_id
title
content


comments
----------------
id
post_id
user_id
content
```

A user can have many posts.

A post can have many comments.

A user can write many comments.

This is exactly the type of structured data where SQLite + Drift becomes useful.

---

# 9. Common Mistakes

## Mistake 1 — Putting Drift directly in UI

Avoid:

```dart
onPressed: () {
  database.into(database.users).insert(...);
}
```

inside large production UI widgets.

Prefer:

```text
UI
 ↓
Repository
 ↓
Data Source
 ↓
Drift
```

---

## Mistake 2 — Loading everything

Avoid:

```dart
final users = await database.select(database.users).get();
```

when the table can contain hundreds of thousands of records and the UI only needs 20.

Use pagination.

---

## Mistake 3 — Ignoring indexes

Searches and joins can become slow as data grows.

Use indexes for frequently queried columns.

---

## Mistake 4 — No migrations

Changing:

```text
schemaVersion = 1
```

to:

```text
schemaVersion = 2
```

is not enough.

You must implement the migration.

---

## Mistake 5 — Storing secrets carelessly

SQLite data is not automatically equivalent to secure credential storage.

Sensitive secrets require additional protection.

---

## Mistake 6 — Not using transactions

Suppose you create:

```text
User
Post
Profile
```

and the third operation fails.

Without a transaction, the database might contain incomplete data.

Use transactions when operations must succeed together.

---

## Mistake 7 — Creating multiple database instances unnecessarily

Prefer managing the database lifecycle centrally.

For example:

```text
AppDatabase
    ↓
Repository
    ↓
Application
```

rather than creating a new database object for every screen.

---

# 10. Senior-Level Considerations

## Database indexes

Indexes can dramatically improve query performance.

For example, if the application frequently searches by email:

```text
email
```

should be considered for indexing.

But indexes also have a cost:

```text
More indexes
    ↓
Faster reads
    +
More storage
    +
Slower writes
```

Do not blindly index every column.

---

## Transactions

Transactions are important for multi-step operations.

Example:

```text
Create Order
 ↓
Create Order Items
 ↓
Update Product Stock
 ↓
Create Payment Record
```

These operations may need to succeed together.

---

## Pagination

Avoid loading huge datasets into memory.

Prefer:

```text
LIMIT
OFFSET
```

or other pagination strategies appropriate for the query.

---

## Reactive queries

Use:

```dart
watch()
```

when the UI should automatically react to database changes.

But do not create unnecessary streams everywhere.

Reactive queries should have a clear purpose.

---

## Database migrations

Production applications must treat schema changes carefully.

Example:

```text
Version 1
    ↓
Version 2
    ↓
Version 3
```

Each version may require a migration.

---

## Testing

Database logic should be tested independently.

In-memory databases are useful for testing because they are:

```text
Fast
Isolated
Disposable
```

---

## Generated code

Drift generates code from database definitions.

Never manually edit generated files such as:

```text
app_database.g.dart
```

Change the source definitions and regenerate.

---

## Query performance

Senior developers should think about:

```text
Query complexity
Indexes
Number of rows
JOIN cost
Memory usage
Pagination
Database locks
Transactions
```

A query that works perfectly with 100 rows may perform badly with 1,000,000 rows.

---

# 11. Demo Implementation

This project demonstrates:

### Create

```dart
await repository.createUser(
  name: 'Ali',
  email: 'ali@example.com',
  age: 25,
);
```

### Read

```dart
final user = await repository.getUserById(1);
```

### Read all

```dart
final users = await repository.getUsers();
```

### Search

```dart
final users = await repository.searchUsers('Ali');
```

### Update

```dart
await repository.updateUser(user);
```

### Delete

```dart
await repository.deleteUser(user.id);
```

### Pagination

```dart
await repository.getUsersPaginated(
  limit: 20,
  offset: 0,
);
```

### Reactive data

```dart
repository.watchUsers();
```

The demo UI uses a `StreamBuilder` to listen to the database.

Therefore:

```text
Create User
     ↓
SQLite changes
     ↓
Drift detects change
     ↓
Stream emits new data
     ↓
StreamBuilder rebuilds
     ↓
UI updates
```

No manual refresh is required.

---

# 12. Short Summary

Drift is a powerful SQLite persistence solution for Flutter.

The most important concepts are:

```text
Drift
 ↓
SQLite
```

and:

```text
Tables
Columns
Queries
Companions
Transactions
Streams
Migrations
Indexes
```

For Clean Architecture:

```text
Presentation
      ↓
Domain Repository
      ↓
Data Repository
      ↓
Local Data Source
      ↓
Drift
      ↓
SQLite
```

Use Drift when your application needs structured relational local data.

Use simpler storage such as SharedPreferences when you only need simple key-value settings.

For senior-level Flutter development, focus especially on:

```text
Transactions
Migrations
Indexes
Pagination
JOINs
Query performance
Reactive queries
Testing
Database lifecycle
Clean Architecture
```

The goal is not simply to know how to insert and retrieve a row.

The goal is to understand how to design a **reliable local database layer that can scale with the application**.
