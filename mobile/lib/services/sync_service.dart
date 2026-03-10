import 'dart:async';
import 'api_client.dart';
import 'connectivity_service.dart';
import 'ride_storage_service.dart';

enum SyncStatus {
  idle,
  syncing,
  success,
  error,
}

class SyncResult {
  final SyncStatus status;
  final int syncedCount;
  final int failedCount;
  final String? errorMessage;

  SyncResult({
    required this.status,
    this.syncedCount = 0,
    this.failedCount = 0,
    this.errorMessage,
  });
}

class SyncService {
  // Singleton pattern
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final ApiClient _apiClient = ApiClient();
  final ConnectivityService _connectivityService = ConnectivityService();
  final RideStorageService _storageService = RideStorageService.instance;

  StreamSubscription<bool>? _connectivitySubscription;

  // Stream controller for sync status updates
  final StreamController<SyncResult> _syncStatusController =
      StreamController<SyncResult>.broadcast();

  Stream<SyncResult> get syncStatusStream => _syncStatusController.stream;

  SyncStatus _currentStatus = SyncStatus.idle;
  SyncStatus get currentStatus => _currentStatus;

  bool _autoSyncEnabled = true;
  bool get autoSyncEnabled => _autoSyncEnabled;

  bool _isSyncing = false;

  /// Initialize the sync service
  Future<void> initialize() async {
    print('Sync Service: Initializing...');

    // Initialize connectivity service
    await _connectivityService.initialize();

    // Listen to connectivity changes for auto-sync
    _connectivitySubscription =
        _connectivityService.connectivityStream.listen((isOnline) {
      print('Sync Service: Connectivity changed - ${isOnline ? "Online" : "Offline"}');

      if (isOnline && _autoSyncEnabled && !_isSyncing) {
        print('Sync Service: Auto-sync triggered by connectivity change');
        syncUnsyncedRides();
      }
    });

    print('Sync Service: Initialized successfully');
  }

  /// Sync all unsynced rides to the server
  Future<SyncResult> syncUnsyncedRides() async {
    if (_isSyncing) {
      print('Sync Service: Sync already in progress, skipping...');
      return SyncResult(
        status: SyncStatus.idle,
        errorMessage: 'Sync already in progress',
      );
    }

    _isSyncing = true;
    _currentStatus = SyncStatus.syncing;
    _syncStatusController.add(SyncResult(status: SyncStatus.syncing));

    print('Sync Service: Starting sync...');

    try {
      // Check connectivity first
      final isOnline = await _connectivityService.checkConnectivity();
      if (!isOnline) {
        print('Sync Service: No internet connection');
        final result = SyncResult(
          status: SyncStatus.error,
          errorMessage: 'No internet connection',
        );
        _currentStatus = SyncStatus.error;
        _syncStatusController.add(result);
        _isSyncing = false;
        return result;
      }

      // Test API connection
      final canConnect = await _apiClient.testConnection();
      if (!canConnect) {
        print('Sync Service: Cannot connect to server');
        final result = SyncResult(
          status: SyncStatus.error,
          errorMessage: 'Cannot connect to server',
        );
        _currentStatus = SyncStatus.error;
        _syncStatusController.add(result);
        _isSyncing = false;
        return result;
      }

      // Get all unsynced rides
      final unsyncedRides = await _storageService.getUnsyncedRides();
      print('Sync Service: Found ${unsyncedRides.length} unsynced rides');

      if (unsyncedRides.isEmpty) {
        print('Sync Service: No rides to sync');
        final result = SyncResult(
          status: SyncStatus.success,
          syncedCount: 0,
        );
        _currentStatus = SyncStatus.success;
        _syncStatusController.add(result);
        _isSyncing = false;
        return result;
      }

      int syncedCount = 0;
      int failedCount = 0;

      // Sync each ride
      for (final ride in unsyncedRides) {
        try {
          print('Sync Service: Syncing ride ${ride.id}...');

          // Get route points for this ride
          final routePoints = await _storageService.getRoutePointsForRide(ride.id);
          print('Sync Service: Ride has ${routePoints.length} route points');

          // Send to server
          await _apiClient.createRide(ride, routePoints);

          // Mark as synced in local database
          await _storageService.markRideAsSynced(ride.id);

          syncedCount++;
          print('Sync Service: Ride ${ride.id} synced successfully');
        } catch (e) {
          print('Sync Service: Failed to sync ride ${ride.id}: $e');
          failedCount++;
        }
      }

      print('Sync Service: Sync complete - $syncedCount synced, $failedCount failed');

      final result = SyncResult(
        status: failedCount == 0 ? SyncStatus.success : SyncStatus.error,
        syncedCount: syncedCount,
        failedCount: failedCount,
        errorMessage: failedCount > 0
            ? 'Failed to sync $failedCount ride(s)'
            : null,
      );

      _currentStatus = result.status;
      _syncStatusController.add(result);
      _isSyncing = false;

      return result;
    } catch (e) {
      print('Sync Service: Sync error: $e');
      final result = SyncResult(
        status: SyncStatus.error,
        errorMessage: 'Sync failed: $e',
      );
      _currentStatus = SyncStatus.error;
      _syncStatusController.add(result);
      _isSyncing = false;
      return result;
    }
  }

  /// Enable or disable auto-sync
  void setAutoSync(bool enabled) {
    _autoSyncEnabled = enabled;
    print('Sync Service: Auto-sync ${enabled ? "enabled" : "disabled"}');
  }

  /// Get count of unsynced rides
  Future<int> getUnsyncedRideCount() async {
    final rides = await _storageService.getUnsyncedRides();
    return rides.length;
  }

  /// Dispose of resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncStatusController.close();
  }
}
