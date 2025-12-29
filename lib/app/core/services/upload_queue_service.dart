import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/models/upload_queue_model.dart';
import '../../data/providers/api_provider.dart';

class UploadQueueService extends GetxService {
  final GetStorage storage = GetStorage();
  final ApiProvider apiProvider = ApiProvider();
  final Connectivity connectivity = Connectivity();

  static const String queueKey = 'upload_queue';

  var uploadQueue = <UploadQueueModel>[].obs;
  var isUploading = false.obs;
  var pendingCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadQueue();
    listenToConnectivity();
  }

  // Load queue from storage
  void loadQueue() {
    try {
      final queueData = storage.read(queueKey);
      if (queueData != null) {
        final List<dynamic> jsonList = jsonDecode(queueData);
        uploadQueue.value =
            jsonList.map((json) => UploadQueueModel.fromJson(json)).toList();
        updatePendingCount();
      }
    } catch (e) {
      print('Error loading queue: $e');
    }
  }

  // Save queue to storage
  void saveQueue() {
    try {
      final jsonList = uploadQueue.map((item) => item.toJson()).toList();
      storage.write(queueKey, jsonEncode(jsonList));
      updatePendingCount();
    } catch (e) {
      print('Error saving queue: $e');
    }
  }

  // Add item to queue
  Future<void> addToQueue(UploadQueueModel item) async {
    uploadQueue.add(item);
    saveQueue();

    // Try to upload immediately if online
    if (await isOnline()) {
      processQueue();
    }
  }

  // Check if online
  Future<bool> isOnline() async {
    try {
      final result = await connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  // Listen to connectivity changes
  void listenToConnectivity() {
    connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        print('Internet connected - processing queue');
        processQueue();
      }
    });
  }

  // Process upload queue
  Future<void> processQueue() async {
    if (isUploading.value || uploadQueue.isEmpty) {
      return;
    }

    if (!await isOnline()) {
      print('No internet connection');
      return;
    }

    isUploading.value = true;

    try {
      // Get pending items
      final pendingItems =
          uploadQueue.where((item) => !item.isUploaded).toList();

      for (var item in pendingItems) {
        try {
          print('Uploading: ${item.rollNumber}');

          // Check if file still exists
          final file = File(item.imagePath);
          if (!await file.exists()) {
            print('File not found: ${item.imagePath}');
            removeFromQueue(item.id);
            continue;
          }

          // Upload photo
          final response = await apiProvider.uploadPhoto(
            item.rollNumber,
            item.imagePath,
          );

          if (response.data['success'] == true) {
            print('Upload successful: ${item.rollNumber}');

            // Mark as uploaded
            final index = uploadQueue.indexWhere((i) => i.id == item.id);
            if (index != -1) {
              uploadQueue[index] = item.copyWith(isUploaded: true);
              saveQueue();
            }

            // Delete local file after successful upload
            await file.delete();
          }
        } catch (e) {
          print('Upload failed for ${item.rollNumber}: $e');

          // Update error message
          final index = uploadQueue.indexWhere((i) => i.id == item.id);
          if (index != -1) {
            uploadQueue[index] = item.copyWith(
              errorMessage: e.toString(),
            );
            saveQueue();
          }
        }
      }

      // Clean up uploaded items after 24 hours
      cleanupQueue();
    } finally {
      isUploading.value = false;
    }
  }

  // Remove item from queue
  void removeFromQueue(String id) {
    uploadQueue.removeWhere((item) => item.id == id);
    saveQueue();
  }

  // Cleanup old uploaded items
  void cleanupQueue() {
    final now = DateTime.now();
    uploadQueue.removeWhere((item) {
      if (item.isUploaded) {
        final age = now.difference(item.capturedAt);
        return age.inHours > 24; // Remove after 24 hours
      }
      return false;
    });
    saveQueue();
  }

  // Update pending count
  void updatePendingCount() {
    pendingCount.value = uploadQueue.where((item) => !item.isUploaded).length;
  }

  // Get pending items
  List<UploadQueueModel> getPendingItems() {
    return uploadQueue.where((item) => !item.isUploaded).toList();
  }

  // Get uploaded items
  List<UploadQueueModel> getUploadedItems() {
    return uploadQueue.where((item) => item.isUploaded).toList();
  }

  // Clear all queue
  void clearQueue() {
    uploadQueue.clear();
    saveQueue();
  }
}
