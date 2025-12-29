import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../core/services/upload_queue_service.dart';
import '../../../data/models/upload_queue_model.dart';

class HistoryController extends GetxController {
  final queueService = Get.find<UploadQueueService>();

  var uploadedItems = <UploadQueueModel>[].obs;
  var pendingItems = <UploadQueueModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  void loadHistory() {
    uploadedItems.value = queueService.getUploadedItems();
    pendingItems.value = queueService.getPendingItems();
  }

  void refresh() {
    loadHistory();
    Get.snackbar(
      'Refreshed',
      'History updated',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 1),
    );
  }

  void retryUpload(UploadQueueModel item) async {
    await queueService.processQueue();
    loadHistory();
  }

  void clearHistory() {
    Get.dialog(
      AlertDialog(
        title: Text('Clear History'),
        content: Text('This will remove all uploaded records. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              queueService.clearQueue();
              loadHistory();
              Get.back();
              Get.snackbar(
                'Cleared',
                'History cleared successfully',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: Text('CLEAR'),
          ),
        ],
      ),
    );
  }
}
