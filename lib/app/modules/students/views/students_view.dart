import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../controllers/students_controller.dart';
import '../../../core/values/app_colors.dart';
import '../../../data/models/student_model.dart';

class StudentsView extends GetView<StudentsController> {
  final TextEditingController searchController = TextEditingController();

  StudentsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        title: Text(
          'Student List',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  onChanged: (value) => controller.searchStudents(value),
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search by roll no, name, or CNIC...',
                    hintStyle: TextStyle(color: Colors.white70),
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                    suffixIcon:
                        Obx(() => controller.searchQuery.value.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.white),
                                onPressed: () {
                                  searchController.clear();
                                  controller.searchStudents('');
                                },
                              )
                            : SizedBox.shrink()),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                // Filter Chips
                Obx(() => Row(
                      children: [
                        _buildFilterChip('All', 'all'),
                        SizedBox(width: 8),
                        _buildFilterChip('Captured', 'captured'),
                        SizedBox(width: 8),
                        _buildFilterChip('Pending', 'pending'),
                      ],
                    )),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Stats Summary
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() => Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Total',
                        '${controller.totalStudents}',
                        Icons.people,
                        AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Captured',
                        '${controller.capturedCount}',
                        Icons.check_circle,
                        AppColors.success,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Pending',
                        '${controller.pendingCount}',
                        Icons.pending,
                        AppColors.warning,
                      ),
                    ),
                  ],
                )),
          ),

          SizedBox(height: 16),

          // Students List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final students = controller.filteredStudents;

              if (students.isEmpty) {
                return _buildEmptyState(context);
              }

              return RefreshIndicator(
                onRefresh: controller.refresh,
                color: AppColors.primary,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    return _buildStudentCard(context, students[index]);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = controller.filterStatus.value == value;
    return InkWell(
      onTap: () => controller.setFilter(value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : Colors.white,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(context),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.getTextSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, StudentModel student) {
    final hasCaptured = controller.hasPhotoCaptured(student.rollNumber);
    final photoPath = controller.getPhotoPath(student.rollNumber);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(context),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => controller.goToCapturePhoto(student),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              // Photo Thumbnail or Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: hasCaptured
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.getTextMuted(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasCaptured 
                        ? AppColors.success 
                        : AppColors.getTextMuted(context),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: photoPath != null
                      ? Image.file(
                          File(photoPath),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person_outline,
                              color: AppColors.getTextMuted(context),
                              size: 32,
                            );
                          },
                        )
                      : Icon(
                          hasCaptured
                              ? Icons.check_circle
                              : Icons.person_outline,
                          color: hasCaptured
                              ? AppColors.success
                              : AppColors.getTextMuted(context),
                          size: 32,
                        ),
                ),
              ),

              SizedBox(width: 12),

              // Student Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextPrimary(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.badge, size: 14, color: AppColors.getTextMuted(context)),
                        SizedBox(width: 4),
                        Text(
                          'Roll: ${student.rollNumber}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.getTextSecondary(context),
                          ),
                        ),
                      ],
                    ),
                    if (student.cnic.isNotEmpty) ...[
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.credit_card,
                              size: 14, color: AppColors.getTextMuted(context)),
                          SizedBox(width: 4),
                          Text(
                            'CNIC: ${student.cnic}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.getTextMuted(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Status Badge & Arrow
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          hasCaptured ? AppColors.success : AppColors.warning,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      hasCaptured ? 'Done' : 'Pending',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Icon(
                    Icons.camera_alt,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: AppColors.getTextMuted(context),
          ),
          SizedBox(height: 16),
          Text(
            'No students found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextSecondary(context),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Sync students from home screen\nor adjust your filters',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextMuted(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.getCardBackground(context),
        title: Text(
          'Filter Students',
          style: TextStyle(color: AppColors.getTextPrimary(context)),
        ),
        content: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFilterOption(context, 'Show All', 'all'),
                _buildFilterOption(context, 'Photos Captured', 'captured'),
                _buildFilterOption(context, 'Pending Photos', 'pending'),
              ],
            )),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'CLOSE',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(BuildContext context, String label, String value) {
    return RadioListTile<String>(
      title: Text(
        label,
        style: TextStyle(color: AppColors.getTextPrimary(context)),
      ),
      value: value,
      groupValue: controller.filterStatus.value,
      onChanged: (value) {
        if (value != null) {
          controller.setFilter(value);
          Get.back();
        }
      },
      activeColor: AppColors.primary,
    );
  }
}
