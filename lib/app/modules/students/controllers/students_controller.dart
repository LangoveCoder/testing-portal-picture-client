import 'package:get/get.dart';
import '../../../data/models/student_model.dart';
import '../../../core/services/student_cache_service.dart';
import '../../../core/services/upload_queue_service.dart';
import '../../../core/utils/custom_toast.dart';
import '../../../routes/app_pages.dart';
import '../../test_selection/controllers/test_selection_controller.dart';

class StudentsController extends GetxController {
  final cacheService = Get.find<StudentCacheService>();
  final queueService = Get.find<UploadQueueService>();

  // ✅ Add test selection controller
  TestSelectionController? testController;

  final RxList<StudentModel> allStudents = <StudentModel>[].obs;
  final RxMap<String, bool> serverPhotoStatus = <String, bool>{}.obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString filterStatus = 'all'.obs;

  @override
  void onInit() {
    super.onInit();

    // Try to get test selection controller
    try {
      testController = Get.find<TestSelectionController>();
    } catch (e) {
      print('TestSelectionController not found: $e');
    }

    // Delay loading until after build is complete
    Future.delayed(Duration.zero, () => loadStudents());
  }

  Future<void> loadStudents() async {
    try {
      isLoading.value = true;

      // Get ALL students from cache
      final cachedStudents = cacheService.cachedStudents.values.toList();

      if (cachedStudents.isEmpty) {
        CustomToast.info('No students found. Sync from home screen.');
        allStudents.clear();
        return;
      }

      print('=== LOADING STUDENTS ===');
      print('Total cached: ${cachedStudents.length}');

      // ✅ Filter by selected test if available
      List<StudentModel> filteredStudents;

      if (testController != null && testController!.hasSelectedTest) {
        final selectedTestId = testController!.getSelectedTestId();
        print('Filtering by test ID: $selectedTestId');

        // Filter students by test
        filteredStudents = cachedStudents.where((student) {
          // Match by test name or college name (since we don't have test_id in student model)
          final testName = testController!.selectedTest.value?.testName ?? '';
          return student.testName?.contains(testName) ?? false;
        }).toList();

        print(
            'Filtered to ${filteredStudents.length} students for selected test');

        if (filteredStudents.isEmpty) {
          CustomToast.warning(
              'No students found for selected test. Try different test.');
        }
      } else {
        // No test selected - show all students
        print('No test selected - showing all students');
        filteredStudents = cachedStudents;
      }

      allStudents.value = filteredStudents;
      print('Displaying ${allStudents.length} students');

      // Update photo status
      _updatePhotoStatusFromStudents();
    } catch (e) {
      print('Error loading students: $e');
      CustomToast.error('Failed to load students');
    } finally {
      isLoading.value = false;
    }
  }

  void _updatePhotoStatusFromStudents() {
    for (var student in allStudents) {
      serverPhotoStatus[student.rollNumber] = student.hasPhoto;
    }
    print('Updated photo status for ${serverPhotoStatus.length} students');
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
    var students = allStudents;

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      students = students
          .where((student) {
            return student.rollNumber
                    .toLowerCase()
                    .contains(searchQuery.value) ||
                student.name.toLowerCase().contains(searchQuery.value) ||
                (student.cnic?.toLowerCase().contains(searchQuery.value) ??
                    false);
          })
          .toList()
          .obs;
    }

    // Apply status filter
    if (filterStatus.value != 'all') {
      students = students
          .where((student) {
            bool hasCaptured = hasPhotoCaptured(student.rollNumber);
            if (filterStatus.value == 'captured') {
              return hasCaptured;
            } else if (filterStatus.value == 'pending') {
              return !hasCaptured;
            }
            return true;
          })
          .toList()
          .obs;
    }

    return students;
  }

  bool hasPhotoCaptured(String rollNumber) {
    bool inLocalQueue =
        queueService.uploadQueue.any((item) => item.rollNumber == rollNumber);

    bool onServer = serverPhotoStatus[rollNumber] ?? false;

    final student =
        allStudents.firstWhereOrNull((s) => s.rollNumber == rollNumber);
    bool hasPhotoInModel = student?.hasPhoto ?? false;

    return inLocalQueue || onServer || hasPhotoInModel;
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
