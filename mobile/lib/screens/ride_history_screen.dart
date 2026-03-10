import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ride.dart';
import '../services/ride_storage_service.dart';
import 'ride_detail_screen.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  final RideStorageService _storageService = RideStorageService.instance;
  List<Ride> _rides = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRides();
  }

  Future<void> _loadRides() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final rides = await _storageService.getAllRides();
      setState(() {
        _rides = rides;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load rides: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _loadRides();
  }

  Future<void> _deleteRide(Ride ride) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ride'),
        content: const Text('Are you sure you want to delete this ride?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _storageService.deleteRide(ride.id);
        _loadRides();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ride deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete ride: $e')),
          );
        }
      }
    }
  }

  void _openRideDetail(Ride ride) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RideDetailScreen(ride: ride),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride History'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRides,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_rides.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.two_wheeler,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No rides yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start your first ride to see it here',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _rides.length,
        itemBuilder: (context, index) {
          final ride = _rides[index];
          return _buildRideCard(ride);
        },
      ),
    );
  }

  Widget _buildRideCard(Ride ride) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: InkWell(
        onTap: () => _openRideDetail(ride),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with date and sync status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        dateFormat.format(ride.startTime),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Sync status indicator
                      Icon(
                        ride.synced ? Icons.cloud_done : Icons.cloud_off,
                        size: 16,
                        color: ride.synced ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ride.synced ? 'Synced' : 'Local',
                        style: TextStyle(
                          fontSize: 12,
                          color: ride.synced ? Colors.green : Colors.orange,
                        ),
                      ),
                      // Delete button
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () => _deleteRide(ride),
                        color: Colors.red,
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Time
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    '${timeFormat.format(ride.startTime)} - ${timeFormat.format(ride.endTime)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const Divider(height: 16),

              // Statistics
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(
                    Icons.straighten,
                    'Distance',
                    ride.formattedDistance(),
                  ),
                  _buildStat(
                    Icons.timer,
                    'Duration',
                    ride.formattedDuration(),
                  ),
                  _buildStat(
                    Icons.speed,
                    'Avg Speed',
                    '${ride.avgSpeedKmh.toStringAsFixed(1)} km/h',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
