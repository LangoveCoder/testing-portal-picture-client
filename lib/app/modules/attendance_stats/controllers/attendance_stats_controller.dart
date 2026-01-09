import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/attendance_service.dart';
import '../../../data/models/attendance_request_model.dart';
import '../../../data/models/attendance_stats_model.dart';
import '../../../core/utils/custom_toast.dart';

class AttendanceStatsController extends GetxController {
  final AttendanceService _attendanceService = Get.find<AttendanceService>();

  var isLoading = false.obs;
  var stats = Rxn<AttendanceStatsModel>();
  var attendanceRecords = <AttendanceRequestModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  /// Load attendance statistics
  Future<void> loadStats() async {
    isLoading.value = true;

    try {
      // Get real stats from API
      if (_attendanceService.isOnline) {
        final realStats = await _attendanceService.getAttendanceStats();
        if (realStats != null) {
          stats.value = realStats;
        } else {
          CustomToast.error('Failed to load statistics');
        }
      } else {
        CustomToast.warning('Offline mode - Cannot load statistics');
      }
    } catch (e) {
      print('Error loading stats: $e');
      CustomToast.error('Failed to load statistics');
    } finally {
      isLoading.value = false;
    }
  }

  /// Use demo statistics for testing
  void _useDemoStats() {
    // Remove this method - no more demo data
  }

  /// Refresh statistics
  Future<void> refreshStats() async {
    await loadStats();
    CustomToast.success('Statistics refreshed');
  }

  /// Get attendance percentage color
  Color getPercentageColor(double percentage) {
    if (percentage >= 80) {
      return const Color(0xFF10B981); // Green
    } else if (percentage >= 60) {
      return const Color(0xFFF59E0B); // Yellow
    } else {
      return const Color(0xFFEF4444); // Red
    }
  }

  /// Get status color
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return const Color(0xFF10B981); // Green
      case 'absent':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  /// Get status icon
  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Icons.check_circle;
      case 'absent':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  /// Filter records by status
  List<Map<String, dynamic>> getFilteredRecords(String? filter) {
    // TODO: Implement real records filtering when API is ready
    return [];
  }

  /// Export statistics (placeholder)
  void exportStats() {
    CustomToast.info('Export functionality coming soon!');
  }

  /// Get sync status info
  Map<String, dynamic> getSyncInfo() {
    return {
      'is_online': _attendanceService.isOnline,
      'pending_count': _attendanceService.pendingCount,
      'is_syncing': _attendanceService.isSyncing,
    };
  }
}