import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/services/attendance_service.dart';
import '../../../data/models/test_model.dart';
import '../../../data/models/college_model.dart';
import '../../../data/providers/api_provider.dart';
import '../../../core/values/app_constants.dart';
import '../../../core/utils/custom_toast.dart';
import '../../../routes/app_pages.dart';

class TestSelectionController extends GetxController {
  final AttendanceService _attendanceService = Get.find<AttendanceService>();
  final ApiProvider _apiProvider = ApiProvider();
  final GetStorage _storage = GetStorage();

  var isLoading = false.obs;
  var tests = <TestModel>[].obs;
  var selectedTest = Rxn<TestModel>();
  var searchQuery = ''.obs;
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadTests();
    loadSelectedTest();
  }

  /// Load available tests
  Future<void> loadTests() async {
    isLoading.value = true;

    try {
      // Get current operator and college info
      final operatorId = _storage.read(AppConstants.operatorIdKey) ?? 0;
      final collegeData = _storage.read(AppConstants.selectedCollegeKey);
      
      if (operatorId == 0 || collegeData == null) {
        CustomToast.error('Authentication required');
        Get.offAllNamed(AppRoutes.AUTH);
        return;
      }

      final college = CollegeModel.fromJson(collegeData);

      print('=== LOADING TESTS ===');
      print('College: ${college.name} (ID: ${college.id})');
      print('Operator ID: $operatorId');

      if (_attendanceService.isOnline) {
        // Load tests from API
        final response = await _apiProvider.getAvailableTests(
          collegeId: college.id,
          operatorId: operatorId,
        );

        print('Tests response: ${response.statusCode}');
        print('Response data: ${response.data}');

        if (response.data['success'] == true) {
          final testsData = response.data['data'] as List<dynamic>;
          tests.value = testsData.map((json) => TestModel.fromJson(json)).toList();
          
          print('Loaded ${tests.length} tests');
          for (var test in tests) {
            print('- ${test.name} (${test.status})');
          }
          
          if (tests.isEmpty) {
            CustomToast.warning('No active tests available for your college');
          }
        } else {
          CustomToast.error(response.data['message'] ?? 'Failed to load tests');
        }
      } else {
        CustomToast.warning('Offline mode - Cannot load tests');
      }
    } catch (e) {
      print('Error loading tests: $e');
      CustomToast.error('Failed to load tests: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load previously selected test
  void loadSelectedTest() {
    final testId = _storage.read(AppConstants.currentTestIdKey);
    if (testId != null) {
      final test = tests.firstWhereOrNull((t) => t.id == testId);
      if (test != null) {
        selectedTest.value = test;
      }
    }
  }

  /// Select a test
  void selectTest(TestModel test) {
    if (!test.canSelect) {
      CustomToast.warning('Cannot select ${test.status} test');
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Select Test'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              test.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Date: ${test.testDate}'),
            Text('Time: ${test.testTime}'),
            Text('Venue: ${test.venue}'),
            Text('Students: ${test.totalStudents}'),
            const SizedBox(height: 12),
            Text(
              'Are you sure you want to select this test for attendance?',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _confirmTestSelection(test);
              Get.back();
            },
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }

  /// Confirm test selection
  void _confirmTestSelection(TestModel test) {
    selectedTest.value = test;
    _attendanceService.setCurrentTestId(test.id);
    _storage.write(AppConstants.currentTestIdKey, test.id);
    
    CustomToast.success('Test selected: ${test.name}');
    
    // Navigate back to home or QR scanner
    Get.back();
  }

  /// Search tests
  void searchTests(String query) {
    searchQuery.value = query.toLowerCase();
  }

  /// Get filtered tests based on search
  List<TestModel> get filteredTests {
    if (searchQuery.value.isEmpty) {
      return tests;
    }
    
    return tests.where((test) {
      return test.name.toLowerCase().contains(searchQuery.value) ||
             test.description.toLowerCase().contains(searchQuery.value) ||
             test.venue.toLowerCase().contains(searchQuery.value);
    }).toList();
  }

  /// Refresh tests
  Future<void> refreshTests() async {
    await loadTests();
    CustomToast.success('Tests refreshed');
  }

  /// Get current selected test info
  String get selectedTestInfo {
    if (selectedTest.value == null) {
      return 'No test selected';
    }
    return selectedTest.value!.name;
  }

  /// Navigate to QR scanner with selected test
  void proceedToScanner() {
    if (selectedTest.value == null) {
      CustomToast.warning('Please select a test first');
      return;
    }
    
    Get.toNamed(AppRoutes.QR_SCANNER);
  }

  /// Clear search
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}