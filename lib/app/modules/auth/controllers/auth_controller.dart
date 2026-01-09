import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/providers/api_provider.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/values/app_constants.dart';
import '../../../data/models/college_model.dart';
import '../../../data/models/test_model.dart';
import '../../../routes/app_pages.dart';
import '../../../core/utils/custom_toast.dart';
import '../../../core/services/attendance_service.dart';

class AuthController extends GetxController {
  final GetStorage storage = GetStorage();
  final ApiProvider apiProvider = ApiProvider();

  var isLoading = false.obs;
  var colleges = <CollegeModel>[].obs;
  var availableTests = <TestModel>[].obs;
  var selectedCollege = Rxn<CollegeModel>();
  var selectedTest = Rxn<TestModel>();
  var operatorName = ''.obs;
  var operatorId = 0.obs;

  /// Authenticate operator with email and password
  Future<void> authenticateOperator(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      CustomToast.error('Please enter email and password');
      return;
    }

    isLoading.value = true;

    try {
      print('=== AUTHENTICATING BIOMETRIC OPERATOR ===');
      print('Email: $email');
      print('API URL: ${AppConstants.baseUrl}/biometric-operator/login');

      // Call biometric operator authentication API
      final response = await apiProvider.authenticateOperator(email, password);

      print('=== DETAILED AUTHENTICATION RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Type: ${response.data.runtimeType}');
      print('Full Response: ${response.data}');
      
      // Check if response is successful
      if (response.statusCode == 200 && response.data != null) {
        print('=== PARSING RESPONSE DATA ===');
        
        // Handle different response structures
        dynamic responseData;
        bool isSuccess = false;
        
        if (response.data is Map) {
          final responseMap = response.data as Map<String, dynamic>;
          print('Response keys: ${responseMap.keys.toList()}');
          
          // Check for success indicator
          if (responseMap.containsKey('success')) {
            isSuccess = responseMap['success'] == true;
            responseData = responseMap['data'];
            print('Success field found: $isSuccess');
          } else if (responseMap.containsKey('status')) {
            isSuccess = responseMap['status'] == 'success';
            responseData = responseMap['data'] ?? responseMap;
            print('Status field found: ${responseMap['status']}');
          } else {
            // Assume success if we have operator data
            isSuccess = responseMap.containsKey('operator') || responseMap.containsKey('id');
            responseData = responseMap;
            print('No success field, assuming success based on data presence: $isSuccess');
          }
        } else {
          print('Unexpected response format: ${response.data}');
          CustomToast.error('Unexpected response format from server');
          return;
        }

        if (isSuccess && responseData != null) {
          print('=== PROCESSING OPERATOR DATA ===');
          
          // Extract operator data
          dynamic operatorData;
          if (responseData is Map && responseData.containsKey('operator')) {
            operatorData = responseData['operator'];
            print('Operator data found in response.data.operator');
          } else if (responseData is Map) {
            operatorData = responseData;
            print('Using response.data directly as operator data');
          } else {
            print('Cannot find operator data in response');
            CustomToast.error('Invalid response structure from server');
            return;
          }
          
          print('Operator data type: ${operatorData.runtimeType}');
          print('Operator data: $operatorData');
          
          if (operatorData is Map) {
            final operatorMap = operatorData as Map<String, dynamic>;
            print('Operator data keys: ${operatorMap.keys.toList()}');
            
            // Extract basic operator info
            operatorId.value = operatorMap['id'] ?? 0;
            operatorName.value = operatorMap['name'] ?? 'Unknown Operator';
            
            print('Extracted - ID: ${operatorId.value}, Name: ${operatorName.value}');
            
            // Look for college assignment in various possible structures
            dynamic assignedCollege;
            int? assignedCollegeId;
            
            print('=== SEARCHING FOR COLLEGE ASSIGNMENT ===');
            
            // Check all possible college-related keys
            final collegeKeys = [
              'assigned_college',
              'assignedCollege', 
              'college',
              'colleges',
              'assigned_colleges'
            ];
            
            for (String key in collegeKeys) {
              if (operatorMap.containsKey(key) && operatorMap[key] != null) {
                assignedCollege = operatorMap[key];
                print('Found college data in key "$key": $assignedCollege');
                break;
              }
            }
            
            // Check for college ID
            final collegeIdKeys = [
              'assigned_college_id',
              'assignedCollegeId',
              'college_id',
              'collegeId'
            ];
            
            for (String key in collegeIdKeys) {
              if (operatorMap.containsKey(key) && operatorMap[key] != null) {
                assignedCollegeId = operatorMap[key];
                print('Found college ID in key "$key": $assignedCollegeId');
                break;
              }
            }
            
            print('Final college data: $assignedCollege');
            print('Final college ID: $assignedCollegeId');
            
            // Process college data
            if (assignedCollege != null) {
              if (assignedCollege is Map) {
                // Single college object
                try {
                  final college = CollegeModel.fromJson(Map<String, dynamic>.from(assignedCollege));
                  colleges.value = [college];
                  print('Successfully parsed college: ${college.name}');
                } catch (e) {
                  print('Error parsing college data: $e');
                  print('College data structure: $assignedCollege');
                  CustomToast.error('Error parsing college information');
                  return;
                }
              } else if (assignedCollege is List) {
                // Multiple colleges
                try {
                  colleges.value = assignedCollege.map<CollegeModel>((collegeData) {
                    return CollegeModel.fromJson(Map<String, dynamic>.from(collegeData));
                  }).toList();
                  print('Successfully parsed ${colleges.length} colleges');
                } catch (e) {
                  print('Error parsing colleges list: $e');
                  CustomToast.error('Error parsing colleges information');
                  return;
                }
              } else {
                print('Unexpected college data type: ${assignedCollege.runtimeType}');
              }
            } else if (assignedCollegeId != null) {
              // Create temporary college with ID only
              colleges.value = [
                CollegeModel(
                  id: assignedCollegeId,
                  name: 'Assigned College (ID: $assignedCollegeId)',
                  district: 'Unknown',
                  province: 'Unknown',
                )
              ];
              print('Created temporary college with ID: $assignedCollegeId');
            }
            
            // Check if we have any colleges
            if (colleges.isEmpty) {
              print('=== NO COLLEGE ASSIGNMENT FOUND ===');
              print('Available operator keys: ${operatorMap.keys.toList()}');
              print('Full operator data: $operatorMap');
              CustomToast.error('No college assigned to this operator. Please contact administrator.');
              return;
            }
            
            // Look for tests data
            print('=== SEARCHING FOR TESTS DATA ===');
            dynamic testsData;
            final testKeys = ['tests', 'accessible_tests', 'assigned_tests'];
            
            for (String key in testKeys) {
              if (operatorMap.containsKey(key) && operatorMap[key] != null) {
                testsData = operatorMap[key];
                print('Found tests data in key "$key": $testsData');
                break;
              }
            }
            
            // Save authentication data
            storage.write(AppConstants.operatorIdKey, operatorId.value);
            storage.write(AppConstants.operatorNameKey, operatorName.value);
            
            // Save token if available
            if (responseData is Map && responseData.containsKey('token')) {
              storage.write('auth_token', responseData['token']);
              print('Token saved: ${responseData['token']}');
            }
            
            CustomToast.success('Authentication successful!');
            
            // Process colleges and tests
            selectedCollege.value = colleges.first;
            storage.write(AppConstants.selectedCollegeKey, colleges.first.toJson());
            
            // Convert tests data if available
            if (testsData is List && testsData.isNotEmpty) {
              try {
                availableTests.value = testsData.map<TestModel>((testData) {
                  return TestModel(
                    id: testData['id'] ?? 1,
                    name: testData['test_name'] ?? testData['name'] ?? 'Test - ${testData['test_date'] ?? 'Unknown Date'}',
                    description: 'Test for ${colleges.first.name}',
                    testDate: testData['test_date'] ?? DateTime.now().toString().split(' ')[0],
                    testTime: testData['test_time'] ?? '09:00 AM',
                    venue: colleges.first.name,
                    status: testData['status'] ?? 'active',
                    totalStudents: testData['total_students'] ?? 0,
                    presentCount: 0,
                    absentCount: 0,
                    createdAt: DateTime.now().toString(),
                    isActive: true,
                  );
                }).toList();
                
                print('Processed ${availableTests.length} tests');
                _showTestSelectionDialog();
              } catch (e) {
                print('Error processing tests: $e');
                CustomToast.warning('Tests data could not be processed, but you can still access the system');
                Get.offAllNamed(AppRoutes.HOME);
              }
            } else {
              print('No tests data found, proceeding without test selection');
              CustomToast.warning('No active tests available, but you can still access the system');
              Get.offAllNamed(AppRoutes.HOME);
            }
            
          } else {
            print('Operator data is not a Map: ${operatorData.runtimeType}');
            CustomToast.error('Invalid operator data format');
            return;
          }
        } else {
          // Authentication failed
          String errorMessage = 'Invalid credentials';
          if (response.data is Map && response.data.containsKey('message')) {
            errorMessage = response.data['message'];
          }
          print('Authentication failed: $errorMessage');
          CustomToast.error(errorMessage);
        }
      } else {
        print('HTTP Error - Status: ${response.statusCode}');
        CustomToast.error('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('=== AUTHENTICATION EXCEPTION ===');
      print('Exception type: ${e.runtimeType}');
      print('Exception message: $e');
      
      if (e.toString().contains('DioException')) {
        print('This is a Dio network exception');
      }
      
      // TEMPORARY FALLBACK for testing - Remove this when your API is ready
      if (email == 'test@test.com' && password == 'test123') {
        CustomToast.info('Using temporary test credentials');
        _handleTestLogin();
        return;
      }
      
      CustomToast.error('Authentication failed: Network error or server unavailable');
    } finally {
      isLoading.value = false;
    }
  }

  /// Temporary test login - Remove when real API is working
  void _handleTestLogin() {
    operatorId.value = 1;
    operatorName.value = 'Test Operator';
    
    // Create test colleges
    colleges.value = [
      CollegeModel(
        id: 1,
        name: 'BACT Main Campus',
        district: 'Quetta',
        province: 'Balochistan',
      ),
      CollegeModel(
        id: 2,
        name: 'Engineering College',
        district: 'Karachi',
        province: 'Sindh',
      ),
    ];

    // Save operator info
    storage.write(AppConstants.operatorIdKey, operatorId.value);
    storage.write(AppConstants.operatorNameKey, operatorName.value);

    // Show college selection
    _showCollegeSelectionDialog();
  }

  /// Show college selection dialog
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
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
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
                            child: Icon(Icons.school, color: AppColors.primary, size: 20),
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

    // Load available tests for this college
    await _loadAvailableTests(college.id);
  }

