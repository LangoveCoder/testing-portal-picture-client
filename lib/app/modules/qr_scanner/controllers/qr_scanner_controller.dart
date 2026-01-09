import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/services/attendance_service.dart';
import '../../../core/utils/custom_toast.dart';
import '../../../routes/app_pages.dart';

class QRScannerController extends GetxController {
  final AttendanceService _attendanceService = Get.find<AttendanceService>();

  MobileScannerController? scannerController;
  var isScanning = true.obs;
  var isProcessing = false.obs;
  var scannedCode = ''.obs;
  var isFlashOn = false.obs;
  final manualEntryController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    print('=== QR SCANNER CONTROLLER INIT ===');
    scannerController = MobileScannerController();
  }

  /// Handle QR code detection
  void onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null && isScanning.value && !isProcessing.value) {
        handleQRScan(barcode.rawValue!);
        break;
      }
    }
  }

  /// Handle QR code scan
  void handleQRScan(String qrData) async {
    if (isProcessing.value) return;

    isProcessing.value = true;
    pauseScanning();

    try {
      print('=== QR CODE SCANNED ===');
      print('QR Data: $qrData');

      if (qrData.startsWith('BACT:')) {
        // This is our encrypted student QR
        await handleStudentQR(qrData);
      } else if (qrData.startsWith('https://maps.google.com') || 
                 qrData.startsWith('https://goo.gl/maps')) {
        // This is a venue location QR
        handleVenueQR(qrData);
      } else if (RegExp(r'^\d{4,6}$').hasMatch(qrData)) {
        // This is a plain roll number (fallback)
        await handlePlainRollNumber(qrData);
      } else {
        CustomToast.error('Invalid QR code format');
        resumeScanning();
      }
    } catch (e) {
      print('Error handling QR scan: $e');
      CustomToast.error('Error processing QR code');
      resumeScanning();
    } finally {
      isProcessing.value = false;
    }
  }

  /// Handle encrypted student QR code
  Future<void> handleStudentQR(String qrData) async {
    try {
      // Decrypt the QR code
      final rollNumber = decryptStudentQR(qrData);
      
      if (rollNumber != null) {
        print('Decrypted roll number: $rollNumber');
        await processStudentRollNumber(rollNumber);
      } else {
        CustomToast.error('Invalid or corrupted student QR code');
        resumeScanning();
      }
    } catch (e) {
      print('Error decrypting student QR: $e');
      CustomToast.error('Failed to decrypt student QR code');
      resumeScanning();
    }
  }

  /// Handle venue location QR code
  void handleVenueQR(String qrData) {
    CustomToast.info('Venue QR detected. Please scan student QR for attendance.');
    resumeScanning();
  }

  /// Handle plain roll number (fallback)
  Future<void> handlePlainRollNumber(String rollNumber) async {
    print('Plain roll number detected: $rollNumber');
    await processStudentRollNumber(rollNumber);
  }

  /// Process student roll number (common logic)
  Future<void> processStudentRollNumber(String rollNumber) async {
    try {
      CustomToast.info('Looking up student: $rollNumber');

      // Get student information
      final student = await _attendanceService.getStudentInfo(rollNumber);

      if (student != null) {
        // Navigate to student verification screen
        Get.toNamed(
          AppRoutes.STUDENT_VERIFICATION,
          arguments: {
            'student': student,
            'roll_number': rollNumber,
          },
        );
      } else {
        CustomToast.error('Student not found: $rollNumber');
        resumeScanning();
      }
    } catch (e) {
      print('Error processing student: $e');
      CustomToast.error('Failed to get student information');
      resumeScanning();
    }
  }

  /// Decrypt student QR code
  String? decryptStudentQR(String qrData) {
    try {
      // Parse QR format: "BACT:encrypted_data:signature"
      final parts = qrData.split(':');
      
      if (parts.length != 3 || parts[0] != 'BACT') {
        return null;
      }

      final encryptedData = parts[1];
      final signature = parts[2];

      // Verify signature (basic check)
      if (!verifySignature(encryptedData, signature)) {
        return null;
      }

      // Decrypt the roll number (simple base64 decode for now)
      // In production, use proper encryption
      try {
        final decoded = utf8.decode(base64.decode(encryptedData));
        return decoded;
      } catch (e) {
        return null;
      }
    } catch (e) {
      print('Error decrypting QR: $e');
      return null;
    }
  }

  /// Verify QR signature (basic implementation)
  bool verifySignature(String data, String signature) {
    // Simple signature verification
    // In production, use proper cryptographic verification
    final expectedSignature = generateSignature(data);
    return signature == expectedSignature;
  }

  /// Generate signature for QR code
  String generateSignature(String data) {
    // Simple signature generation
    // In production, use proper cryptographic signing
    return data.hashCode.toString();
  }

  /// Manual roll number entry
  void enterRollNumberManually() {
    Get.dialog(
      AlertDialog(
        title: const Text('Enter Roll Number'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Roll Number',
                hintText: 'Enter 4-6 digit roll number',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                Get.back();
                if (value.isNotEmpty && RegExp(r'^\d{4,6}$').hasMatch(value)) {
                  handleQRScan(value);
                } else {
                  CustomToast.error('Please enter a valid roll number (4-6 digits)');
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Pause scanning
  void pauseScanning() {
    isScanning.value = false;
    scannerController?.stop();
  }

  /// Resume scanning
  void resumeScanning() {
    isScanning.value = true;
    scannerController?.start();
  }

  /// Toggle flashlight
  void toggleFlash() {
    isFlashOn.value = !isFlashOn.value;
    scannerController?.toggleTorch();
  }

  @override
  void onClose() {
    scannerController?.dispose();
    manualEntryController.dispose();
    super.onClose();
  }
}