import 'package:get/get.dart';
import '../../../data/models/upload_queue_model.dart';
import '../../../core/services/upload_queue_service.dart';
import '../../../core/utils/helpers.dart';

class HistoryController extends GetxController {
  final uploadQueueService = Get.find<UploadQueueService>();

  final RxList<CapturedStudent> capturedStudents = <CapturedStudent>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCapturedStudents();
  }

  Future<void> loadCapturedStudents() async {
    try {
      isLoading.value = true;

      // Get all queue items (uploaded and pending)
      final items = await uploadQueueService.getAllQueueItems();
      capturedStudents.value = items;
    } catch (e) {
      print('Error loading captured students: $e');
      Helpers.showErrorToast('Failed to load history');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    isRefreshing.value = true;
    await loadCapturedStudents();
    isRefreshing.value = false;
    Helpers.showSuccessToast('History refreshed');
  }

  void searchStudents(String query) {
    searchQuery.value = query.toLowerCase();
  }

  List<CapturedStudent> get filteredStudents {
    if (searchQuery.isEmpty) {
      return capturedStudents;
    }
    return capturedStudents.where((student) {
      return student.rollNumber.toLowerCase().contains(searchQuery.value) ||
          student.studentName.toLowerCase().contains(searchQuery.value);
    }).toList();
  }

  Future<void> retryUpload(CapturedStudent student) async {
    try {
      Helpers.showInfoToast('Retrying upload...');
      await uploadQueueService.processQueue();
      await loadCapturedStudents();
      Helpers.showSuccessToast('Upload completed');
    } catch (e) {
      print('Retry upload error: $e');
      Helpers.showErrorToast('Upload failed. Try again.');
    }
  }

  Future<void> deleteEntry(CapturedStudent student) async {
    try {
      await uploadQueueService.removeFromQueue(student.id); // ✅ Now takes int
      capturedStudents
          .removeWhere((s) => s.id == student.id); // ✅ Better removal
      Helpers.showSuccessToast('Entry deleted');
    } catch (e) {
      print('Delete error: $e');
      Helpers.showErrorToast('Failed to delete entry');
    }
  }
}
