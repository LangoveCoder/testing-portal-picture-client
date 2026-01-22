import 'package:get/get.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/models/student_model.dart';
import '../../../routes/app_pages.dart';
import '../../../core/services/student_cache_service.dart';
import '../../../core/utils/custom_toast.dart';

class StudentSearchController extends GetxController {
  late ApiProvider apiProvider;
  late StudentCacheService studentCache;

  var isLoading = false.obs;
  var student = Rxn<StudentModel>();
  var rollNumber = ''.obs;
  var isFromCache = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Initialize services
    try {
      apiProvider = Get.find<ApiProvider>();
      studentCache = Get.find<StudentCacheService>();
    } catch (e) {
      print('Error initializing services: $e');
    }

    // Get roll number from arguments
    rollNumber.value = Get.arguments ?? '';
    if (rollNumber.value.isNotEmpty) {
      // Delay search until after build is complete
      Future.delayed(Duration.zero, () => searchStudent());
    }
  }

  // Search student - CACHE FIRST
  Future<void> searchStudent() async {
    if (rollNumber.value.isEmpty) {
      CustomToast.error('Roll number is required');
      return;
    }

    isLoading.value = true;
    isFromCache.value = false;

    try {
      // FIRST: Try cache
      print('Searching from cache for: ${rollNumber.value}');
      final cachedStudent = studentCache.getStudent(rollNumber.value);

      if (cachedStudent != null) {
        student.value = cachedStudent;
        isFromCache.value = true;
        CustomToast.success('Student found');
        isLoading.value = false;
        return;
      }

      // SECOND: Try API if online
      final isOnline = await studentCache.isOnline();

      if (isOnline) {
        print('Not in cache, fetching from API...');

        try {
          final response = await apiProvider.getStudentInfo(rollNumber.value);

          if (response.data['success'] == true) {
            student.value = StudentModel.fromJson(response.data['data']);
            studentCache.addStudent(student.value!);
            CustomToast.success('Student found');
          } else {
            CustomToast.error('Student not found');
            student.value = null;
          }
        } catch (e) {
          print('API Error: $e');
          CustomToast.error('Student not found');
          student.value = null;
        }
      } else {
        CustomToast.error('Student not in cache. Connect to internet.');
        student.value = null;
      }
    } catch (e) {
      print('Search Error: $e');
      CustomToast.error('Error searching student');
      student.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  void goToCamera() {
    if (student.value != null) {
      Get.toNamed(AppRoutes.CAMERA, arguments: student.value);
    } else {
      CustomToast.error('No student selected');
    }
  }

  void goToMarkAttendance() {
    if (student.value != null) {
      Get.toNamed(
        AppRoutes.MARK_ATTENDANCE,
        arguments: {'student': student.value},
      );
    } else {
      CustomToast.error('No student selected');
    }
  }
}
