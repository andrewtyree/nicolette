import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// DatabaseHelper class manages SQLite database operations for Nicolette
/// 
/// This singleton class handles:
/// - Database creation and initialization
/// - Schema management and migrations
/// - Database connection management
/// - Initial data setup
class DatabaseHelper {
  // Singleton pattern implementation
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // Database instance
  static Database? _database;

  // Database configuration
  static const String _databaseName = 'nicolette.db';
  static const int _databaseVersion = 1;

  /// Get database instance, creating it if it doesn't exist
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  /// Creates the database file and sets up all tables
  Future<Database> _initDatabase() async {
    // Get the documents directory for storing the database
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    // Open the database, creating it if it doesn't exist
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// Configure database settings
  /// Enables foreign key constraints for data integrity
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Create all database tables
  /// This method runs when the database is created for the first time
  Future<void> _onCreate(Database db, int version) async {
    // Create workers table - stores individual worker information
    await db.execute('''
      CREATE TABLE workers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        email TEXT UNIQUE,
        phone TEXT,
        employee_id TEXT UNIQUE,
        is_senior_worker INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        hire_date TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_workers_active ON workers(is_active)');
    await db.execute('CREATE INDEX idx_workers_senior ON workers(is_senior_worker)');

    // Insert some test data for development
    await _insertTestData(db);
  }

  /// Insert test data for development
  Future<void> _insertTestData(Database db) async {
    // Insert a few test workers
    await db.insert('workers', {
      'first_name': 'John',
      'last_name': 'Doe',
      'email': 'john.doe@example.com',
      'employee_id': 'EMP001',
      'is_senior_worker': 1,
      'is_active': 1,
    });

    await db.insert('workers', {
      'first_name': 'Jane',
      'last_name': 'Smith',
      'email': 'jane.smith@example.com',
      'employee_id': 'EMP002',
      'is_senior_worker': 0,
      'is_active': 1,
    });

    await db.insert('workers', {
      'first_name': 'Mike',
      'last_name': 'Johnson',
      'email': 'mike.johnson@example.com',
      'employee_id': 'EMP003',
      'is_senior_worker': 0,
      'is_active': 0,
    });
  }

  /// Handle database schema upgrades
  /// This method runs when the database version is incremented
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here when schema changes are needed
    // For now, we'll just recreate the database
    // In production, you'd want to preserve existing data
    
    if (oldVersion < newVersion) {
      // Drop and recreate tables
      await db.execute('DROP TABLE IF EXISTS workers');
      await _onCreate(db, newVersion);
    }
  }

  /// Close the database connection
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// Delete the entire database (useful for testing)
  Future<void> deleteDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    
    await close();
    
    File databaseFile = File(path);
    if (await databaseFile.exists()) {
      await databaseFile.delete();
    }
  }

  /// Get database path (useful for debugging)
  Future<String> getDatabasePath() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    return join(documentsDirectory.path, _databaseName);
  }
}