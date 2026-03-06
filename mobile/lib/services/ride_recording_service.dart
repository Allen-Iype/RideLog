import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'gps_service.dart';

/// Service that manages ride recording
///
/// This service:
/// - Starts/stops ride recording
/// - Collects GPS points during a ride
/// - Calculates ride statistics (distance, duration, average speed)
/// - Provides route data for visualization
class RideRecordingService {
  // Singleton pattern
  RideRecordingService._();
  static final RideRecordingService instance = RideRecordingService._();

  final GpsService _gpsService = GpsService.instance;

  // Ride state
  bool _isRecording = false;
  DateTime? _rideStartTime;
  DateTime? _rideEndTime;
  final List<Position> _routePoints = [];

  // Location subscription
  StreamSubscription<Position>? _locationSubscription;

  // Statistics
  double _totalDistance = 0.0; // in meters
  double _maxSpeed = 0.0; // in m/s

  /// Check if currently recording a ride
  bool get isRecording => _isRecording;

  /// Get the start time of the current ride
  DateTime? get rideStartTime => _rideStartTime;

  /// Get the end time of the ride (only available after stopping)
  DateTime? get rideEndTime => _rideEndTime;

  /// Get the list of GPS points collected during the ride
  List<Position> get routePoints => List.unmodifiable(_routePoints);

  /// Get the route as LatLng points for map rendering
  List<LatLng> get routeLatLngs {
    return _routePoints
        .map((pos) => LatLng(pos.latitude, pos.longitude))
        .toList();
  }

  /// Get total distance traveled in meters
  double get totalDistance => _totalDistance;

  /// Get total distance in kilometers
  double get totalDistanceKm => _totalDistance / 1000.0;

  /// Get ride duration in seconds
  int get durationSeconds {
    if (_rideStartTime == null) return 0;
    final endTime = _rideEndTime ?? DateTime.now();
    return endTime.difference(_rideStartTime!).inSeconds;
  }

  /// Get ride duration as formatted string (HH:MM:SS)
  String get durationFormatted {
    final seconds = durationSeconds;
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  /// Get average speed in km/h
  double get averageSpeedKmh {
    if (durationSeconds == 0) return 0.0;
    // distance in km / time in hours
    return (totalDistanceKm / (durationSeconds / 3600.0));
  }

  /// Get max speed in km/h
  double get maxSpeedKmh => _maxSpeed * 3.6;

  /// Get number of GPS points recorded
  int get pointCount => _routePoints.length;

  /// Start recording a new ride
  ///
  /// This will:
  /// - Start GPS tracking if not already active
  /// - Begin collecting GPS points
  /// - Calculate statistics
  ///
  /// Returns true if started successfully, false otherwise
  Future<bool> startRide() async {
    if (_isRecording) {
      print('Ride recording already in progress');
      return false;
    }

    // Clear previous ride data
    _routePoints.clear();
    _totalDistance = 0.0;
    _maxSpeed = 0.0;
    _rideStartTime = DateTime.now();
    _rideEndTime = null;

    // Start GPS tracking if not already active
    if (!_gpsService.isTracking) {
      final started = await _gpsService.startTracking(
        distanceFilter: 10.0, // Update every 10 meters
        timeInterval: 5000, // Or every 5 seconds
      );

      if (!started) {
        print('Failed to start GPS tracking');
        return false;
      }
    }

    // Subscribe to location updates
    _locationSubscription = _gpsService.locationStream.listen(
      _handleLocationUpdate,
      onError: (error) {
        print('Error during ride recording: $error');
      },
    );

    _isRecording = true;
    print('Ride recording started at ${_rideStartTime!.toIso8601String()}');
    return true;
  }

  /// Handle location update during ride recording
  void _handleLocationUpdate(Position position) {
    if (!_isRecording) return;

    // Filter out low accuracy points (> 50 meters accuracy)
    if (position.accuracy > 50) {
      print('Skipping low accuracy point: ${position.accuracy}m');
      return;
    }

    // Add point to route
    _routePoints.add(position);

    // Calculate distance from previous point
    if (_routePoints.length > 1) {
      final previousPoint = _routePoints[_routePoints.length - 2];
      final distance = _gpsService.calculateDistance(previousPoint, position);

      // Only add distance if movement is reasonable (< 100m in 5 seconds = 72 km/h)
      // This filters out GPS jumps/errors
      if (distance < 100) {
        _totalDistance += distance;
      }
    }

    // Track max speed
    if (position.speed > _maxSpeed) {
      _maxSpeed = position.speed;
    }

    print('Recorded point ${_routePoints.length}: '
        '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)} '
        '(distance: ${totalDistanceKm.toStringAsFixed(2)}km)');
  }

  /// Stop recording the current ride
  ///
  /// Returns a summary of the ride
  Future<RideSummary> stopRide() async {
    if (!_isRecording) {
      throw StateError('No ride in progress');
    }

    _rideEndTime = DateTime.now();
    _isRecording = false;

    // Cancel location subscription
    await _locationSubscription?.cancel();
    _locationSubscription = null;

    print('Ride recording stopped at ${_rideEndTime!.toIso8601String()}');
    print('Total distance: ${totalDistanceKm.toStringAsFixed(2)} km');
    print('Duration: $durationFormatted');
    print('Average speed: ${averageSpeedKmh.toStringAsFixed(1)} km/h');
    print('Max speed: ${maxSpeedKmh.toStringAsFixed(1)} km/h');
    print('Points recorded: $pointCount');

    return RideSummary(
      startTime: _rideStartTime!,
      endTime: _rideEndTime!,
      distanceMeters: _totalDistance,
      durationSeconds: durationSeconds,
      averageSpeedKmh: averageSpeedKmh,
      maxSpeedKmh: maxSpeedKmh,
      routePoints: List.from(_routePoints),
    );
  }

  /// Discard the current ride without saving
  Future<void> discardRide() async {
    if (!_isRecording) return;

    _isRecording = false;
    await _locationSubscription?.cancel();
    _locationSubscription = null;

    _routePoints.clear();
    _totalDistance = 0.0;
    _maxSpeed = 0.0;
    _rideStartTime = null;
    _rideEndTime = null;

    print('Ride recording discarded');
  }

  /// Dispose and cleanup resources
  void dispose() {
    _locationSubscription?.cancel();
    _routePoints.clear();
  }
}

/// Summary of a completed ride
class RideSummary {
  final DateTime startTime;
  final DateTime endTime;
  final double distanceMeters;
  final int durationSeconds;
  final double averageSpeedKmh;
  final double maxSpeedKmh;
  final List<Position> routePoints;

  RideSummary({
    required this.startTime,
    required this.endTime,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.averageSpeedKmh,
    required this.maxSpeedKmh,
    required this.routePoints,
  });

  double get distanceKm => distanceMeters / 1000.0;

  String get durationFormatted {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    final secs = durationSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'RideSummary('
        'distance: ${distanceKm.toStringAsFixed(2)} km, '
        'duration: $durationFormatted, '
        'avg speed: ${averageSpeedKmh.toStringAsFixed(1)} km/h, '
        'max speed: ${maxSpeedKmh.toStringAsFixed(1)} km/h, '
        'points: ${routePoints.length}'
        ')';
  }
}
