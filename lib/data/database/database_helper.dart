import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/password_model.dart';
import '../models/subfolder_model.dart';

/// Database helper class for managing encrypted SQLite operations.
///
/// Uses SQLCipher for database encryption and singleton pattern
/// to ensure single database instance.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // Encryption key for SQLCipher
  // In production, this should be stored securely (e.g., flutter_secure_storage)
  static const String _encryptionKey = 'your_secure_password_key_here';

  DatabaseHelper._init();

  /// Initialize FFI for desktop platforms
  static void initializeFfi() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  /// Gets the database instance, creating it if necessary.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('passwords_encrypted.db');
    return _database!;
  }

  /// Initializes the encrypted database with the passwords and subfolders tables.
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Open database with encryption
    final db = await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onConfigure: (db) async {
        // Enable SQLCipher encryption with the key
        await db.execute("PRAGMA key = '$_encryptionKey'");
      },
    );

    return db;
  }

  /// Creates the database tables.
  Future<void> _createDB(Database db, int version) async {
    // Subfolders table
    await db.execute('''
      CREATE TABLE subfolders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL
      )
    ''');

    // Passwords table
    await db.execute('''
      CREATE TABLE passwords (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        account_name TEXT NOT NULL,
        email TEXT,
        username TEXT,
        password TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        category TEXT NOT NULL,
        subfolder_id INTEGER,
        FOREIGN KEY (subfolder_id) REFERENCES subfolders(id) ON DELETE SET NULL
      )
    ''');

    debugPrint('Database tables created successfully');
  }

  /// Handles database upgrades.
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Drop old tables and recreate
      await db.execute('DROP TABLE IF EXISTS passwords');
      await db.execute('DROP TABLE IF EXISTS subfolders');
      await _createDB(db, newVersion);
    }
  }

  // ==================== SUBFOLDER OPERATIONS ====================

  /// Inserts a new subfolder.
  Future<int> insertSubfolder(SubfolderModel subfolder) async {
    final db = await database;
    return await db.insert('subfolders', subfolder.toMap());
  }

  /// Gets all subfolders for a category.
  Future<List<SubfolderModel>> getSubfoldersByCategory(String category) async {
    final db = await database;
    final result = await db.query(
      'subfolders',
      where: 'category = ?',
      whereArgs: [category],
    );
    return result.map((map) => SubfolderModel.fromMap(map)).toList();
  }

  /// Gets a subfolder by ID.
  Future<SubfolderModel?> getSubfolderById(int id) async {
    final db = await database;
    final result = await db.query(
      'subfolders',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return SubfolderModel.fromMap(result.first);
  }

  /// Updates a subfolder.
  Future<int> updateSubfolder(SubfolderModel subfolder) async {
    final db = await database;
    return await db.update(
      'subfolders',
      subfolder.toMap(),
      where: 'id = ?',
      whereArgs: [subfolder.id],
    );
  }

  /// Deletes a subfolder.
  Future<int> deleteSubfolder(int id) async {
    final db = await database;
    return await db.delete('subfolders', where: 'id = ?', whereArgs: [id]);
  }

  /// Gets the count of accounts in a subfolder.
  Future<int> getSubfolderAccountCount(int subfolderId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM passwords WHERE subfolder_id = ?',
      [subfolderId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ==================== PASSWORD OPERATIONS ====================

  /// Inserts a new password entry.
  Future<int> insertPassword(PasswordModel password) async {
    final db = await database;
    return await db.insert('passwords', password.toMap());
  }

  /// Gets all passwords.
  Future<List<PasswordModel>> getAllPasswords() async {
    final db = await database;
    final result = await db.query('passwords');
    return result.map((map) => PasswordModel.fromMap(map)).toList();
  }

  /// Gets passwords filtered by category (without subfolder).
  Future<List<PasswordModel>> getPasswordsByCategory(String category) async {
    final db = await database;
    final result = await db.query(
      'passwords',
      where: 'category = ? AND subfolder_id IS NULL',
      whereArgs: [category],
    );
    return result.map((map) => PasswordModel.fromMap(map)).toList();
  }

  /// Gets passwords in a specific subfolder.
  Future<List<PasswordModel>> getPasswordsBySubfolder(int subfolderId) async {
    final db = await database;
    final result = await db.query(
      'passwords',
      where: 'subfolder_id = ?',
      whereArgs: [subfolderId],
    );
    return result.map((map) => PasswordModel.fromMap(map)).toList();
  }

  /// Gets the count of passwords per category.
  Future<Map<String, int>> getCategoryCounts() async {
    final db = await database;
    final counts = <String, int>{};

    for (final category in PasswordModel.categories) {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM passwords WHERE category = ?',
        [category],
      );
      counts[category] = Sqflite.firstIntValue(result) ?? 0;
    }

    return counts;
  }

  /// Updates an existing password entry.
  Future<int> updatePassword(PasswordModel password) async {
    final db = await database;
    return await db.update(
      'passwords',
      password.toMap(),
      where: 'id = ?',
      whereArgs: [password.id],
    );
  }

  /// Deletes a password entry.
  Future<int> deletePassword(int id) async {
    final db = await database;
    return await db.delete('passwords', where: 'id = ?', whereArgs: [id]);
  }

  /// Closes the database connection.
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Resets the database (for development/testing).
  Future<void> resetDatabase() async {
    final db = await database;
    await db.execute('DROP TABLE IF EXISTS passwords');
    await db.execute('DROP TABLE IF EXISTS subfolders');
    await _createDB(db, 2);
  }
}
