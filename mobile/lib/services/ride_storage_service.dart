import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/ride.dart';
import '../models/route_point.dart';

/// Service for managing local ride storage
///
/// Provides CRUD operations for:
/// - Saving rides with GPS points
/// - Retrieving rides (all, by ID, filtered)
/// - Deleting rides
/// - Updating sync status
class RideStorageService {
  // Singleton pattern
  RideStorageService._();
  static final RideStorageService instance = RideStorageService._();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Save a ride with all its route points
  ///
  /// Returns the ride ID
  Future<String> saveRide(Ride ride) async {
    final db = await _dbHelper.database;

    try {
      await db.transaction((txn) async {
        // Insert ride metadata
        await txn.insert(
          DatabaseHelper.tableRides,
          ride.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        print('Saved ride: ${ride.id}');

        // Insert all route points
        for (final point in ride.routePoints) {
          await txn.insert(
            DatabaseHelper.tableRoutePoints,
            point.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        print('Saved ${ride.routePoints.length} route points for ride ${ride.id}');
      });

      return ride.id;
    } catch (e) {
      print('Error saving ride: $e');
      rethrow;
    }
  }

  /// Get a single ride by ID (with route points)
  Future<Ride?> getRideById(String id) async {
    final db = await _dbHelper.database;

    try {
      // Get ride metadata
      final List<Map<String, dynamic>> rideMaps = await db.query(
        DatabaseHelper.tableRides,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rideMaps.isEmpty) {
        return null;
      }

      // Get route points
      final List<Map<String, dynamic>> pointMaps = await db.query(
        DatabaseHelper.tableRoutePoints,
        where: 'ride_id = ?',
        whereArgs: [id],
        orderBy: 'sequence_number ASC',
      );

      final routePoints =
          pointMaps.map((map) => RoutePoint.fromMap(map)).toList();

      return Ride.fromMap(rideMaps.first, routePoints: routePoints);
    } catch (e) {
      print('Error getting ride by ID: $e');
      return null;
    }
  }

  /// Get all rides (without route points for performance)
  ///
  /// Route points are loaded only when needed (e.g., viewing ride details)
  Future<List<Ride>> getAllRides({bool includeSynced = true}) async {
    final db = await _dbHelper.database;

    try {
      String? where;
      List<dynamic>? whereArgs;

      if (!includeSynced) {
        where = 'synced = ?';
        whereArgs = [0];
      }

      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableRides,
        where: where,
        whereArgs: whereArgs,
        orderBy: 'start_time DESC', // Most recent first
      );

      return maps.map((map) => Ride.fromMap(map)).toList();
    } catch (e) {
      print('Error getting all rides: $e');
      return [];
    }
  }

  /// Get rides that haven't been synced to the server
  Future<List<Ride>> getUnsyncedRides() async {
    return getAllRides(includeSynced: false);
  }

  /// Get rides within a date range
  Future<List<Ride>> getRidesByDateRange(DateTime start, DateTime end) async {
    final db = await _dbHelper.database;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableRides,
        where: 'start_time >= ? AND start_time <= ?',
        whereArgs: [
          start.millisecondsSinceEpoch,
          end.millisecondsSinceEpoch,
        ],
        orderBy: 'start_time DESC',
      );

      return maps.map((map) => Ride.fromMap(map)).toList();
    } catch (e) {
      print('Error getting rides by date range: $e');
      return [];
    }
  }

  /// Delete a ride (cascade deletes route points)
  Future<bool> deleteRide(String id) async {
    final db = await _dbHelper.database;

    try {
      final count = await db.delete(
        DatabaseHelper.tableRides,
        where: 'id = ?',
        whereArgs: [id],
      );

      print('Deleted ride: $id (rows affected: $count)');
      return count > 0;
    } catch (e) {
      print('Error deleting ride: $e');
      return false;
    }
  }

  /// Delete all rides
  Future<int> deleteAllRides() async {
    final db = await _dbHelper.database;

    try {
      final count = await db.delete(DatabaseHelper.tableRides);
      print('Deleted all rides: $count');
      return count;
    } catch (e) {
      print('Error deleting all rides: $e');
      return 0;
    }
  }

  /// Get route points for a specific ride
  Future<List<RoutePoint>> getRoutePointsForRide(String rideId) async {
    final db = await _dbHelper.database;

    try {
      final List<Map<String, dynamic>> pointMaps = await db.query(
        DatabaseHelper.tableRoutePoints,
        where: 'ride_id = ?',
        whereArgs: [rideId],
        orderBy: 'sequence_number ASC',
      );

      return pointMaps.map((map) => RoutePoint.fromMap(map)).toList();
    } catch (e) {
      print('Error getting route points for ride: $e');
      return [];
    }
  }

  /// Mark a ride as synced
  Future<bool> markAsSynced(String id) async {
    final db = await _dbHelper.database;

    try {
      final count = await db.update(
        DatabaseHelper.tableRides,
        {'synced': 1},
        where: 'id = ?',
        whereArgs: [id],
      );

      print('Marked ride as synced: $id');
      return count > 0;
    } catch (e) {
      print('Error marking ride as synced: $e');
      return false;
    }
  }

  /// Mark a ride as synced (alias for consistency with sync service)
  Future<bool> markRideAsSynced(String id) async {
    return markAsSynced(id);
  }

  /// Get total number of rides
  Future<int> getRideCount() async {
    final db = await _dbHelper.database;

    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableRides}',
      );

      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      print('Error getting ride count: $e');
      return 0;
    }
  }

  /// Get total distance of all rides (in meters)
  Future<double> getTotalDistance() async {
    final db = await _dbHelper.database;

    try {
      final result = await db.rawQuery(
        'SELECT SUM(distance_meters) as total FROM ${DatabaseHelper.tableRides}',
      );

      if (result.isNotEmpty && result.first['total'] != null) {
        return (result.first['total'] as num).toDouble();
      }
      return 0.0;
    } catch (e) {
      print('Error getting total distance: $e');
      return 0.0;
    }
  }

  /// Get total duration of all rides (in seconds)
  Future<int> getTotalDuration() async {
    final db = await _dbHelper.database;

    try {
      final result = await db.rawQuery(
        'SELECT SUM(duration_seconds) as total FROM ${DatabaseHelper.tableRides}',
      );

      if (result.isNotEmpty && result.first['total'] != null) {
        return (result.first['total'] as num).toInt();
      }
      return 0;
    } catch (e) {
      print('Error getting total duration: $e');
      return 0;
    }
  }

  /// Get statistics summary
  Future<Map<String, dynamic>> getStatistics() async {
    final rideCount = await getRideCount();
    final totalDistance = await getTotalDistance();
    final totalDuration = await getTotalDuration();

    return {
      'rideCount': rideCount,
      'totalDistanceKm': totalDistance / 1000.0,
      'totalDurationHours': totalDuration / 3600.0,
      'avgDistanceKm': rideCount > 0 ? (totalDistance / 1000.0) / rideCount : 0.0,
    };
  }
}
