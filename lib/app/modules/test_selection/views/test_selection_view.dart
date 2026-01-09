import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/test_selection_controller.dart';
import '../../../core/values/app_colors.dart';
import '../../../data/models/test_model.dart';

class TestSelectionView extends GetView<TestSelectionController> {
  const TestSelectionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        title: const Text('Select Test'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Obx(() => IconButton(
            onPressed: controller.isLoading.value ? null : controller.refreshTests,
            icon: controller.isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh),
          )),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.getCardBackground(context),
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.searchTests,
              decoration: InputDecoration(
                hintText: 'Search tests...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        onPressed: controller.clearSearch,
                        icon: const Icon(Icons.clear),
                      )
                    : const SizedBox()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.getBackground(context),
              ),
            ),
          ),

          // Selected Test Info
          Obx(() {
            if (controller.selectedTest.value != null) {
              return Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Test',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.getTextSecondary(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            controller.selectedTest.value!.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.getTextPrimary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: controller.proceedToScanner,
                      icon: const Icon(Icons.qr_code_scanner, size: 16),
                      label: const Text('Start'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          }),

          // Tests List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.tests.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading tests...'),
                    ],
                  ),
                );
              }

              final filteredTests = controller.filteredTests;

              if (filteredTests.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        controller.searchQuery.value.isNotEmpty
                            ? 'No tests found for "${controller.searchQuery.value}"'
                            : 'No tests available',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (controller.searchQuery.value.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: controller.clearSearch,
                          child: const Text('Clear search'),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshTests,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredTests.length,
                  itemBuilder: (context, index) {
                    final test = filteredTests[index];
                    return _buildTestCard(context, test);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTestCard(BuildContext context, TestModel test) {
    final isSelected = controller.selectedTest.value?.id == test.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.getCardBackground(context),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected 
              ? AppColors.primary 
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => controller.selectTest(test),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: test.getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: test.getStatusColor(),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          test.getStatusIcon(),
                          size: 12,
                          color: test.getStatusColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          test.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: test.getStatusColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Test Name
              Text(
                test.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(context),
                ),
              ),

              const SizedBox(height: 4),

              // Description
              Text(
                test.description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.getTextSecondary(context),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Test Details
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      Icons.calendar_today,
                      'Date',
                      test.testDate,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      Icons.access_time,
                      'Time',
                      test.testTime,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      Icons.location_on,
                      'Venue',
                      test.venue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      Icons.people,
                      'Students',
                      '${test.totalStudents}',
                    ),
                  ),
                ],
              ),

              // Attendance Progress (for active/completed tests)
              if (test.status == 'active' || test.status == 'completed') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Attendance Progress',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.getTextSecondary(context),
                                ),
                              ),
                              Text(
                                '${test.attendancePercentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: test.attendancePercentage >= 80 
                                      ? Colors.green 
                                      : test.attendancePercentage >= 60 
                                          ? Colors.orange 
                                          : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: test.attendancePercentage / 100,
                            backgroundColor: Colors.grey.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              test.attendancePercentage >= 80 
                                  ? Colors.green 
                                  : test.attendancePercentage >= 60 
                                      ? Colors.orange 
                                      : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'Present: ${test.presentCount}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Absent: ${test.absentCount}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],

              // Action Button
              if (test.canSelect) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => controller.selectTest(test),
                    icon: Icon(
                      isSelected ? Icons.check : Icons.play_arrow,
                      size: 16,
                    ),
                    label: Text(isSelected ? 'Selected' : 'Select Test'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected 
                          ? Colors.green 
                          : AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    'Test ${test.status}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.getTextSecondary(context),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.getTextSecondary(context),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.getTextPrimary(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}