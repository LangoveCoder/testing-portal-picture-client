import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/mark_attendance_controller.dart';
import '../../../core/values/app_colors.dart';

class MarkAttendanceView extends GetView<MarkAttendanceController> {
  const MarkAttendanceView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        final student = controller.student.value;

        if (student == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  'No student selected',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.getTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('GO BACK'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Student Info Card
              _buildStudentInfoCard(context, student),

              const SizedBox(height: 24),

              // Attendance Status Selection
              _buildStatusSelection(context),

              const SizedBox(height: 32),

              // Submit Button
              _buildSubmitButton(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStudentInfoCard(BuildContext context, student) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(context),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Student Avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: student.picture != null
                ? ClipOval(
                    child: Image.network(
                      student.picture!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 50,
                    color: AppColors.primary,
                  ),
          ),

          const SizedBox(height: 16),

          // Student Name
          Text(
            student.name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(context),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Roll Number
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Roll No: ${student.rollNumber}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Additional Info
          _buildInfoRow(context, Icons.person_outline, 'Father: ${student.fatherName}'),
          if (student.collegeName != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(context, Icons.school, student.collegeName!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.getTextSecondary(context)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(context),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.camera_alt, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Attendance Photo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(context),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Obx(() {
            final photoPath = controller.capturedPhotoPath.value;

            if (photoPath != null) {
              return Column(
                children: [
                  // Photo Preview
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(photoPath),
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controller.showPhotoSourceDialog,
                          icon: const Icon(Icons.refresh),
                          label: const Text('RETAKE'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controller.removePhoto,
                          icon: const Icon(Icons.delete),
                          label: const Text('REMOVE'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            } else {
              // No Photo - Show Capture Button
              return OutlinedButton.icon(
                onPressed: controller.showPhotoSourceDialog,
                icon: const Icon(Icons.add_a_photo),
                label: const Text('CAPTURE PHOTO'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildStatusSelection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(context),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Attendance Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(context),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Obx(() {
            return Column(
              children: [
                _buildStatusButton(
                  context,
                  'present',
                  'Present',
                  Icons.check_circle,
                  AppColors.success,
                ),
                const SizedBox(height: 12),
                _buildStatusButton(
                  context,
                  'late',
                  'Late',
                  Icons.access_time,
                  Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildStatusButton(
                  context,
                  'absent',
                  'Absent',
                  Icons.cancel,
                  AppColors.error,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatusButton(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = controller.selectedStatus.value == value;

    return InkWell(
      onTap: () => controller.setStatus(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.1)
              : AppColors.getInputBackground(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.getBorder(context),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.getTextSecondary(context),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? color
                      : AppColors.getTextPrimary(context),
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Obx(() {
      final isSubmitting = controller.isSubmitting.value;

      return ElevatedButton(
        onPressed: isSubmitting ? null : controller.confirmSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'MARK ATTENDANCE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      );
    });
  }
}
