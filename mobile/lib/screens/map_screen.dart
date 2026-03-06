import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/gps_service.dart';
import '../widgets/gps_data_panel.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final GpsService _gpsService = GpsService.instance;

  Position? _currentPosition;
  bool _isLoadingLocation = true;
  bool _isTracking = false;
  String? _locationError;

  StreamSubscription<Position>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
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

          // GPS Data Panel
          Positioned(
            bottom: 100, // Leave space for FAB
            left: 0,
            right: 0,
            child: GpsDataPanel(
              position: _currentPosition,
              isTracking: _isTracking,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Start ride recording (Phase 4)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ride recording coming in Phase 4!'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        icon: const Icon(Icons.play_arrow),
        label: const Text('Start Ride'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
