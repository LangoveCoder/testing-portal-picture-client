import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/attendance_stats_controller.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/services/attendance_service.dart';

class AttendanceStatsView extends GetView<AttendanceStatsController> {
  const AttendanceStatsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final attendanceService = Get.find<AttendanceService>();
    
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        title: const Text('Attendance Statistics'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Obx(() => IconButton(
            onPressed: controller.isLoading.value ? null : controller.refreshStats,
            icon: controller.isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh),
          )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.stats.value == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading statistics...'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshStats,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sync Status Card
                _buildSyncStatusCard(context, attendanceService),
                
                const SizedBox(height: 16),
                
                // Statistics Overview
                _buildStatsOverview(context),
                
                const SizedBox(height: 16),
                
                // Recent Records
                _buildRecentRecords(context),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSyncStatusCard(BuildContext context, AttendanceService attendanceService) {
    return Card(
      color: AppColors.getCardBackground(context),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: attendanceService.isOnline 
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                attendanceService.isOnline ? Icons.cloud_done : Icons.cloud_off,
                color: attendanceService.isOnline ? Colors.green : Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attendanceService.isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextPrimary(context),
                    ),
                  ),
                  Text(
                    attendanceService.pendingCount > 0
                        ? '${attendanceService.pendingCount} records pending sync'
                        : 'All records synced',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.getTextSecondary(context),
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

  Widget _buildStatsOverview(BuildContext context) {
    final stats = controller.stats.value;
    if (stats == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(context),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Total Students',
                stats.total.toString(),
                Icons.people,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Present',
                stats.present.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Absent',
                stats.absent.toString(),
                Icons.cancel,
                Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Attendance Rate',
                '${stats.presentPercentage.toStringAsFixed(1)}%',
                Icons.trending_up,
                controller.getPercentageColor(stats.presentPercentage),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      color: AppColors.getCardBackground(context),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.getTextSecondary(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRecords(BuildContext context) {
    return Card(
      color: AppColors.getCardBackground(context),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Records',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            const SizedBox(height: 12),
            
            // Records List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 0, // No demo records
              itemBuilder: (context, index) {
                return const SizedBox(); // Empty for now
              },
            ),
            
            // Show message when no records
            if (true) // Always show for now since no real data
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No recent records available',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}