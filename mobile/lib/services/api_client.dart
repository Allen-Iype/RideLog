import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ride.dart';
import '../models/route_point.dart';
import 'auth_service.dart';

class ApiClient {
  // Singleton pattern
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  // Base URL for the API - for development, use local network IP or localhost
  // TODO: Update this to your actual backend URL
  static const String baseUrl = 'http://localhost:8080/api/v1';

  // For Android emulator, use: http://10.0.2.2:8080/api/v1
  // For iOS simulator, use: http://localhost:8080/api/v1
  // For physical devices, use your computer's IP: http://192.168.x.x:8080/api/v1

  final http.Client _client = http.Client();
  final AuthService _authService = AuthService();

  // Timeout duration for requests
  static const Duration timeout = Duration(seconds: 30);

  // Get headers with authentication token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Create a new ride on the server
  Future<Map<String, dynamic>> createRide(Ride ride, List<RoutePoint> routePoints) async {
    try {
      final url = Uri.parse('$baseUrl/rides');

      // Convert route points to API format
      final apiRoutePoints = routePoints.map((point) => {
        'latitude': point.latitude,
        'longitude': point.longitude,
        'altitude': point.altitude,
        'speed': point.speed,
        'heading': point.heading,
        'accuracy': point.accuracy,
        'timestamp': point.timestamp,
        'sequence_number': point.sequenceNumber,
      }).toList();

      // Prepare request body
      final body = {
        'start_time': ride.startTime.toIso8601String(),
        'end_time': ride.endTime.toIso8601String(),
        'distance_meters': ride.distanceMeters,
        'avg_speed_kmh': ride.avgSpeedKmh,
        'max_speed_kmh': ride.maxSpeedKmh,
        'duration_seconds': ride.durationSeconds,
        'route_points': apiRoutePoints,
      };

      print('API Client: Sending ride to $url');
      print('API Client: Request body has ${apiRoutePoints.length} route points');

      final headers = await _getHeaders();
      final response = await _client
          .post(
            url,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(timeout);

      print('API Client: Response status: ${response.statusCode}');

      if (response.statusCode == 201) {
        // Success - ride created
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        print('API Client: Ride created successfully with ID: ${responseData['id']}');
        return responseData;
      } else {
        // Error response
        final errorData = jsonDecode(response.body);
        throw ApiException(
          'Failed to create ride: ${response.statusCode}',
          response.statusCode,
          errorData,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      print('API Client: Error creating ride: $e');
      throw ApiException('Network error: $e', 0, null);
    }
  }

  /// Get all rides from the server
  Future<List<Map<String, dynamic>>> getRides({int page = 1, int pageSize = 20}) async {
    try {
      final url = Uri.parse('$baseUrl/rides?page=$page&page_size=$pageSize');

      final headers = await _getHeaders();
      final response = await _client
          .get(
            url,
            headers: headers,
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rides = data['rides'] as List<dynamic>;
        return rides.cast<Map<String, dynamic>>();
      } else {
        throw ApiException(
          'Failed to fetch rides: ${response.statusCode}',
          response.statusCode,
          null,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Network error: $e', 0, null);
    }
  }

  /// Get a specific ride by ID
  Future<Map<String, dynamic>> getRideById(String rideId) async {
    try {
      final url = Uri.parse('$baseUrl/rides/$rideId');

      final headers = await _getHeaders();
      final response = await _client
          .get(
            url,
            headers: headers,
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        throw ApiException('Ride not found', 404, null);
      } else {
        throw ApiException(
          'Failed to fetch ride: ${response.statusCode}',
          response.statusCode,
          null,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Network error: $e', 0, null);
    }
  }

  /// Delete a ride from the server
  Future<void> deleteRide(String rideId) async {
    try {
      final url = Uri.parse('$baseUrl/rides/$rideId');

      final headers = await _getHeaders();
      final response = await _client
          .delete(
            url,
            headers: headers,
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        print('API Client: Ride deleted successfully');
      } else if (response.statusCode == 404) {
        throw ApiException('Ride not found', 404, null);
      } else {
        throw ApiException(
          'Failed to delete ride: ${response.statusCode}',
          response.statusCode,
          null,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Network error: $e', 0, null);
    }
  }

  /// Test connection to the server
  Future<bool> testConnection() async {
    try {
      final url = Uri.parse('http://localhost:8080/health');
      final response = await _client.get(url).timeout(
        const Duration(seconds: 5),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('API Client: Connection test failed: $e');
      return false;
    }
  }

  /// Dispose of the client
  void dispose() {
    _client.close();
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final dynamic details;

  ApiException(this.message, this.statusCode, this.details);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
