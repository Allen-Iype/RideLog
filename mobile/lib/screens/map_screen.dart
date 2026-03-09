import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/gps_service.dart';
import '../services/ride_recording_service.dart';
import '../services/ride_storage_service.dart';
import '../models/ride.dart';
import '../widgets/gps_data_panel.dart';
import '../widgets/ride_stats_panel.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final GpsService _gpsService = GpsService.instance;
  final RideRecordingService _rideService = RideRecordingService.instance;

  Position? _currentPosition;
  bool _isLoadingLocation = true;
  bool _isTracking = false;
  String? _locationError;

  StreamSubscription<Position>? _locationSubscription;
  Timer? _routeUpdateTimer;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _routeUpdateTimer?.cancel();
    // Don't dispose the GPS service singleton here
    super.dispose();
  }

  /// Initialize location - get current position once
  Future<void> _initializeLocation() async {
    try {
      final position = await _gpsService.getCurrentLocation();

      if (position == null) {
        setState(() {
          _locationError = 'Could not get location. Check permissions.';
          _isLoadingLocation = false;
        });
        return;
      }

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });

      // Center map on initial location
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        15.0,
      );
    } catch (e) {
      setState(() {
        _locationError = 'Error getting location: $e';
        _isLoadingLocation = false;
      });
    }
  }

  /// Start continuous GPS tracking
  Future<void> _startTracking() async {
    final started = await _gpsService.startTracking(
      distanceFilter: 10.0, // Update every 10 meters
      timeInterval: 5000, // Or every 5 seconds
    );

    if (!started) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to start GPS tracking. Check permissions.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Listen to location stream
    _locationSubscription = _gpsService.locationStream.listen(
      (Position position) {
        setState(() {
          _currentPosition = position;
        });

        // Auto-center map on new location (optional - can be toggled)
        // _mapController.move(
        //   LatLng(position.latitude, position.longitude),
        //   _mapController.zoom,
        // );
      },
      onError: (error) {
        print('Location stream error: $error');
      },
    );

    setState(() {
      _isTracking = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GPS tracking started'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Stop continuous GPS tracking
  Future<void> _stopTracking() async {
    await _gpsService.stopTracking();
    await _locationSubscription?.cancel();
    _locationSubscription = null;

    setState(() {
      _isTracking = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GPS tracking stopped'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Toggle GPS tracking on/off
  Future<void> _toggleTracking() async {
    if (_isTracking) {
      await _stopTracking();
    } else {
      await _startTracking();
    }
  }

  /// Center map on current location
  void _centerOnLocation() {
    if (_currentPosition != null) {
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        15.0,
      );
    }
  }

  /// Start recording a ride
  Future<void> _startRide() async {
    final started = await _rideService.startRide();

    if (!started) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to start ride recording. Check GPS.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Start timer to update route polyline periodically
    _routeUpdateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _rideService.isRecording) {
        setState(() {
          // Trigger rebuild to update polyline
        });
      }
    });

    setState(() {
      // Update UI to show recording state
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ride recording started!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Stop recording the current ride
  Future<void> _stopRide() async {
    try {
      final summary = await _rideService.stopRide();

      // Cancel update timer
      _routeUpdateTimer?.cancel();
      _routeUpdateTimer = null;

      setState(() {
        // Update UI
      });

      if (mounted) {
        // Show ride summary dialog
        _showRideSummary(summary);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error stopping ride: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show ride summary dialog
  void _showRideSummary(RideSummary summary) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Ride Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryRow(
              icon: Icons.route,
              label: 'Distance',
              value: '${summary.distanceKm.toStringAsFixed(2)} km',
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              icon: Icons.timer,
              label: 'Duration',
              value: summary.durationFormatted,
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              icon: Icons.speed,
              label: 'Average Speed',
              value: '${summary.averageSpeedKmh.toStringAsFixed(1)} km/h',
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              icon: Icons.trending_up,
              label: 'Max Speed',
              value: '${summary.maxSpeedKmh.toStringAsFixed(1)} km/h',
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              icon: Icons.location_on,
              label: 'GPS Points',
              value: '${summary.routePoints.length}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              try {
                // Convert RideSummary to Ride model
                final ride = Ride.fromRideSummary(summary);

                // Save to local database
                final rideId = await RideStorageService.instance.saveRide(ride);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ride saved successfully!'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 3),
                      action: SnackBarAction(
                        label: 'View',
                        textColor: Colors.white,
                        onPressed: () {
                          // TODO: Navigate to ride detail screen
                        },
                      ),
                    ),
                  );
                }

                print('Ride saved with ID: $rideId');
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error saving ride: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
                print('Error saving ride: $e');
              }
            },
            child: const Text('Save Ride'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RideLog'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // GPS tracking toggle button
          IconButton(
            icon: Icon(
              _isTracking ? Icons.gps_fixed : Icons.gps_not_fixed,
              color: _isTracking ? Colors.green : null,
            ),
            onPressed: _toggleTracking,
            tooltip: _isTracking ? 'Stop GPS tracking' : 'Start GPS tracking',
          ),
          // Center on location button
          if (_currentPosition != null)
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: _centerOnLocation,
              tooltip: 'Center on my location',
            ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition != null
                  ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                  : const LatLng(37.7749, -122.4194), // Default to San Francisco
              initialZoom: 15.0,
              minZoom: 3.0,
              maxZoom: 18.0,
            ),
            children: [
              // OpenStreetMap tile layer
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ridelog.app',
                maxZoom: 19,
              ),
              // Route polyline (if recording)
              if (_rideService.isRecording && _rideService.routeLatLngs.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _rideService.routeLatLngs,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                      borderStrokeWidth: 2.0,
                      borderColor: Colors.white,
                    ),
                  ],
                ),
              // Current location marker
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      width: 80,
                      height: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Accuracy circle (if tracking)
                          if (_isTracking)
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue.withOpacity(0.2),
                                border: Border.all(
                                  color: Colors.blue.withOpacity(0.5),
                                  width: 2,
                                ),
                              ),
                            ),
                          // Location marker
                          Icon(
                            _isTracking ? Icons.navigation : Icons.location_on,
                            color: _isTracking ? Colors.blue : Colors.red,
                            size: 40,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Loading indicator
          if (_isLoadingLocation)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Getting your location...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Error message
          if (_locationError != null && !_isLoadingLocation)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.red.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _locationError!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _locationError = null;
                            _isLoadingLocation = true;
                          });
                          _initializeLocation();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Data Panels
          Positioned(
            bottom: 100, // Leave space for FAB
            left: 0,
            right: 0,
            child: _rideService.isRecording
                ? RideStatsPanel(rideService: _rideService)
                : GpsDataPanel(
                    position: _currentPosition,
                    isTracking: _isTracking,
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _rideService.isRecording ? _stopRide : _startRide,
        icon: Icon(_rideService.isRecording ? Icons.stop : Icons.play_arrow),
        label: Text(_rideService.isRecording ? 'Stop Ride' : 'Start Ride'),
        backgroundColor: _rideService.isRecording ? Colors.red : Colors.green,
      ),
    );
  }
}
