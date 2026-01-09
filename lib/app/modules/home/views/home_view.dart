import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/values/app_constants.dart';
import '../../../core/services/upload_queue_service.dart';
import '../../../core/services/student_cache_service.dart';
import '../../../core/utils/custom_toast.dart';
import '../../../routes/app_pages.dart';

class HomeView extends GetView<HomeController> {
  final TextEditingController rollNumberController = TextEditingController();

  HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: Column(
        children: [
          // Modern Header - Fixed
          _buildModernHeader(context),
          
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Section - Primary Focus
                  _buildProfessionalSearchSection(context),
                  
                  SizedBox(height: 24),
                  
                  // Stats Dashboard
                  _buildStatsDashboard(context),
                  
                  SizedBox(height: 24),
                  
                  // Action Center
                  _buildActionCenter(context),
                  
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E293B),
            const Color(0xFF334155),
            AppColors.primary,
          ],
          stops: [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar - Compact
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good ${_getGreeting()}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 2),
                        Obx(() => Text(
                              controller.operatorName.value,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => controller.logout(),
                      icon: Icon(Icons.logout_rounded, color: Colors.white),
                      iconSize: 20,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // App Title - Compact
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 24,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppConstants.appName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Attendance System',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // College Info - Compact
              Obx(() {
                final college = controller.selectedCollege.value;
                if (college == null) return SizedBox.shrink();

                return GestureDetector(
                  onTap: () => controller.changeCollege(),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.getCardBackground(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.school_rounded,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                college.name,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.getTextPrimary(context),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${college.district}, ${college.province}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.getTextSecondary(context),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.edit_rounded,
                          color: AppColors.getTextSecondary(context),
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Widget _buildProfessionalSearchSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(context),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Student Search',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextPrimary(context),
                      ),
                    ),
                    Text(
                      'Enter roll number to begin capture',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.getTextSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Search Input
          Container(
            decoration: BoxDecoration(
              color: AppColors.getInputBackground(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.getBorder(context),
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: rollNumberController,
              maxLength: 5, // Limit to 5 digits
              keyboardType: TextInputType.number, // Only numbers
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(context),
              ),
              decoration: InputDecoration(
                hintText: 'Enter roll number (e.g., 00123)',
                hintStyle: TextStyle(
                  color: AppColors.getTextMuted(context),
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                prefixIcon: Container(
                  padding: EdgeInsets.all(10),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                counterText: '', // Hide character counter
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (value) => controller.searchStudent(value),
            ),
          ),

          SizedBox(height: 16),

          // Search Button
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => controller.searchStudent(rollNumberController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'SEARCH STUDENT',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
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

  Widget _buildStatsDashboard(BuildContext context) {
    final queueService = Get.find<UploadQueueService>();
    final cacheService = Get.find<StudentCacheService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(context),
          ),
        ),
        SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: Obx(() => _buildModernStatCard(
                    context: context,
                    icon: Icons.cloud_upload_rounded,
                    title: 'Pending Uploads',
                    value: '${queueService.pendingCount.value}',
                    subtitle: queueService.pendingCount.value > 0 
                        ? 'Photos waiting' 
                        : 'All synced',
                    color: queueService.pendingCount.value > 0
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF10B981),
                    onTap: () {
                      CustomToast.info(
                        '${queueService.pendingCount.value} photos waiting to upload',
                        icon: Icons.cloud_upload_rounded,
                      );
                    },
                  )),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Obx(() => _buildModernStatCard(
                    context: context,
                    icon: Icons.people_rounded,
                    title: 'Cached Students',
                    value: '${cacheService.cachedStudents.length}',
                    subtitle: 'Available offline',
                    color: const Color(0xFF3B82F6),
                    onTap: () {
                      final stats = cacheService.getCacheStats();
                      CustomToast.info(
                        'Last sync: ${stats['last_sync']} • Total: ${stats['total_students']} students',
                        icon: Icons.people_rounded,
                      );
                    },
                  )),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCenter(BuildContext context) {
    final cacheService = Get.find<StudentCacheService>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(context),
          ),
        ),
        SizedBox(height: 8),
        
        // Action Grid
        Column(
          children: [
            // First Row - QR Scanner (Full Width)
            _buildProfessionalActionCard(
              context: context,
              icon: Icons.qr_code_scanner_rounded,
              title: 'QR Scanner',
              subtitle: 'Scan student QR codes for attendance',
              color: AppColors.primary,
              isFullWidth: true,
              onPressed: () => Get.toNamed(AppRoutes.QR_SCANNER),
            ),
            
            SizedBox(height: 8),
            
            // Second Row - Sync and Student List
            Row(
              children: [
                Expanded(
                  child: Obx(() => _buildProfessionalActionCard(
                        context: context,
                        icon: Icons.sync_rounded,
                        title: 'Sync Students',
                        subtitle: cacheService.isSyncing.value 
                            ? 'Syncing...' 
                            : 'Update database',
                        color: const Color(0xFF3B82F6),
                        isLoading: cacheService.isSyncing.value,
                        onPressed: cacheService.isSyncing.value
                            ? null
                            : () => _showSyncDialog(cacheService, context),
                      )),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildProfessionalActionCard(
                    context: context,
                    icon: Icons.list_alt_rounded,
                    title: 'Student List',
                    subtitle: 'Browse all students',
                    color: const Color(0xFF8B5CF6),
                    onPressed: () => Get.toNamed(AppRoutes.STUDENTS),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 8),
            
            // Third Row - Test Selection and Statistics
            Row(
              children: [
                Expanded(
                  child: _buildProfessionalActionCard(
                    context: context,
                    icon: Icons.assignment_rounded,
                    title: 'Select Test',
                    subtitle: 'Choose test for attendance',
                    color: const Color(0xFF059669),
                    onPressed: () => Get.toNamed(AppRoutes.TEST_SELECTION),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildProfessionalActionCard(
                    context: context,
                    icon: Icons.analytics_rounded,
                    title: 'Statistics',
                    subtitle: 'View attendance stats',
                    color: const Color(0xFF0891B2),
                    onPressed: () => Get.toNamed(AppRoutes.ATTENDANCE_STATS),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 8),
            
            // Fourth Row - History Button (Full Width)
            _buildProfessionalActionCard(
              context: context,
              icon: Icons.history_rounded,
              title: 'View History',
              subtitle: 'Check attendance records',
              color: const Color(0xFF64748B),
              isFullWidth: true,
              onPressed: () {
                try {
                  Get.toNamed(AppRoutes.HISTORY);
                } catch (e) {
                  print('History error: $e');
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernStatCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.getCardBackground(context),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.getShadow(context),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                Icon(
                  Icons.more_horiz_rounded,
                  color: AppColors.getTextMuted(context),
                  size: 20,
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextSecondary(context),
              ),
            ),
            SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.getTextMuted(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    bool isLoading = false,
    bool isFullWidth = false,
    VoidCallback? onPressed,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      height: 125,
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(context),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: color,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Icon(icon, color: color, size: 22),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextPrimary(context),
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.getTextSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.getTextMuted(context),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSyncDialog(StudentCacheService cacheService, BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.getCardBackground(context),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.sync_rounded,
                  color: const Color(0xFF3B82F6),
                  size: 32,
                ),
              ),
              
              SizedBox(height: 20),
              
              Text(
                'Sync Students',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              
              SizedBox(height: 12),
              
              Text(
                'Download all student data for offline use?',
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 20),
              
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: const Color(0xFF3B82F6),
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This will download all students with roll numbers for offline access.',
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 28),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'CANCEL',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF3B82F6),
                            const Color(0xFF3B82F6).withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          cacheService.syncStudents();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'SYNC NOW',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
