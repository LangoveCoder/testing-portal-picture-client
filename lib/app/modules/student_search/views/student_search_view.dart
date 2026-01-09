import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/student_search_controller.dart';
import '../../../core/values/app_colors.dart';

class StudentSearchView extends GetView<StudentSearchController> {
  const StudentSearchView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        title: Text('Student Verification'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoading(context);
        }

        if (controller.student.value == null) {
          return _buildNoData(context);
        }

        return _buildStudentInfo(context);
      }),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
          SizedBox(height: 20),
          Text(
            'Searching student...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.getTextSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoData(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off_rounded,
            size: 80,
            color: AppColors.getTextMuted(context),
          ),
          SizedBox(height: 20),
          Text(
            'No student found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Please try again',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextSecondary(context),
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Go Back',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentInfo(BuildContext context) {
    final student = controller.student.value!;

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: student.picture != null
                        ? Image.network(
                            student.picture!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person_rounded,
                                size: 60,
                                color: AppColors.primary,
                              );
                            },
                          )
                        : Icon(
                            Icons.person_rounded,
                            size: 60,
                            color: AppColors.primary,
                          ),
                  ),
                ),

                SizedBox(height: 20),

                // Roll Number
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    student.rollNumber,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Info Card
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.getCardBackground(context),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.getShadow(context),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(context),
                  ),
                ),

                SizedBox(height: 20),

                _buildInfoRow(context, Icons.person_outline, 'Name', student.name),
                Divider(height: 32, color: AppColors.getBorder(context)),
                _buildInfoRow(context, Icons.person_outline, 'Father Name', student.fatherName),
                Divider(height: 32, color: AppColors.getBorder(context)),
                _buildInfoRow(context, Icons.credit_card_rounded, 'CNIC', student.cnic),
                Divider(height: 32, color: AppColors.getBorder(context)),
                _buildInfoRow(context, Icons.location_on_rounded, 'Venue', student.venue),
                Divider(height: 32, color: AppColors.getBorder(context)),
                _buildInfoRow(context, Icons.assignment_rounded, 'Test', student.testName),

                SizedBox(height: 20),

                // Photo Status
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: student.hasPhoto
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        student.hasPhoto
                            ? Icons.check_circle_rounded
                            : Icons.warning_rounded,
                        color: student.hasPhoto
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          student.hasPhoto
                              ? 'Photo already uploaded'
                              : 'Photo not uploaded yet',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: student.hasPhoto
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 32),

          // Capture Button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => controller.goToCamera(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    student.hasPhoto ? 'RETAKE PHOTO' : 'CAPTURE PHOTO',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.getTextSecondary(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.getTextPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
