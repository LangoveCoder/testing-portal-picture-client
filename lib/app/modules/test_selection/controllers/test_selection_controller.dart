import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/models/test_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/custom_toast.dart';
import '../../../routes/app_pages.dart';

class TestSelectionController extends GetxController {
  final authService = Get.find<AuthService>();
  final storage = GetStorage();
  final searchController = TextEditingController(); // ✅ Added

  final RxList<TestModel> availableTests = <TestModel>[].obs;
  final Rx<TestModel?> selectedTest = Rx<TestModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs; // ✅ Added

  static const String SELECTED_TEST_KEY = 'selected_test';

  @override
  void onInit() {
    super.onInit();
    loadTests();
    loadSelectedTest();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Load ALL tests assigned to operator
  void loadTests() {
    try {
      isLoading.value = true;

      final operator = authService.currentOperator.value;

      if (operator == null) {
        CustomToast.error('Operator not found');
        return;
      }

      final tests = operator.tests;

      print('=== LOADING TESTS ===');
      print('Operator: ${operator.name}');
      print('Total tests found: ${tests.length}');

      if (tests.isEmpty) {
        CustomToast.warning('No tests assigned to you');
        availableTests.clear();
        return;
      }

      availableTests.value = tests.map((test) {
        print('Test: ${test.testName} (ID: ${test.id})');
        return TestModel.fromJson(test.toJson());
      }).toList();

      print('Loaded ${availableTests.length} tests');
    } catch (e) {
      print('Error loading tests: $e');
      CustomToast.error('Failed to load tests');
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Refresh tests
  Future<void> refreshTests() async {
    loadTests();
  }

  // ✅ Search tests
  void searchTests(String query) {
    searchQuery.value = query.toLowerCase();
  }

  // ✅ Clear search
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  // ✅ Filtered tests getter
  List<TestModel> get filteredTests {
    if (searchQuery.isEmpty) {
      return availableTests;
    }

    return availableTests.where((test) {
      return test.name.toLowerCase().contains(searchQuery.value) ||
          test.testDate.toLowerCase().contains(searchQuery.value) ||
          (test.collegeName?.toLowerCase().contains(searchQuery.value) ??
              false);
    }).toList();
  }

  // ✅ Alias for compatibility
  List<TestModel> get tests => availableTests;

  // Load selected test from storage
  void loadSelectedTest() {
    try {
      final testJson = storage.read(SELECTED_TEST_KEY);

      if (testJson != null) {
        selectedTest.value = TestModel.fromJson(testJson);
        print('Loaded selected test: ${selectedTest.value?.name}');
      }
    } catch (e) {
      print('Error loading selected test: $e');
    }
  }

  // Select a test
  void selectTest(TestModel test) {
    try {
      selectedTest.value = test;
      storage.write(SELECTED_TEST_KEY, test.toJson());

      CustomToast.success('Selected: ${test.name}');
      print('Test selected: ${test.name} (ID: ${test.id})');

      // Go back
      Get.back();
    } catch (e) {
      print('Error selecting test: $e');
      CustomToast.error('Failed to select test');
    }
  }

  // ✅ Proceed to scanner (navigate to home/QR scanner)
  void proceedToScanner() {
    if (selectedTest.value == null) {
      CustomToast.warning('Please select a test first');
      return;
    }

    Get.offAllNamed(AppRoutes.HOME);
    CustomToast.success('Test selected: ${selectedTest.value!.name}');
  }

  // Clear selected test
  void clearSelectedTest() {
    selectedTest.value = null;
    storage.remove(SELECTED_TEST_KEY);
    CustomToast.info('Test selection cleared');
  }

  // Get selected test ID
  int? getSelectedTestId() {
    return selectedTest.value?.id;
  }

  // Get selected test info
  String getSelectedTestInfo() {
    if (selectedTest.value == null) {
      return 'No test selected';
    }
    return selectedTest.value!.name;
  }

  // Check if a test is selected
  bool get hasSelectedTest => selectedTest.value != null;
}
