import 'package:get/get.dart';
import 'package:otsp_attendance/app/core/values/app_constants.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/models/student_model.dart';
import '../../../routes/app_pages.dart';
import '../../../core/services/student_cache_service.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/models/college_model.dart';
import '../../../core/utils/custom_toast.dart';

class StudentSearchController extends GetxController {
  final ApiProvider apiProvider = ApiProvider();
  final studentCache = Get.find<StudentCacheService>();

  var isLoading = false.obs;
  var student = Rxn<StudentModel>();
  var rollNumber = ''.obs;
  var isFromCache = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Get roll number from arguments
    rollNumber.value = Get.arguments ?? '';
    if (rollNumber.value.isNotEmpty) {
      searchStudent();
    }
  }

  // Search student by roll number
  // Search student by roll number
  Future<void> searchStudent() async {
    if (rollNumber.value.isEmpty) {
      CustomToast.error('Roll number is required');
      return;
    }

    isLoading.value = true;
    isFromCache.value = false;

    try {
      // Check if online
      final isOnline = await studentCache.isOnline();

      if (isOnline) {
        // Try to fetch from API
        print('Fetching student from API...');
        final response = await apiProvider.getStudentInfo(rollNumber.value);

        if (response.data['success'] == true) {
          student.value = StudentModel.fromJson(response.data['data']);

          // VALIDATE: Check if student belongs to selected college
          final storage = GetStorage();
          final collegeJson = storage.read(AppConstants.selectedCollegeKey);

          if (collegeJson != null) {
            final selectedCollege = CollegeModel.fromJson(collegeJson);

            // Check if test name matches college name (simple validation)
            // In production, you'd match by college_id from the API
            if (!student.value!.testName.contains(selectedCollege.name)) {
              CustomToast.error(
                'Access Denied\nThis student belongs to a different college.\nYou can only access students from: ${selectedCollege.name}',
              );
              student.value = null;
              isLoading.value = false;
              return;
            }
          }

          // Save to cache for offline use
          studentCache.addStudent(student.value!);

          CustomToast.success('Student found');
        } else {
          // If not found in API, try cache
          await _searchFromCache();
        }
      } else {
        // Offline - search from cache
        print('Offline - searching from cache...');
        await _searchFromCache();
      }
    } catch (e) {
      print('API Error: $e');
      // On error, try cache
      await _searchFromCache();
    } finally {
      isLoading.value = false;
    }
  }

  // Search from cache
  Future<void> _searchFromCache() async {
    print('Searching from cache for: ${rollNumber.value}');

    final cachedStudent = studentCache.getStudent(rollNumber.value);

    if (cachedStudent != null) {
      student.value = cachedStudent;
      isFromCache.value = true;

      CustomToast.warning('Offline Mode\nShowing cached student data');
    } else {
      CustomToast.error('Student not found in cache. Please connect to internet.');
    }
  }

  // Navigate to camera
  void goToCamera() {
    final currentStudent = student.value;

    if (currentStudent != null) {
      Get.toNamed(AppRoutes.CAMERA, arguments: currentStudent);
    } else {
      CustomToast.error('No student selected');
    }
  }
}
