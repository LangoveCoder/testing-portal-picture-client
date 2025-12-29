import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/providers/api_provider.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/values/app_constants.dart';
import '../../../data/models/college_model.dart';
import '../../../routes/app_pages.dart';

class AuthController extends GetxController {
  final GetStorage storage = GetStorage();
  final ApiProvider apiProvider = ApiProvider();

  var isLoading = false.obs;
  var colleges = <CollegeModel>[].obs;
  var selectedCollege = Rxn<CollegeModel>();
  var operatorName = ''.obs;

  @override
  void onReady() {
    super.onReady();
    checkAuthentication();
  }

  void checkAuthentication() async {
    await Future.delayed(Duration(milliseconds: 500));

    final isAuthenticated =
        storage.read(AppConstants.isAuthenticatedKey) ?? false;

    if (isAuthenticated) {
      // Load saved college
      final savedCollegeJson = storage.read(AppConstants.selectedCollegeKey);
      if (savedCollegeJson != null) {
        selectedCollege.value = CollegeModel.fromJson(savedCollegeJson);
      }
      Get.offAllNamed(AppRoutes.HOME);
    }
  }

  Future<void> validatePin(String pin, String operatorNameInput) async {
    if (pin.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter PIN',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.textWhite,
      );
      return;
    }

    if (operatorNameInput.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter operator name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.textWhite,
      );
      return;
    }

    isLoading.value = true;

    try {
      // Validate PIN (simple local check for now)
      if (pin == AppConstants.appPin) {
        // Fetch colleges from API
        final response = await apiProvider.getActiveColleges();

        if (response.data['success'] == true) {
          final List<dynamic> collegesData = response.data['data'];
          colleges.value =
              collegesData.map((json) => CollegeModel.fromJson(json)).toList();

          if (colleges.isEmpty) {
            Get.snackbar(
              'Error',
              'No colleges available',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.error,
              colorText: AppColors.textWhite,
            );
            return;
          }

          // Save operator name
          operatorName.value = operatorNameInput;
          storage.write(AppConstants.operatorNameKey, operatorNameInput);

          // Show college selection dialog
          _showCollegeSelectionDialog();
        } else {
          Get.snackbar(
            'Error',
            'Failed to load colleges',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.error,
            colorText: AppColors.textWhite,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Invalid PIN',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: AppColors.textWhite,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Authentication failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.textWhite,
      );
    } finally {
      isLoading.value = false;
    }
  }

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
                  'Select the college you are assigned to:',
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

  void selectCollege(CollegeModel college) {
    selectedCollege.value = college;

    // Save authentication
    storage.write(AppConstants.isAuthenticatedKey, true);
    storage.write(AppConstants.selectedCollegeKey, college.toJson());

    Get.back(); // Close dialog

    Get.snackbar(
      'Success',
      'Logged in as ${operatorName.value}\nCollege: ${college.name}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: AppColors.textWhite,
      duration: Duration(seconds: 2),
    );

    // Navigate to home
    Future.delayed(Duration(milliseconds: 500), () {
      Get.offAllNamed(AppRoutes.HOME);
    });
  }

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
              storage.remove(AppConstants.isAuthenticatedKey);
              storage.remove(AppConstants.selectedCollegeKey);
              storage.remove(AppConstants.operatorNameKey);
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
}
