import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/student_model.dart';
import '../../../core/services/attendance_service.dart';
import '../../../core/utils/custom_toast.dart';
import '../../../routes/app_pages.dart';

class MarkAttendanceController extends GetxController {
  final AttendanceService attendanceService = Get.find<AttendanceService>();
  final ImagePicker _picker = ImagePicker();

  // Student data
  var student = Rxn<StudentModel>();
  var capturedPhotoPath = Rxn<String>();
  var isSubmitting = false.obs;

  // Attendance status
  var selectedStatus = 'present'.obs; // present, absent, late

  @override
  void onInit() {
    super.onInit();

    // Get student from navigation arguments
    final args = Get.arguments;
    if (args != null && args is Map && args.containsKey('student')) {
      student.value = args['student'] as StudentModel;
      print('Student loaded: ${student.value?.name}');
    }
  }

  /// Capture photo using camera
  Future<void> capturePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );

      if (photo != null) {
        capturedPhotoPath.value = photo.path;
        print('Photo captured: ${photo.path}');
        CustomToast.success('Photo captured successfully');
      }
    } catch (e) {
      print('Error capturing photo: $e');
      CustomToast.error('Failed to capture photo: ${e.toString()}');
    }
  }

  /// Pick photo from gallery (fallback)
  Future<void> pickFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (photo != null) {
        capturedPhotoPath.value = photo.path;
        print('Photo selected: ${photo.path}');
        CustomToast.success('Photo selected successfully');
      }
    } catch (e) {
      print('Error picking photo: $e');
      CustomToast.error('Failed to pick photo: ${e.toString()}');
    }
  }

  /// Show photo source selection dialog
  void showPhotoSourceDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Choose Photo Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Get.back();
                capturePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Get.back();
                pickFromGallery();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );
  }

  /// Remove captured photo
  void removePhoto() {
    capturedPhotoPath.value = null;
    CustomToast.info('Photo removed');
  }

  /// Change attendance status
  void setStatus(String status) {
    selectedStatus.value = status;

    // If absent is selected, immediately submit without photo
    if (status == 'absent') {
      submitAttendanceDirectly();
    }
  }

  /// Submit attendance directly without confirmation (for absent)
  Future<void> submitAttendanceDirectly() async {
    if (student.value == null) {
      CustomToast.error('No student selected');
      return;
    }

    isSubmitting.value = true;

    try {
      print('=== SUBMITTING ABSENT ATTENDANCE ===');
      print('Student: ${student.value!.name}');
      print('Roll Number: ${student.value!.rollNumber}');
      print('Status: ABSENT');

      final success = await attendanceService.markAttendance(
        rollNumber: student.value!.rollNumber,
        attendanceStatus: 'absent',
        notes: 'Student marked as absent',
      );

      if (success) {
        CustomToast.success('Student marked as absent');
        // Go back to first page (home)
        Get.until((route) => route.isFirst);
      } else {
        CustomToast.error('Failed to mark attendance');
      }
    } catch (e) {
      print('Error submitting attendance: $e');
      CustomToast.error('Error: ${e.toString()}');
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Submit attendance
  Future<void> submitAttendance() async {
    if (student.value == null) {
      CustomToast.error('No student selected');
      return;
    }

    isSubmitting.value = true;

    try {
      print('=== SUBMITTING ATTENDANCE ===');
      print('Student: ${student.value!.name}');
      print('Roll Number: ${student.value!.rollNumber}');
      print('Status: ${selectedStatus.value}');

      // Use AttendanceService to mark attendance
      final success = await attendanceService.markAttendance(
        rollNumber: student.value!.rollNumber,
        attendanceStatus: selectedStatus.value,
        notes: null,
      );

      if (success) {
        CustomToast.success('Attendance marked successfully!');

        // Go back to home screen
        Get.until((route) => route.isFirst);
      } else {
        CustomToast.error('Failed to mark attendance');
      }
    } catch (e) {
      print('Error submitting attendance: $e');
      CustomToast.error('Error: ${e.toString()}');
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Confirm and submit
  void confirmSubmit() {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Attendance'),
        content: Text(
          'Mark ${student.value?.name} as ${selectedStatus.value.toUpperCase()}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              submitAttendance();
            },
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    );
  }
}
