import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../values/app_constants.dart';
import '../../data/models/attendance_request_model.dart';
import '../../data/providers/sync_api_provider.dart';
import '../utils/custom_toast.dart';
import 'auth_service.dart';

class AttendanceOfflineService extends GetxService {
  final GetStorage _storage = GetStorage();
  final SyncApiProvider _syncApiProvider = SyncApiProvider();
  final Connectivity _connectivity = Connectivity();
  late String _deviceId;

  var pendingRecords = <AttendanceRequestModel>[].obs;
  var isSyncing = false.obs;
  var isOnline = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeDeviceId();
    _loadPendingRecords();
    _checkConnectivity();
    _setupConnectivityListener();
    setAuthToken();
  }

  /// Set auth token from AuthService
  void setAuthToken() {
    try {
      final authService = Get.find<AuthService>();
      if (authService.isAuthenticated.value && authService.authToken.value.isNotEmpty) {
        _syncApiProvider.setAuthToken(authService.authToken.value);
        print('[AttendanceOfflineService] Auth token set from AuthService');
      }
    } catch (e) {
      print('[AttendanceOfflineService] Could not get auth token: $e');
    }
  }

  /// Initialize device ID
  Future<void> _initializeDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      _deviceId = 'android_${androidInfo.id}';
      print('Device ID: $_deviceId');
    } catch (e) {
      print('Error getting device ID: $e');
      _deviceId = 'android_device_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Load pending attendance records from storage
  void _loadPendingRecords() {
    try {
      final stored = _storage.read(AppConstants.pendingAttendanceKey);
      if (stored != null) {
        final List<dynamic> jsonList = jsonDecode(stored);
        pendingRecords.value = jsonList
            .map((json) => AttendanceRequestModel.fromJson(json))
            .toList();
        print('Loaded ${pendingRecords.length} pending attendance records');
      }
    } catch (e) {
      print('Error loading pending records: $e');
      pendingRecords.clear();
    }
  }

  /// Save pending records to storage
  void _savePendingRecords() {
    try {
      final jsonList = pendingRecords.map((record) => record.toJson()).toList();
      _storage.write(AppConstants.pendingAttendanceKey, jsonEncode(jsonList));
      print('Saved ${pendingRecords.length} pending records');
    } catch (e) {
      print('Error saving pending records: $e');
    }
  }

  /// Add attendance record to offline queue
  void addPendingRecord(AttendanceRequestModel record) {
    // Check if record already exists (prevent duplicates)
    final existingIndex = pendingRecords.indexWhere(
      (r) => r.rollNumber == record.rollNumber && r.testId == record.testId,
    );

    if (existingIndex != -1) {
      // Update existing record
      pendingRecords[existingIndex] = record.copyWith(
        offlineMarkedAt: DateTime.now(),
        synced: false,
      );
    } else {
      // Add new record
      pendingRecords.add(record.copyWith(
        offlineMarkedAt: DateTime.now(),
        synced: false,
      ));
    }

    _savePendingRecords();
    print('Added attendance record for ${record.rollNumber} to offline queue');
  }

  /// Remove synced records from queue
  void removeSyncedRecords(List<String> rollNumbers) {
    pendingRecords.removeWhere((record) => rollNumbers.contains(record.rollNumber));
    _savePendingRecords();
    print('Removed ${rollNumbers.length} synced records from queue');
  }

  /// Get pending records count
  int get pendingCount => pendingRecords.length;

  /// Check if there are pending records
  bool get hasPendingRecords => pendingRecords.isNotEmpty;

  /// Check network connectivity
  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final wasOnline = isOnline.value;
      isOnline.value = result != ConnectivityResult.none;

      // If we just came online and have pending records, sync them
      if (!wasOnline && isOnline.value && hasPendingRecords) {
        print('Device came online with $pendingCount pending records');
        await syncPendingRecords();
      }
    } catch (e) {
      print('Error checking connectivity: $e');
      isOnline.value = false;
    }
  }

  /// Setup connectivity listener
  void _setupConnectivityListener() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      final wasOnline = isOnline.value;
      isOnline.value = result != ConnectivityResult.none;

      print('Connectivity changed: ${isOnline.value ? 'Online' : 'Offline'}');

      // If we just came online and have pending records, sync them
      if (!wasOnline && isOnline.value && hasPendingRecords) {
        print('Auto-syncing $pendingCount pending records');
        syncPendingRecords();
      }
    });
  }

  /// Sync pending attendance records using official sync API
  Future<bool> syncPendingRecords() async {
    if (isSyncing.value) {
      print('Sync already in progress');
      return false;
    }

    if (pendingRecords.isEmpty) {
      print('No pending records to sync');
      return true;
    }

    if (!isOnline.value) {
      print('Cannot sync - device is offline');
      CustomToast.warning('Cannot sync - device is offline');
      return false;
    }

    isSyncing.value = true;

    try {
      print('=== SYNCING ${pendingRecords.length} ATTENDANCE RECORDS ===');

      CustomToast.info('Syncing ${pendingRecords.length} attendance records...');

      // Step 1: Queue attendance records for sync
      final payload = pendingRecords.map((record) {
        return {
          'roll_number': record.rollNumber,
          'test_id': record.testId,
          'attendance_status': record.attendanceStatus,
          'marked_at': record.offlineMarkedAt?.toIso8601String() ??
                       DateTime.now().toIso8601String(),
        };
      }).toList();

      final queueResponse = await _syncApiProvider.queueSync(
        deviceId: _deviceId,
        syncType: 'attendance',
        payload: payload,
      );

      if (queueResponse.data['success'] != true) {
        CustomToast.error('Failed to queue sync: ${queueResponse.data['message']}');
        return false;
      }

      print('Queued ${queueResponse.data['queued_records']} records');

      // Step 2: Process the sync
      final processResponse = await _syncApiProvider.processSync(
        deviceId: _deviceId,
      );

      if (processResponse.data['success'] == true) {
        final processed = processResponse.data['processed'] ?? 0;
        final failed = processResponse.data['failed'] ?? 0;

        print('Sync completed: $processed processed, $failed failed');

        // Remove all pending records if sync was successful
        if (failed == 0) {
          clearPendingRecords();
          CustomToast.success('All $processed records synced successfully!');
          return true;
        } else {
          // Partial success - clear successful records
          // Note: The API should return which records failed, but for now we'll keep all
          CustomToast.warning('Synced $processed records. $failed failed.');
          return false;
        }
      } else {
        CustomToast.error('Sync processing failed: ${processResponse.data['message']}');
        return false;
      }
    } catch (e) {
      print('Sync error: $e');
      CustomToast.error('Sync failed: Network error');
      return false;
    } finally {
      isSyncing.value = false;
    }
  }

  /// Get sync status from API
  Future<Map<String, dynamic>?> getApiSyncStatus() async {
    try {
      final response = await _syncApiProvider.getSyncStatus(deviceId: _deviceId);

      if (response.data['success'] == true) {
        return {
          'pending_count': response.data['pending_count'] ?? 0,
          'completed_count': response.data['completed_count'] ?? 0,
          'failed_count': response.data['failed_count'] ?? 0,
          'last_sync_at': response.data['last_sync_at'],
        };
      }
      return null;
    } catch (e) {
      print('Error getting sync status: $e');
      return null;
    }
  }

  /// Clear completed sync records from API
  Future<bool> clearCompletedApiRecords() async {
    try {
      final response = await _syncApiProvider.clearCompletedSync(deviceId: _deviceId);

      if (response.data['success'] == true) {
        print('Cleared ${response.data['cleared_count']} completed records from API');
        return true;
      }
      return false;
    } catch (e) {
      print('Error clearing completed records: $e');
      return false;
    }
  }

  /// Force sync (manual trigger)
  Future<void> forcSync() async {
    if (!isOnline.value) {
      CustomToast.warning('Cannot sync - device is offline');
      return;
    }

    if (pendingRecords.isEmpty) {
      CustomToast.info('No pending records to sync');
      return;
    }

    await syncPendingRecords();
  }

  /// Clear all pending records (use with caution)
  void clearPendingRecords() {
    pendingRecords.clear();
    _storage.remove(AppConstants.pendingAttendanceKey);
    print('Cleared all pending attendance records');
  }

  /// Get sync status info
  Map<String, dynamic> getSyncStatus() {
    return {
      'pending_count': pendingCount,
      'is_syncing': isSyncing.value,
      'is_online': isOnline.value,
      'has_pending': hasPendingRecords,
    };
  }
}