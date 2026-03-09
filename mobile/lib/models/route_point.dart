import 'package:geolocator/geolocator.dart';

/// Represents a single GPS point in a ride route
///
/// This model stores individual GPS coordinates collected during a ride,
/// including metadata like speed, heading, and accuracy.
class RoutePoint {
  final int? id; // Auto-incremented database ID
  final String rideId;
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? speed; // m/s
  final double? heading; // degrees
  final double? accuracy; // meters
  final DateTime timestamp;
  final int sequenceNumber; // Order in the route (0, 1, 2, ...)

  RoutePoint({
    this.id,
    required this.rideId,
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.speed,
    this.heading,
    this.accuracy,
    required this.timestamp,
    required this.sequenceNumber,
  });

  /// Create RoutePoint from Geolocator Position
  factory RoutePoint.fromPosition(
    Position position,
    String rideId,
    int sequenceNumber,
  ) {
    return RoutePoint(
      rideId: rideId,
      latitude: position.latitude,
      longitude: position.longitude,
      altitude: position.altitude,
      speed: position.speed >= 0 ? position.speed : null,
      heading: position.heading >= 0 ? position.heading : null,
      accuracy: position.accuracy,
      timestamp: position.timestamp,
      sequenceNumber: sequenceNumber,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ride_id': rideId,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'speed': speed,
      'heading': heading,
      'accuracy': accuracy,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'sequence_number': sequenceNumber,
    };
  }

  /// Create from database map
  factory RoutePoint.fromMap(Map<String, dynamic> map) {
    return RoutePoint(
      id: map['id'] as int?,
      rideId: map['ride_id'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      altitude: map['altitude'] as double?,
      speed: map['speed'] as double?,
      heading: map['heading'] as double?,
      accuracy: map['accuracy'] as double?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      sequenceNumber: map['sequence_number'] as int,
    );
  }

  /// Convert to Position for use with Geolocator
  Position toPosition() {
    return Position(
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp,
      accuracy: accuracy ?? 0,
      altitude: altitude ?? 0,
      altitudeAccuracy: 0,
      heading: heading ?? 0,
      headingAccuracy: 0,
      speed: speed ?? 0,
      speedAccuracy: 0,
    );
  }

  @override
  String toString() {
    return 'RoutePoint(seq: $sequenceNumber, lat: ${latitude.toStringAsFixed(6)}, '
        'lon: ${longitude.toStringAsFixed(6)}, '
        'speed: ${speed?.toStringAsFixed(1)} m/s)';
  }

  /// Copy with method for creating modified copies
  RoutePoint copyWith({
    int? id,
    String? rideId,
    double? latitude,
    double? longitude,
    double? altitude,
    double? speed,
    double? heading,
    double? accuracy,
    DateTime? timestamp,
    int? sequenceNumber,
  }) {
    return RoutePoint(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      accuracy: accuracy ?? this.accuracy,
      timestamp: timestamp ?? this.timestamp,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    );
  }
}
