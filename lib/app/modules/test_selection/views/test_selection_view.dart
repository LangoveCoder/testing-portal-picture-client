import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/test_selection_controller.dart';
import '../../../core/values/app_colors.dart';

class TestSelectionView extends GetView<TestSelectionController> {
  const TestSelectionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        title: Text(
          'Select Test',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.refreshTests,
            tooltip: 'Refresh tests',
          ),
          if (controller.hasSelectedTest)
            IconButton(
              icon: Icon(Icons.clear, color: Colors.white),
              onPressed: controller.clearSelectedTest,
              tooltip: 'Clear selection',
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
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.searchTests,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search tests...',
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.white),
                        onPressed: controller.clearSearch,
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
          ),

          SizedBox(height: 16),

          // Tests List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final tests = controller.filteredTests;

              if (tests.isEmpty) {
                return _buildEmptyState(context);
              }

              return RefreshIndicator(
                onRefresh: controller.refreshTests,
                color: AppColors.primary,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: tests.length,
                  itemBuilder: (context, index) {
                    return _buildTestCard(context, tests[index]);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        if (controller.hasSelectedTest) {
          return FloatingActionButton.extended(
            onPressed: controller.proceedToScanner,
            backgroundColor: AppColors.primary,
            icon: Icon(Icons.arrow_forward, color: Colors.white),
            label: Text(
              'PROCEED',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
        return SizedBox.shrink();
      }),
    );
  }

  Widget _buildTestCard(BuildContext context, dynamic test) {
    final isSelected = controller.selectedTest.value?.id == test.id;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(context),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => controller.selectTest(test),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.2)
                      : AppColors.getTextMuted(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSelected ? Icons.check_circle : Icons.assignment,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.getTextMuted(context),
                  size: 28,
                ),
              ),

              SizedBox(width: 16),

              // Test Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextPrimary(context),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 14, color: AppColors.getTextMuted(context)),
                        SizedBox(width: 4),
                        Text(
                          test.testDate,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.getTextSecondary(context),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 14, color: AppColors.getTextMuted(context)),
                        SizedBox(width: 4),
                        Text(
                          test.testTime,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.getTextSecondary(context),
                          ),
                        ),
                      ],
                    ),
                    if (test.collegeName != null) ...[
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.school,
                              size: 14, color: AppColors.getTextMuted(context)),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              test.collegeName!,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.getTextMuted(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Selected Badge
              if (isSelected)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'SELECTED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
            Icons.assignment_outlined,
            size: 80,
            color: AppColors.getTextMuted(context),
          ),
          SizedBox(height: 16),
          Text(
            controller.searchQuery.isNotEmpty
                ? 'No tests found'
                : 'No Tests Assigned',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextSecondary(context),
            ),
          ),
          SizedBox(height: 8),
          Text(
            controller.searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Contact your administrator',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextMuted(context),
            ),
          ),
          if (controller.searchQuery.isNotEmpty) ...[
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.clearSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'CLEAR SEARCH',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
