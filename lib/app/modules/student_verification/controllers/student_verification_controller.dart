import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/attendance_service.dart';
import '../../../data/models/attendance_student_model.dart';
import '../../../core/utils/custom_toast.dart';

class StudentVerificationController extends GetxController {
  final AttendanceService _attendanceService = Get.find<AttendanceService>();

  late AttendanceStudentModel student;
  late String rollNumber;
  
  var isMarking = false.obs;
  var selectedStatus = ''.obs;
  final notesController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    
    // Get arguments
    final args = Get.arguments as Map<String, dynamic>;
    student = args['student'] as AttendanceStudentModel;
    rollNumber = args['roll_number'] as String;
    
    print('=== STUDENT VERIFICATION INIT ===');
    print('Student: ${student.name}');
    print('Roll Number: $rollNumber');
  }

  /// Mark attendance as present
  void markPresent() {
    selectedStatus.value = 'present';
    _showConfirmationDialog('PRESENT');
  }

  /// Mark attendance as absent
  void markAbsent() {
    selectedStatus.value = 'absent';
    _showConfirmationDialog('ABSENT');
  }

  /// Show confirmation dialog
  void _showConfirmationDialog(String status) {
    Get.dialog(
      AlertDialog(
        title: Text('Confirm Attendance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student: ${student.name}'),
            Text('Roll Number: $rollNumber'),
            Text('Father: ${student.fatherName}'),
            const SizedBox(height: 8),
            Text(
              'Status: $status',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: status == 'PRESENT' ? Colors.green : Colors.red,
                fontSize: 16,
              ),
            ),
            if (notesController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Notes: ${notesController.text}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _confirmAttendance();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'PRESENT' ? Colors.green : Colors.red,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  /// Confirm and mark attendance
  Future<void> _confirmAttendance() async {
    if (isMarking.value) return;

    isMarking.value = true;

    try {
      final success = await _attendanceService.markAttendance(
        rollNumber: rollNumber,
        attendanceStatus: selectedStatus.value,
        notes: notesController.text.isNotEmpty ? notesController.text : null,
      );

      if (success) {
        // Show success and go back
        await Future.delayed(const Duration(milliseconds: 500));
        Get.back(); // Go back to QR scanner
        
        // Show success message
        CustomToast.success(
          'Attendance marked: ${student.name} - ${selectedStatus.value.toUpperCase()}'
        );
      }
    } catch (e) {
      print('Error marking attendance: $e');
      CustomToast.error('Failed to mark attendance');
    } finally {
      isMarking.value = false;
    }
  }

  /// Update attendance (if already marked)
  Future<void> updateAttendance(String newStatus) async {
    if (isMarking.value) return;

    Get.dialog(
      AlertDialog(
        title: const Text('Update Attendance'),
        content: Text(
          'Change attendance from ${student.attendance?.attendanceStatus.toUpperCase()} to ${newStatus.toUpperCase()}?'
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              
              isMarking.value = true;
              
              try {
                final success = await _attendanceService.updateAttendance(
                  rollNumber: rollNumber,
                  newStatus: newStatus,
                  reason: 'Updated via mobile app',
                );

                if (success) {
                  Get.back(); // Go back to QR scanner
                  CustomToast.success('Attendance updated successfully');
                }
              } catch (e) {
                CustomToast.error('Failed to update attendance');
              } finally {
                isMarking.value = false;
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }
}