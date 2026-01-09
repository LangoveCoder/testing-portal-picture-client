import 'package:get/get.dart';
import '../../../data/models/student_model.dart';
import '../../../core/services/student_cache_service.dart';
import '../../../core/services/upload_queue_service.dart';
import '../../../core/utils/helpers.dart';
import '../../../routes/app_pages.dart';

class StudentsController extends GetxController {
  final cacheService = Get.find<StudentCacheService>();
  final queueService = Get.find<UploadQueueService>();

  final RxList<StudentModel> allStudents = <StudentModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString filterStatus = 'all'.obs; // all, captured, pending

  @override
  void onInit() {
    super.onInit();
    loadStudents();
  }

  Future<void> loadStudents() async {
    try {
      isLoading.value = true;

      // Get students from cache (convert Map to List)
      final cachedStudents = cacheService.cachedStudents.values.toList();

      if (cachedStudents.isEmpty) {
        Helpers.showInfoToast('No students found. Sync from home screen.');
      }

      allStudents.value = cachedStudents;
    } catch (e) {
      print('Error loading students: $e');
      Helpers.showErrorToast('Failed to load students');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    await cacheService.syncStudents();
    await loadStudents();
  }

  void searchStudents(String query) {
    searchQuery.value = query.toLowerCase();
  }

  void setFilter(String status) {
    filterStatus.value = status;
  }

  List<StudentModel> get filteredStudents {
    List<StudentModel> students = allStudents.toList();

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value;
      students = students.where((student) {
        return student.rollNumber.toLowerCase().contains(q) ||
            student.name.toLowerCase().contains(q) ||
            student.cnic.toLowerCase().contains(q);
      }).toList();
    }

    // Apply status filter
    if (filterStatus.value != 'all') {
      students = students.where((student) {
        final hasCaptured = hasPhotoCaptured(student.rollNumber);
        if (filterStatus.value == 'captured') return hasCaptured;
        if (filterStatus.value == 'pending') return !hasCaptured;
        return true;
      }).toList();
    }

    return students;
  }

  bool hasPhotoCaptured(String rollNumber) {
    return queueService.uploadQueue
        .any((item) => item.rollNumber == rollNumber);
  }

  String? getPhotoPath(String rollNumber) {
    try {
      final item = queueService.uploadQueue.firstWhere(
        (item) => item.rollNumber == rollNumber,
      );
      return item.imagePath;
    } catch (e) {
      return null;
    }
  }

  void goToCapturePhoto(StudentModel student) {
    Get.toNamed(
      AppRoutes.CAMERA,
      arguments: student,
    );
  }

  int get totalStudents => allStudents.length;
  int get capturedCount =>
      allStudents.where((s) => hasPhotoCaptured(s.rollNumber)).length;
  int get pendingCount => totalStudents - capturedCount;
}
