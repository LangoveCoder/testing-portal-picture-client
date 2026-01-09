import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../controllers/history_controller.dart';
import '../../../core/values/app_colors.dart';
import '../../../data/models/upload_queue_model.dart'; // ✅ ADD THIS LINE
import 'package:intl/intl.dart';

class HistoryView extends GetView<HistoryController> {
  final TextEditingController searchController = TextEditingController();

  HistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        title: Text(
          'Captured Photos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: TextField(
              controller: searchController,
              onChanged: (value) => controller.searchStudents(value),
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by roll number or name...',
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          searchController.clear();
                          controller.searchStudents('');
                        },
                      )
                    : SizedBox.shrink()),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          SizedBox(height: 16),

          // Stats Summary
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() => Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Total',
                        '${controller.capturedStudents.length}',
                        Icons.photo_camera,
                        AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Pending',
                        '${controller.capturedStudents.where((s) => !s.isUploaded).length}',
                        Icons.cloud_upload,
                        AppColors.warning,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Uploaded',
                        '${controller.capturedStudents.where((s) => s.isUploaded).length}',
                        Icons.check_circle,
                        AppColors.success,
                      ),
                    ),
                  ],
                )),
          ),

          SizedBox(height: 16),

          // Students List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final students = controller.filteredStudents;

              if (students.isEmpty) {
                return _buildEmptyState(context);
              }

              return RefreshIndicator(
                onRefresh: controller.refresh,
                color: AppColors.primary,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    return _buildStudentCard(context, students[index]);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(context),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.getTextSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, CapturedStudent student) {
    final dateFormatter = DateFormat('MMM dd, yyyy • hh:mm a');

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(context),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with Roll Number and Status
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: student.isUploaded
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Roll No: ${student.rollNumber}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextPrimary(context),
                        ),
                      ),
                      Text(
                        student.studentName,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.getTextSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(student.isUploaded),
              ],
            ),
          ),

          // Photo Preview
          if (student.photoPath.isNotEmpty)
            Container(
              width: double.infinity,
              height: 250,
              child: ClipRRect(
                borderRadius: BorderRadius.zero,
                child: Image.file(
                  File(student.photoPath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.getTextMuted(context).withOpacity(0.1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image,
                              size: 48, color: AppColors.getTextMuted(context)),
                          SizedBox(height: 8),
                          Text('Image not found',
                              style: TextStyle(color: AppColors.getTextMuted(context))),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

          // Footer with Timestamp and Actions
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 14, color: AppColors.getTextMuted(context)),
                    SizedBox(width: 4),
                    Text(
                      dateFormatter.format(student.capturedAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getTextMuted(context),
                      ),
                    ),
                    Spacer(),
                    if (!student.isUploaded) ...[
                      TextButton.icon(
                        onPressed: () => controller.retryUpload(student),
                        icon: Icon(Icons.refresh, size: 16),
                        label: Text('Retry'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                      SizedBox(width: 4),
                      IconButton(
                        onPressed: () => _showDeleteDialog(context, student),
                        icon: Icon(Icons.delete_outline,
                            color: AppColors.error, size: 20),
                        padding: EdgeInsets.all(4),
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isUploaded) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isUploaded ? AppColors.success : AppColors.warning,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUploaded ? Icons.cloud_done : Icons.cloud_upload,
            color: Colors.white,
            size: 14,
          ),
          SizedBox(width: 4),
          Text(
            isUploaded ? 'Uploaded' : 'Pending',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: AppColors.getTextMuted(context),
          ),
          SizedBox(height: 16),
          Text(
            'No photos captured yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextSecondary(context),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start capturing student photos\nfrom the home screen',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextMuted(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, CapturedStudent student) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.getCardBackground(context),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            SizedBox(width: 12),
            Text(
              'Delete Entry',
              style: TextStyle(color: AppColors.getTextPrimary(context)),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this entry?\n\nRoll No: ${student.rollNumber}\nName: ${student.studentName}',
          style: TextStyle(color: AppColors.getTextPrimary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'CANCEL',
              style: TextStyle(color: AppColors.getTextSecondary(context)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteEntry(student);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(
              'DELETE',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
