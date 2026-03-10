import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../models/ride.dart';
import '../models/route_point.dart';
import '../services/ride_storage_service.dart';

class RideDetailScreen extends StatefulWidget {
  final Ride ride;

  const RideDetailScreen({super.key, required this.ride});

  @override
  State<RideDetailScreen> createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends State<RideDetailScreen> {
  final RideStorageService _storageService = RideStorageService.instance;
  final MapController _mapController = MapController();

  List<RoutePoint> _routePoints = [];
  bool _isLoadingRoute = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRoutePoints();
  }

  Future<void> _loadRoutePoints() async {
    setState(() {
      _isLoadingRoute = true;
      _errorMessage = null;
    });

    try {
      final points = await _storageService.getRoutePointsForRide(widget.ride.id);
      setState(() {
        _routePoints = points;
        _isLoadingRoute = false;
      });

      // Center map on route if available
      if (_routePoints.isNotEmpty && mounted) {
        final firstPoint = _routePoints.first;
        _mapController.move(
          LatLng(firstPoint.latitude, firstPoint.longitude),
          15.0,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load route: $e';
        _isLoadingRoute = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMMM dd, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Map showing route
            SizedBox(
              height: 300,
              child: _buildMap(),
            ),

            // Ride information
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and time
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        dateFormat.format(widget.ride.startTime),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        '${timeFormat.format(widget.ride.startTime)} - ${timeFormat.format(widget.ride.endTime)}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Statistics cards
                  _buildStatsGrid(),

                  const SizedBox(height: 24),

                  // Route information
                  if (_routePoints.isNotEmpty) ...[
                    Text(
                      'Route Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('GPS Points', '${_routePoints.length}'),
                    _buildInfoRow('Start Location',
                        '${_routePoints.first.latitude.toStringAsFixed(6)}, ${_routePoints.first.longitude.toStringAsFixed(6)}'),
                    _buildInfoRow('End Location',
                        '${_routePoints.last.latitude.toStringAsFixed(6)}, ${_routePoints.last.longitude.toStringAsFixed(6)}'),
                    const SizedBox(height: 24),
                  ],

                  // Sync status
                  Card(
                    color: widget.ride.synced
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            widget.ride.synced
                                ? Icons.cloud_done
                                : Icons.cloud_off,
                            color: widget.ride.synced
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.ride.synced
                                  ? 'This ride has been synced to the server'
                                  : 'This ride is stored locally and will sync when online',
                              style: TextStyle(
                                color: widget.ride.synced
                                    ? Colors.green.shade900
                                    : Colors.orange.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap() {
    if (_isLoadingRoute) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text(_errorMessage!),
          ],
        ),
      );
    }

    if (_routePoints.isEmpty) {
      return const Center(
        child: Text('No route data available'),
      );
    }

    // Convert route points to LatLng for polyline
    final routeLatLngs = _routePoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: routeLatLngs.first,
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

        // Route polyline
        PolylineLayer(
          polylines: [
            Polyline(
              points: routeLatLngs,
              strokeWidth: 4.0,
              color: Colors.blue,
            ),
          ],
        ),

        // Start marker
        MarkerLayer(
          markers: [
            Marker(
              point: routeLatLngs.first,
              width: 40,
              height: 40,
              child: const Icon(
                Icons.play_circle,
                color: Colors.green,
                size: 40,
              ),
            ),
            // End marker
            Marker(
              point: routeLatLngs.last,
              width: 40,
              height: 40,
              child: const Icon(
                Icons.stop_circle,
                color: Colors.red,
                size: 40,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          Icons.straighten,
          'Distance',
          widget.ride.formattedDistance(),
          Colors.blue,
        ),
        _buildStatCard(
          Icons.timer,
          'Duration',
          widget.ride.formattedDuration(),
          Colors.orange,
        ),
        _buildStatCard(
          Icons.speed,
          'Average Speed',
          '${widget.ride.avgSpeedKmh.toStringAsFixed(1)} km/h',
          Colors.green,
        ),
        _buildStatCard(
          Icons.trending_up,
          'Max Speed',
          '${widget.ride.maxSpeedKmh.toStringAsFixed(1)} km/h',
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      IconData icon, String label, String value, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
