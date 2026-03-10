import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  // Singleton pattern
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  // Stream controller for connectivity changes
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectivityStream => _connectivityController.stream;

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    // Check initial connectivity
    _isOnline = await checkConnectivity();
    print('Connectivity Service: Initial state - ${_isOnline ? "Online" : "Offline"}');

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) async {
        final wasOnline = _isOnline;
        _isOnline = _hasInternetConnection(result);

        print('Connectivity Service: Connectivity changed - ${_isOnline ? "Online" : "Offline"}');
        print('Connectivity Service: Result: $result');

        // Only emit if the state actually changed
        if (wasOnline != _isOnline) {
          print('Connectivity Service: State changed from ${wasOnline ? "Online" : "Offline"} to ${_isOnline ? "Online" : "Offline"}');
          _connectivityController.add(_isOnline);
        }
      },
    );
  }

  /// Check current connectivity status
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return _hasInternetConnection(result);
    } catch (e) {
      print('Connectivity Service: Error checking connectivity: $e');
      return false;
    }
  }

  /// Determine if we have internet connection based on connectivity result
  bool _hasInternetConnection(ConnectivityResult result) {
    return result != ConnectivityResult.none;
  }

  /// Get a human-readable connectivity status
  Future<String> getConnectionType() async {
    try {
      final result = await _connectivity.checkConnectivity();

      switch (result) {
        case ConnectivityResult.wifi:
          return 'WiFi';
        case ConnectivityResult.mobile:
          return 'Mobile Data';
        case ConnectivityResult.ethernet:
          return 'Ethernet';
        case ConnectivityResult.bluetooth:
          return 'Bluetooth';
        case ConnectivityResult.vpn:
          return 'VPN';
        case ConnectivityResult.other:
          return 'Other';
        case ConnectivityResult.none:
          return 'None';
      }
    } catch (e) {
      print('Connectivity Service: Error getting connection type: $e');
      return 'Unknown';
    }
  }

  /// Dispose of resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController.close();
  }
}
