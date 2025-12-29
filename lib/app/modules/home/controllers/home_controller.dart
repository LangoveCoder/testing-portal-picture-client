import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/values/app_constants.dart';
import '../../../data/models/college_model.dart';
import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  final GetStorage storage = GetStorage();

  var selectedCollege = Rxn<CollegeModel>();
  var operatorName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  void loadUserData() {
    // Load operator name
    operatorName.value =
        storage.read(AppConstants.operatorNameKey) ?? 'Operator';

    // Load selected college
    final collegeJson = storage.read(AppConstants.selectedCollegeKey);
    if (collegeJson != null) {
      selectedCollege.value = CollegeModel.fromJson(collegeJson);
    }
  }

  void searchStudent(String rollNumber) {
    if (rollNumber.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter roll number',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Navigate to student search with roll number
    Get.toNamed(AppRoutes.STUDENT_SEARCH, arguments: rollNumber);
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
            child: Text('LOGOUT'),
          ),
        ],
      ),
    );
  }

  void changeCollege() {
    Get.dialog(
      AlertDialog(
        title: Text('Change College'),
        content: Text('You need to logout and login again to change college.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              logout();
            },
            child: Text('LOGOUT'),
          ),
        ],
      ),
    );
  }
}
