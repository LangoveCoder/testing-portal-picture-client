import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import '../values/app_constants.dart';
import '../../data/models/attendance_student_model.dart';
import '../../data/models/attendance_request_model.dart';
import '../../data/models/attendance_stats_model.dart';
import '../../data/providers/attendance_api_provider.dart';
import 'attendance_offline_service.dart';
import '../utils/custom_toast.dart';

class AttendanceService extends GetxService {
  final AttendanceApiProvider _apiProvider = AttendanceApiProvider();
  final AttendanceOfflineService _offlineService = Get.find<AttendanceOfflineService>();
  final GetStorage _storage = GetStorage();

  var currentTestId = 0.obs;
  var operatorName = ''.obs;
  var deviceInfo = ''.obs;

  // Getters for offline service properties
  bool get isOnline => _offlineService.isOnline.value;
  int get pendingCount => _offlineService.pendingCount;
  bool get isSyncing => _offlineService.isSyncing.value;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _getDeviceInfo();
  }

  /// Load settings from storage
  void _loadSettings() {
    currentTestId.value = _storage.read(AppConstants.currentTestIdKey) ?? 1;
    operatorName.value = _storage.read(AppConstants.operatorNameKey) ?? 'Unknown Operator';
    print('Loaded settings - Test ID: ${currentTestId.value}, Operator: ${operatorName.value}');
  }

  /// Get device information
  Future<void> _getDeviceInfo() async {
    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceInfo.value = 'Android ${androidInfo.version.release}, ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        deviceInfo.value = 'iOS ${iosInfo.systemVersion}, ${iosInfo.model}';
      } else {
        deviceInfo.value = 'Unknown Device';
      }
      print('Device Info: ${deviceInfo.value}');
    } catch (e) {
      deviceInfo.value = 'Unknown Device';
      print('Error getting device info: $e');
    }
  }

  /// Set current test ID
  void setCurrentTestId(int testId) {
    currentTestId.value = testId;
    _storage.write(AppConstants.currentTestIdKey, testId);
    print('Set current test ID: $testId');
  }

  /// Get student information for attendance
  Future<AttendanceStudentModel?> getStudentInfo(String rollNumber) async {
    try {
      print('=== GET STUDENT INFO FOR ATTENDANCE ===');
      print('Roll Number: $rollNumber');
      print('Test ID: ${currentTestId.value}');
      print('API URL: ${AppConstants.baseUrl}${AppConstants.attendanceStudentInfoEndpoint}');

      if (_offlineService.isOnline.value) {
        // Try to fetch from API
        final response = await _apiProvider.getAttendanceStudentInfo(
          rollNumber,
          currentTestId.value,
        );

        print('Student info response: ${response.statusCode}');
        print('Response data: ${response.data}');

        if (response.data['success'] == true) {
          final studentData = response.data['data'];
          final student = AttendanceStudentModel.fromJson(studentData['student']);
          
          print('Student found: ${student.name} (${student.collegeName})');
          return student;
        } else {
          final message = response.data['message'] ?? 'Student not found';
          print('Student not found: $message');
          CustomToast.error(message);
          return null;
        }
      } else {
        CustomToast.warning('Offline mode - Cannot fetch student information');
        return null;
      }
    } catch (e) {
      print('Error getting student info: $e');
      CustomToast.error('Failed to get student information: ${e.toString()}');
      return null;
    }
  }

  /// Mark student attendance
  Future<bool> markAttendance({
    required String rollNumber,
    required String attendanceStatus,
    String? notes,
    LocationModel? location,
  }) async {
    try {
      print('=== MARK ATTENDANCE ===');
      print('Roll Number: $rollNumber');
      print('Status: $attendanceStatus');
      print('Test ID: ${currentTestId.value}');

      // Create attendance request
      final request = AttendanceRequestModel(
        rollNumber: rollNumber,
        testId: currentTestId.value,
        attendanceStatus: attendanceStatus,
        markedBy: operatorName.value,
        deviceInfo: deviceInfo.value,
        notes: notes,
        location: location,
      );

      if (_offlineService.isOnline.value) {
        // Try to mark online
        try {
          final response = await _apiProvider.markAttendance(request);

          if (response.data['success'] == true) {
            CustomToast.success('Attendance marked successfully!');
            return true;
          } else {
            // If online but API fails, store offline
            _offlineService.addPendingRecord(request);
            CustomToast.warning('Stored offline - Will sync when possible');
            return true;
          }
        } catch (e) {
          // If online but network error, store offline
          _offlineService.addPendingRecord(request);
          CustomToast.warning('Network error - Stored offline for sync');
          return true;
        }
      } else {
        // Store offline
        _offlineService.addPendingRecord(request);
        CustomToast.info('Offline mode - Attendance stored for sync');
        return true;
      }
    } catch (e) {
      print('Error marking attendance: $e');
      CustomToast.error('Failed to mark attendance');
      return false;
    }
  }

  /// Update existing attendance
  Future<bool> updateAttendance({
    required String rollNumber,
    required String newStatus,
    String? reason,
  }) async {
    try {
      if (!_offlineService.isOnline.value) {
        CustomToast.warning('Cannot update attendance - Device is offline');
        return false;
      }

      final response = await _apiProvider.updateAttendance(
        rollNumber: rollNumber,
        testId: currentTestId.value,
        attendanceStatus: newStatus,
        updatedBy: operatorName.value,
        reason: reason,
      );

      if (response.data['success'] == true) {
        CustomToast.success('Attendance updated successfully!');
        return true;
      } else {
        CustomToast.error(response.data['message'] ?? 'Failed to update attendance');
        return false;
      }
    } catch (e) {
      print('Error updating attendance: $e');
      CustomToast.error('Failed to update attendance');
      return false;
    }
  }

  /// Get attendance statistics
  Future<AttendanceStatsModel?> getAttendanceStats() async {
    try {
      if (!_offlineService.isOnline.value) {
        CustomToast.warning('Cannot get stats - Device is offline');
        return null;
      }

      final response = await _apiProvider.getAttendanceStats(currentTestId.value);

      if (response.data['success'] == true) {
        return AttendanceStatsModel.fromJson(response.data['data']);
      } else {
        CustomToast.error('Failed to get attendance statistics');
        return null;
      }
    } catch (e) {
      print('Error getting attendance stats: $e');
      CustomToast.error('Failed to get statistics');
      return null;
    }
  }

  /// Force sync pending records
  Future<void> syncPendingRecords() async {
    await _offlineService.forcSync();
  }

  /// Get sync status
  Map<String, dynamic> getSyncStatus() {
    return _offlineService.getSyncStatus();
  }
}