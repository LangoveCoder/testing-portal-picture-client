import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/values/app_constants.dart';
import '../../../data/models/college_model.dart';
import '../../../data/models/test_model.dart';
import '../../../routes/app_pages.dart';
import '../../../core/utils/custom_toast.dart';
import '../../../core/services/attendance_service.dart';
import '../../../core/services/auth_service.dart';

class AuthController extends GetxController {
  final GetStorage storage = GetStorage();

  var isLoading = false.obs;
  var colleges = <CollegeModel>[].obs;
  var availableTests = <TestModel>[].obs;
  var selectedCollege = Rxn<CollegeModel>();
  var selectedTest = Rxn<TestModel>();
  var operatorName = ''.obs;
  var operatorId = 0.obs;

  /// Authenticate operator with email and password
  /// TEMPORARY: Bypass authentication for development
  Future<void> authenticateOperator(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      CustomToast.error('Please enter email and password');
      return;
    }

    isLoading.value = true;

    try {
      print('=== BYPASS AUTH MODE - DUMMY LOGIN ===');

      // Simulate short delay
      await Future.delayed(Duration(milliseconds: 500));

      // Create dummy operator data
      operatorId.value = 1;
      operatorName.value = 'Test Operator';

      selectedCollege.value = CollegeModel(
        id: 1,
        name: 'Test College',
        district: 'Test District',
        province: 'Test Province',
      );

      colleges.value = [selectedCollege.value!];

      // Save selected college
      storage.write(
          AppConstants.selectedCollegeKey, selectedCollege.value!.toJson());

      // Create dummy test
      availableTests.value = [
        TestModel(
          id: 1,
          name: 'Test Attendance Session',
          testDate: DateTime.now().toString().split(' ')[0],
          testTime: '09:00 AM',
          totalMarks: 100,
          collegeName: 'Test College',
        ),
      ];

      // Save auth data
      storage.write(AppConstants.isAuthenticatedKey, true);
      storage.write(AppConstants.operatorIdKey, operatorId.value);
      storage.write(AppConstants.operatorNameKey, operatorName.value);
      storage.write(AppConstants.currentTestIdKey, 1);

      // Set test in attendance service
      try {
        final attendanceService = Get.find<AttendanceService>();
        attendanceService.setCurrentTestId(1);
      } catch (e) {
        print('AttendanceService not found: $e');
      }

      CustomToast.success('Login successful! (Development Mode)');

      // Navigate to home directly
      Future.delayed(Duration(milliseconds: 500), () {
        Get.offAllNamed(AppRoutes.HOME);
      });

    } catch (e) {
      print('=== LOGIN ERROR ===');
      print('Error: $e');
      CustomToast.error('Login failed: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// Show college selection dialog (if multiple colleges)
  void _showCollegeSelectionDialog() {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Row(
            children: [
              Icon(Icons.school_rounded, color: AppColors.primary),
              SizedBox(width: 12),
              Text('Select College'),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select the college you are operating for:',
                  style:
                      TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                SizedBox(height: 16),
                Container(
                  constraints: BoxConstraints(maxHeight: 400),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: colleges.length,
                    itemBuilder: (context, index) {
                      final college = colleges[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Icon(Icons.school,
                                color: AppColors.primary, size: 20),
                          ),
                          title: Text(
                            college.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            '${college.district}, ${college.province}',
                            style: TextStyle(fontSize: 12),
                          ),
                          onTap: () => selectCollege(college),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Select college and load available tests
  void selectCollege(CollegeModel college) async {
    selectedCollege.value = college;
    Get.back(); // Close college dialog

    // Save selected college
    storage.write(AppConstants.selectedCollegeKey, college.toJson());

    // Show test selection if tests available
    if (availableTests.isNotEmpty) {
      _showTestSelectionDialog();
    } else {
      CustomToast.warning('No tests assigned');
      Get.offAllNamed(AppRoutes.HOME);
    }
  }

  /// Show test selection dialog
  void _showTestSelectionDialog() {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Row(
            children: [
              Icon(Icons.assignment_rounded, color: AppColors.primary),
              SizedBox(width: 12),
              Text('Select Test'),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select the test you are working on:',
                  style:
                      TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                SizedBox(height: 16),
                Container(
                  constraints: BoxConstraints(maxHeight: 400),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableTests.length,
                    itemBuilder: (context, index) {
                      final test = availableTests[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.assignment,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            test.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      size: 12, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text(
                                    test.testDate,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.access_time,
                                      size: 12, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text(
                                    test.testTime,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              if (test.collegeName != null) ...[
                                SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(Icons.school,
                                        size: 12, color: Colors.grey),
                                    SizedBox(width: 4),
                                    Text(
                                      test.collegeName!,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                          trailing: Icon(Icons.chevron_right,
                              color: AppColors.primary),
                          onTap: () => selectTest(test),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                Get.offAllNamed(AppRoutes.HOME);
              },
              child: Text('SKIP FOR NOW'),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Select test and complete authentication
  void selectTest(TestModel test) {
    selectedTest.value = test;

    // Close dialog if open
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    // Save test selection
    storage.write(AppConstants.currentTestIdKey, test.id);

    // Set current test in attendance service if available
    try {
      final attendanceService = Get.find<AttendanceService>();
      attendanceService.setCurrentTestId(test.id);
    } catch (e) {
      print('AttendanceService not found: $e');
    }

    CustomToast.success('Test Selected!\n${test.name}');

    // Navigate to home
    Future.delayed(Duration(milliseconds: 800), () {
      Get.offAllNamed(AppRoutes.HOME);
    });
  }

  /// Logout operator
  void logout() {
    Get.dialog(
      AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              // ✅ Use AuthService logout
              try {
                final authService = Get.find<AuthService>();
                await authService.logout();
              } catch (e) {
                print('AuthService not found: $e');
              }

              // Clear local data
              storage.remove(AppConstants.isAuthenticatedKey);
              storage.remove(AppConstants.selectedCollegeKey);
              storage.remove(AppConstants.operatorNameKey);
              storage.remove(AppConstants.operatorIdKey);
              storage.remove(AppConstants.currentTestIdKey);

              operatorName.value = '';
              operatorId.value = 0;
              selectedCollege.value = null;
              selectedTest.value = null;
              colleges.clear();
              availableTests.clear();

              Get.back();
              Get.offAllNamed(AppRoutes.AUTH);

              CustomToast.success('Logged out successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text('LOGOUT', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Check if operator is authenticated
  bool get isAuthenticated {
    try {
      final authService = Get.find<AuthService>();
      return authService.isAuthenticated.value;
    } catch (e) {
      return storage.read(AppConstants.isAuthenticatedKey) ?? false;
    }
  }

  /// Load saved authentication data
  void loadSavedAuth() {
    try {
      final authService = Get.find<AuthService>();
      if (authService.isAuthenticated.value) {
        final operator = authService.currentOperator.value;
        if (operator != null) {
          operatorName.value = operator.name;
          operatorId.value = operator.id;

          if (operator.assignedCollege != null) {
            selectedCollege.value = CollegeModel(
              id: operator.assignedCollege!.id,
              name: operator.assignedCollege!.name,
              district: operator.assignedCollege!.district,
              province: operator.assignedCollege!.province,
            );
          }

          if (operator.tests.isNotEmpty) {
            availableTests.value = operator.tests.map((test) {
              return TestModel(
                id: test.id,
                name: test.testName,
                testDate: test.testDate,
                testTime: test.testTime,
                totalMarks: test.totalMarks,
                collegeName: operator.assignedCollege?.name,
              );
            }).toList();
          }
        }
      }
    } catch (e) {
      print('AuthService not available: $e');
      if (isAuthenticated) {
        operatorName.value = storage.read(AppConstants.operatorNameKey) ?? '';
        operatorId.value = storage.read(AppConstants.operatorIdKey) ?? 0;

        final collegeData = storage.read(AppConstants.selectedCollegeKey);
        if (collegeData != null) {
          selectedCollege.value = CollegeModel.fromJson(collegeData);
        }
      }
    }
  }
}
