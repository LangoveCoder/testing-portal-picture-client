import 'dart:io';
import 'package:dio/dio.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:otsp_attendance/app/core/services/upload_queue_service.dart';
import 'package:otsp_attendance/app/data/models/upload_queue_model.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/models/student_model.dart';
import '../../../core/values/app_colors.dart';

class PhotoCaptureController extends GetxController {
  final ApiProvider apiProvider = ApiProvider();

  late CameraController cameraController;
  var isCameraInitialized = false.obs;
  var isUploading = false.obs;
  var capturedImage = Rxn<File>();

  StudentModel? student;

  @override
  void onInit() {
    super.onInit();
    student = Get.arguments as StudentModel?;
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        Get.snackbar(
          'Error',
          'No camera found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: AppColors.textWhite,
        );
        return;
      }

      // Use front camera if available, otherwise use first camera
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      cameraController = CameraController(
        camera,
        ResolutionPreset.high,
      );

      await cameraController.initialize();
      isCameraInitialized.value = true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to initialize camera: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.textWhite,
      );
    }
  }

  Future<void> capturePhoto() async {
    if (!cameraController.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await cameraController.takePicture();
      capturedImage.value = File(photo.path);

      Get.snackbar(
        'Success',
        'Photo captured! Review before uploading.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.textWhite,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to capture photo: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.textWhite,
      );
    }
  }

  Future<void> retakePhoto() async {
    capturedImage.value = null;
  }

  Future<void> uploadPhoto() async {
    if (capturedImage.value == null || student == null) {
      Get.snackbar(
        'Error',
        'No photo or student data',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.textWhite,
      );
      return;
    }

    isUploading.value = true;

    try {
      // Get upload queue service
      final queueService = Get.find<UploadQueueService>();

      // Check if online
      final isOnline = await queueService.isOnline();

      if (isOnline) {
        // Try to upload directly
        print('=== DIRECT UPLOAD ===');
        print('Roll Number: ${student!.rollNumber}');
        print('Image Path: ${capturedImage.value!.path}');

        final response = await apiProvider.uploadPhoto(
          student!.rollNumber,
          capturedImage.value!.path,
        );

        print('Response: ${response.data}');

        if (response.data['success'] == true) {
          Get.snackbar(
            'Success',
            'Photo uploaded successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.success,
            colorText: AppColors.textWhite,
            duration: Duration(seconds: 2),
          );

          // Delete local file after successful upload
          await capturedImage.value!.delete();

          // Go back to home
          await Future.delayed(Duration(seconds: 2));
          Get.offAllNamed('/home');
          return;
        }
      }

      // If offline or upload failed, add to queue
      print('=== ADDING TO QUEUE ===');

      final queueItem = UploadQueueModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        rollNumber: student!.rollNumber,
        studentName: student!.name,
        imagePath: capturedImage.value!.path,
        capturedAt: DateTime.now(),
      );

      await queueService.addToQueue(queueItem);

      Get.snackbar(
        isOnline ? 'Queued' : 'Offline',
        isOnline
            ? 'Photo saved. Will retry upload.'
            : 'Photo saved. Will upload when online.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warning,
        colorText: AppColors.textWhite,
        duration: Duration(seconds: 3),
      );

      // Go back to home
      await Future.delayed(Duration(seconds: 2));
      Get.offAllNamed('/home');
    } on DioException catch (e) {
      print('=== DIO ERROR ===');
      print('Error: ${e.response?.data}');

      // Add to queue on error
      final queueService = Get.find<UploadQueueService>();

      final queueItem = UploadQueueModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        rollNumber: student!.rollNumber,
        studentName: student!.name,
        imagePath: capturedImage.value!.path,
        capturedAt: DateTime.now(),
      );

      await queueService.addToQueue(queueItem);

      Get.snackbar(
        'Queued',
        'Photo saved. Will retry upload.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warning,
        colorText: AppColors.textWhite,
        duration: Duration(seconds: 3),
      );

      await Future.delayed(Duration(seconds: 2));
      Get.offAllNamed('/home');
    } catch (e) {
      print('=== ERROR ===');
      print('Error: $e');

      Get.snackbar(
        'Error',
        'Failed to save photo: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.textWhite,
      );
    } finally {
      isUploading.value = false;
    }
  }

  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }
}
