import 'package:flutter/material.dart';
import 'dart:async';
import '../services/ride_recording_service.dart';

/// Widget that displays live ride statistics during recording
///
/// Shows:
/// - Current distance
/// - Elapsed time
/// - Average speed
/// - Max speed
class RideStatsPanel extends StatefulWidget {
  final RideRecordingService rideService;

  const RideStatsPanel({
    super.key,
    required this.rideService,
  });

  @override
  State<RideStatsPanel> createState() => _RideStatsPanelState();
}

class _RideStatsPanelState extends State<RideStatsPanel> {
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    // Update stats every second to show live duration
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && widget.rideService.isRecording) {
        setState(() {
          // Trigger rebuild to update duration
        });
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.rideService.isRecording) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 6,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with recording indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'RECORDING',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Statistics grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.route,
                  label: 'Distance',
                  value: widget.rideService.totalDistanceKm.toStringAsFixed(2),
                  unit: 'km',
                  color: Colors.blue,
                ),
                _buildStatItem(
                  icon: Icons.timer,
                  label: 'Time',
                  value: _formatDuration(widget.rideService.durationSeconds),
                  unit: '',
                  color: Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.speed,
                  label: 'Avg Speed',
                  value: widget.rideService.averageSpeedKmh.toStringAsFixed(1),
                  unit: 'km/h',
                  color: Colors.orange,
                ),
                _buildStatItem(
                  icon: Icons.trending_up,
                  label: 'Max Speed',
                  value: widget.rideService.maxSpeedKmh.toStringAsFixed(1),
                  unit: 'km/h',
                  color: Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Point count
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.rideService.pointCount} GPS points',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
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

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 2),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }
}
