import 'package:uuid/uuid.dart';
import 'route_point.dart';
import '../services/ride_recording_service.dart';

/// Represents a completed ride with all metadata and route points
///
/// This model stores complete ride information including:
/// - Ride statistics (distance, duration, speeds)
/// - Route GPS points
/// - Sync status
class Ride {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final double distanceMeters;
  final int durationSeconds;
  final double avgSpeedKmh;
  final double maxSpeedKmh;
  final int pointCount;
  final bool synced;
  final DateTime createdAt;
  final List<RoutePoint> routePoints;

  Ride({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.avgSpeedKmh,
    required this.maxSpeedKmh,
    required this.pointCount,
    this.synced = false,
    DateTime? createdAt,
    List<RoutePoint>? routePoints,
  })  : createdAt = createdAt ?? DateTime.now(),
        routePoints = routePoints ?? [];

  /// Create Ride from RideSummary (after completing a ride)
  factory Ride.fromRideSummary(RideSummary summary) {
    const uuid = Uuid();
    final rideId = uuid.v4();

    // Convert Position objects to RoutePoint objects
    final routePoints = <RoutePoint>[];
    for (int i = 0; i < summary.routePoints.length; i++) {
      routePoints.add(
        RoutePoint.fromPosition(
          summary.routePoints[i],
          rideId,
          i, // sequence number
        ),
      );
    }

    return Ride(
      id: rideId,
      startTime: summary.startTime,
      endTime: summary.endTime,
      distanceMeters: summary.distanceMeters,
      durationSeconds: summary.durationSeconds,
      avgSpeedKmh: summary.averageSpeedKmh,
      maxSpeedKmh: summary.maxSpeedKmh,
      pointCount: summary.routePoints.length,
      synced: false,
      routePoints: routePoints,
    );
  }

  /// Convert to database map (rides table)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start_time': startTime.millisecondsSinceEpoch,
      'end_time': endTime.millisecondsSinceEpoch,
      'distance_meters': distanceMeters,
      'duration_seconds': durationSeconds,
      'avg_speed_kmh': avgSpeedKmh,
      'max_speed_kmh': maxSpeedKmh,
      'point_count': pointCount,
      'synced': synced ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  /// Create from database map
  factory Ride.fromMap(Map<String, dynamic> map, {List<RoutePoint>? routePoints}) {
    return Ride(
      id: map['id'] as String,
      startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time'] as int),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['end_time'] as int),
      distanceMeters: map['distance_meters'] as double,
      durationSeconds: map['duration_seconds'] as int,
      avgSpeedKmh: map['avg_speed_kmh'] as double,
      maxSpeedKmh: map['max_speed_kmh'] as double,
      pointCount: map['point_count'] as int,
      synced: map['synced'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      routePoints: routePoints,
    );
  }

  // Getters for formatted values

  /// Distance in kilometers
  double get distanceKm => distanceMeters / 1000.0;

  /// Duration formatted as HH:MM:SS
  String get durationFormatted {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    final seconds = durationSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// Duration as human-readable string (e.g., "1h 23m")
  String get durationHumanReadable {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${durationSeconds}s';
    }
  }

  /// Start time formatted as date and time
  String get startTimeFormatted {
    return '${startTime.year}-${startTime.month.toString().padLeft(2, '0')}-'
        '${startTime.day.toString().padLeft(2, '0')} '
        '${startTime.hour.toString().padLeft(2, '0')}:'
        '${startTime.minute.toString().padLeft(2, '0')}';
  }

  /// Start date formatted (e.g., "Mar 6, 2026")
  String get startDateFormatted {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[startTime.month - 1]} ${startTime.day}, ${startTime.year}';
  }

  @override
  String toString() {
    return 'Ride(id: $id, '
        'distance: ${distanceKm.toStringAsFixed(2)} km, '
        'duration: $durationFormatted, '
        'points: $pointCount, '
        'synced: $synced)';
  }

  /// Copy with method for creating modified copies
  Ride copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    double? distanceMeters,
    int? durationSeconds,
    double? avgSpeedKmh,
    double? maxSpeedKmh,
    int? pointCount,
    bool? synced,
    DateTime? createdAt,
    List<RoutePoint>? routePoints,
  }) {
    return Ride(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      avgSpeedKmh: avgSpeedKmh ?? this.avgSpeedKmh,
      maxSpeedKmh: maxSpeedKmh ?? this.maxSpeedKmh,
      pointCount: pointCount ?? this.pointCount,
      synced: synced ?? this.synced,
      createdAt: createdAt ?? this.createdAt,
      routePoints: routePoints ?? this.routePoints,
    );
  }

  /// Create a copy with synced status updated
  Ride markAsSynced() {
    return copyWith(synced: true);
  }
}