  /// Load available tests for the selected college
  Future<void> _loadAvailableTests(int collegeId) async {
    isLoading.value = true;

    try {
      print('=== LOADING AVAILABLE TESTS ===');
      print('College ID: $collegeId');
      print('Operator ID: ${operatorId.value}');

      // Load from API
      final response = await apiProvider.getAvailableTests(
        collegeId: collegeId,
        operatorId: operatorId.value,
      );

      print('Tests response: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.data['success'] == true) {
        final testsData = response.data['data'] as List<dynamic>;
        availableTests.value = testsData.map((json) => TestModel.fromJson(json)).toList();

        print('Available tests: ${availableTests.length}');
        for (var test in availableTests) {
          print('- ${test.name} (${test.status})');
        }

        if (availableTests.isEmpty) {
          CustomToast.error('No active tests available for this college');
          _showCollegeSelectionDialog(); // Go back to college selection
          return;
        }

        // Show test selection dialog
        _showTestSelectionDialog();
      } else {
        CustomToast.error(response.data['message'] ?? 'Failed to load tests');
        _showCollegeSelectionDialog(); // Go back to college selection
      }
    } catch (e) {
      print('Error loading tests: $e');
      
      // TEMPORARY FALLBACK for testing
      CustomToast.info('API unavailable - Using test data');
      availableTests.value = [
        TestModel(
          id: 1,
          name: 'BACT Entry Test 2024',
          description: 'Bachelor of Arts in Computer Technology entrance examination',
          testDate: '2024-02-15',
          testTime: '09:00 AM',
          venue: 'Main Campus, Block A',
          status: 'active',
          totalStudents: 150,
          presentCount: 0,
          absentCount: 0,
          createdAt: '2024-01-15',
          isActive: true,
        ),
        TestModel(
          id: 2,
          name: 'Engineering Aptitude Test',
          description: 'Engineering program entrance test',
          testDate: '2024-02-20',
          testTime: '10:00 AM',
          venue: 'Engineering Block, Hall 1',
          status: 'upcoming',
          totalStudents: 200,
          presentCount: 0,
          absentCount: 0,
          createdAt: '2024-01-20',
          isActive: false,
        ),
      ];
      
      // Show test selection dialog
      _showTestSelectionDialog();
    } finally {
      isLoading.value = false;
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
                  'Select the test you are taking attendance for:',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
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
                              color: test.getStatusColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              test.getStatusIcon(),
                              color: test.getStatusColor(),
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
                              Text(
                                '${test.testDate} at ${test.testTime}',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                test.venue,
                                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          trailing: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: test.getStatusColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: test.getStatusColor()),
                            ),
                            child: Text(
                              test.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: test.getStatusColor(),
                              ),
                            ),
                          ),
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
                Get.back(); // Close test dialog
                _showCollegeSelectionDialog(); // Go back to college selection
              },
              child: Text('BACK TO COLLEGES'),
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
    Get.back(); // Close test dialog

    // Save authentication and test selection
    storage.write(AppConstants.isAuthenticatedKey, true);
    storage.write(AppConstants.currentTestIdKey, test.id);

    // Set current test in attendance service
    final attendanceService = Get.find<AttendanceService>();
    attendanceService.setCurrentTestId(test.id);

    CustomToast.success(
      'Logged in successfully!\n'
      'Operator: ${operatorName.value}\n'
      'College: ${selectedCollege.value!.name}\n'
      'Test: ${test.name}'
    );

    // Navigate to home
    Future.delayed(Duration(milliseconds: 1000), () {
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
            onPressed: () {
              // Clear all stored data
              storage.remove(AppConstants.isAuthenticatedKey);
              storage.remove(AppConstants.selectedCollegeKey);
              storage.remove(AppConstants.operatorNameKey);
              storage.remove(AppConstants.operatorIdKey);
              storage.remove(AppConstants.currentTestIdKey);
              
              // Clear controller data
              operatorName.value = '';
              operatorId.value = 0;
              selectedCollege.value = null;
              selectedTest.value = null;
              colleges.clear();
              availableTests.clear();

              Get.back();
              Get.offAllNamed(AppRoutes.AUTH);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text('LOGOUT'),
          ),
        ],
      ),
    );
  }

  /// Check if operator is authenticated
  bool get isAuthenticated {
    return storage.read(AppConstants.isAuthenticatedKey) ?? false;
  }

  /// Load saved authentication data
  void loadSavedAuth() {
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
