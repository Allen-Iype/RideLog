import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// Widget that displays live GPS tracking data
///
/// Shows:
/// - Current speed
/// - Heading/direction
/// - GPS accuracy
/// - Coordinates
class GpsDataPanel extends StatelessWidget {
  final Position? position;
  final bool isTracking;

  const GpsDataPanel({
    super.key,
    required this.position,
    required this.isTracking,
  });

  @override
  Widget build(BuildContext context) {
    if (position == null) {
      return _buildNoDataCard(context);
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with tracking status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.gps_fixed,
                      color: isTracking ? Colors.green : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isTracking ? 'Tracking Active' : 'Tracking Inactive',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isTracking ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
                _buildAccuracyIndicator(position!.accuracy),
              ],
            ),
            const Divider(height: 24),

            // GPS data grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDataItem(
                  icon: Icons.speed,
                  label: 'Speed',
                  value: _formatSpeed(position!.speed),
                  unit: 'km/h',
                ),
                _buildDataItem(
                  icon: Icons.explore,
                  label: 'Heading',
                  value: _formatHeading(position!.heading),
                  unit: '°',
                ),
                _buildDataItem(
                  icon: Icons.height,
                  label: 'Altitude',
                  value: position!.altitude.toStringAsFixed(0),
                  unit: 'm',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Coordinates
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Latitude:',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        position!.latitude.toStringAsFixed(6),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Longitude:',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        position!.longitude.toStringAsFixed(6),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.gps_off, color: Colors.grey.shade400),
            const SizedBox(width: 12),
            const Text(
              'No GPS data available',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataItem({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 24),
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccuracyIndicator(double accuracy) {
    Color color;
    String label;

    if (accuracy < 10) {
      color = Colors.green;
      label = 'Excellent';
    } else if (accuracy < 30) {
      color = Colors.lightGreen;
      label = 'Good';
    } else if (accuracy < 50) {
      color = Colors.orange;
      label = 'Fair';
    } else {
      color = Colors.red;
      label = 'Poor';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: color, size: 8),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '±${accuracy.toStringAsFixed(0)}m',
            style: TextStyle(
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatSpeed(double speedMps) {
    if (speedMps < 0) return '--';
    final speedKmh = speedMps * 3.6;
    return speedKmh.toStringAsFixed(1);
  }

  String _formatHeading(double heading) {
    if (heading < 0) return '--';
    return heading.toStringAsFixed(0);
  }
}
