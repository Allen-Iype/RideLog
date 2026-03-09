import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Database helper for managing local SQLite database
///
/// Manages:
/// - Database initialization
/// - Schema creation
/// - Migrations
/// - Database versioning
class DatabaseHelper {
  // Singleton pattern
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;
  static const String _databaseName = 'ridelog.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String tableRides = 'rides';
  static const String tableRoutePoints = 'route_points';

  /// Get database instance (creates if doesn't exist)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    // Get the application documents directory
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    print('Initializing database at: $path');

    // Open/create the database
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDatabase,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// Configure database (enable foreign keys)
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Create database schema
  Future<void> _createDatabase(Database db, int version) async {
    print('Creating database schema...');

    // Create rides table
    await db.execute('''
      CREATE TABLE $tableRides (
        id TEXT PRIMARY KEY,
        start_time INTEGER NOT NULL,
        end_time INTEGER NOT NULL,
        distance_meters REAL NOT NULL,
        duration_seconds INTEGER NOT NULL,
        avg_speed_kmh REAL NOT NULL,
        max_speed_kmh REAL NOT NULL,
        point_count INTEGER NOT NULL,
        synced INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL
      )
    ''');

    print('Created rides table');

    // Create route_points table
    await db.execute('''
      CREATE TABLE $tableRoutePoints (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ride_id TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        altitude REAL,
        speed REAL,
        heading REAL,
        accuracy REAL,
        timestamp INTEGER NOT NULL,
        sequence_number INTEGER NOT NULL,
        FOREIGN KEY (ride_id) REFERENCES $tableRides (id) ON DELETE CASCADE
      )
    ''');

    print('Created route_points table');

    // Create indices for better query performance
    await db.execute('''
      CREATE INDEX idx_rides_start_time ON $tableRides(start_time)
    ''');

    await db.execute('''
      CREATE INDEX idx_rides_synced ON $tableRides(synced)
    ''');

    await db.execute('''
      CREATE INDEX idx_route_points_ride_id ON $tableRoutePoints(ride_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_route_points_sequence ON $tableRoutePoints(ride_id, sequence_number)
    ''');

    print('Created indices');
    print('Database schema creation complete');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');

    // Future migrations will go here
    // Example:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE rides ADD COLUMN new_column TEXT');
    // }
  }

  /// Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Delete the database (for testing)
  Future<void> deleteDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    await close();
    await File(path).delete();
    print('Database deleted');
  }

  /// Get database path (for debugging)
  Future<String> getDatabasePath() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    return join(documentsDirectory.path, _databaseName);
  }
}
