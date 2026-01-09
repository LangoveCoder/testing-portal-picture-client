import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../values/app_constants.dart';
import '../../data/models/attendance_request_model.dart';
import '../../data/providers/attendance_api_provider.dart';
import '../utils/custom_toast.dart';

class AttendanceOfflineService extends GetxService {
  final GetStorage _storage = GetStorage();
  final AttendanceApiProvider _apiProvider = AttendanceApiProvider();
  final Connectivity _connectivity = Connectivity();

  var pendingRecords = <AttendanceRequestModel>[].obs;
  var isSyncing = false.obs;
  var isOnline = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPendingRecords();
    _checkConnectivity();
    _setupConnectivityListener();
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

  /// Sync pending attendance records
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

      // Attempt to sync records
      final response = await _apiProvider.bulkMarkAttendance(pendingRecords.toList());

      if (response.data['success'] == true) {
        final bulkResponse = BulkAttendanceResponseModel.fromJson(response.data);
        
        print('Sync completed: ${bulkResponse.summary.successful} successful, ${bulkResponse.summary.failed} failed');

        // Remove successfully synced records
        final successfulRollNumbers = bulkResponse.results
            .where((result) => result.success)
            .map((result) => result.rollNumber)
            .toList();

        removeSyncedRecords(successfulRollNumbers);

        // Show sync result
        if (bulkResponse.summary.failed == 0) {
          CustomToast.success('All ${bulkResponse.summary.successful} records synced successfully!');
        } else {
          CustomToast.warning(
            'Synced ${bulkResponse.summary.successful} records. ${bulkResponse.summary.failed} failed.',
          );
        }

        return bulkResponse.summary.failed == 0;
      } else {
        CustomToast.error('Sync failed: ${response.data['message']}');
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