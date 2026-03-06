import 'dart:async';
import 'package:geolocator/geolocator.dart';

/// GPS tracking service that provides continuous location updates
///
/// This service manages:
/// - Location permission requests
/// - Continuous GPS tracking with configurable intervals
/// - Location stream for real-time updates
/// - Battery-efficient tracking settings
class GpsService {
  // Private constructor for singleton pattern
  GpsService._();
  static final GpsService instance = GpsService._();

  // Stream controller for location updates
  final _locationController = StreamController<Position>.broadcast();

  // Location stream subscription
  StreamSubscription<Position>? _positionStreamSubscription;

  // Tracking state
  bool _isTracking = false;
  Position? _lastPosition;

  /// Public stream of location updates
  Stream<Position> get locationStream => _locationController.stream;

  /// Check if currently tracking
  bool get isTracking => _isTracking;

  /// Get the last known position
  Position? get lastPosition => _lastPosition;

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check current permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permissions
  /// Returns true if permission granted, false otherwise
  Future<bool> requestPermission() async {
    // Check if location services are enabled
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Check current permission
    LocationPermission permission = await checkPermission();

    // Request permission if denied
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    // Check if permanently denied
    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Get current location once (not continuous tracking)
  Future<Position?> getCurrentLocation() async {
    try {
      // Ensure permissions
      bool hasPermission = await requestPermission();
      if (!hasPermission) {
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _lastPosition = position;
      return position;
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  /// Start continuous GPS tracking
  ///
  /// Updates will be sent via [locationStream]
  ///
  /// Parameters:
  /// - [distanceFilter]: Minimum distance (meters) before update (default: 10m)
  /// - [timeInterval]: Minimum time (milliseconds) between updates (default: 5000ms)
  Future<bool> startTracking({
    double distanceFilter = 10.0,
    int timeInterval = 5000,
  }) async {
    if (_isTracking) {
      print('GPS tracking already started');
      return true;
    }

    try {
      // Request permissions
      bool hasPermission = await requestPermission();
      if (!hasPermission) {
        print('Location permission not granted');
        return false;
      }

      // Configure location settings for optimal battery and accuracy
      late LocationSettings locationSettings;

      // Platform-specific settings
      locationSettings = LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: distanceFilter.toInt(),
        timeLimit: Duration(milliseconds: timeInterval),
      );

      // Start position stream
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          _lastPosition = position;
          _locationController.add(position);
        },
        onError: (error) {
          print('GPS tracking error: $error');
        },
      );

      _isTracking = true;
      print('GPS tracking started (distance filter: ${distanceFilter}m, time: ${timeInterval}ms)');
      return true;
    } catch (e) {
      print('Error starting GPS tracking: $e');
      return false;
    }
  }

  /// Stop continuous GPS tracking
  Future<void> stopTracking() async {
    if (!_isTracking) {
      return;
    }

    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _isTracking = false;
    print('GPS tracking stopped');
  }

  /// Calculate distance between two positions in meters
  double calculateDistance(Position start, Position end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  /// Calculate speed in km/h from position
  /// Returns null if speed data not available
  double? getSpeedKmh(Position position) {
    if (position.speed < 0) {
      return null;
    }
    return position.speed * 3.6; // m/s to km/h
  }

  /// Get heading/direction from position
  /// Returns null if heading data not available
  double? getHeading(Position position) {
    if (position.heading < 0) {
      return null;
    }
    return position.heading;
  }

  /// Get accuracy in meters
  double getAccuracy(Position position) {
    return position.accuracy;
  }

  /// Dispose and cleanup resources
  void dispose() {
    stopTracking();
    _locationController.close();
  }
}
