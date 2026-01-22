class AppConstants {
  // ✅ Environment-based URL configuration
  // Development: HTTP with local IP
  // Production: HTTPS with domain
  static const bool isProduction = false; // ✅ Set to true for production builds

  static String get baseUrl {
    if (isProduction) {
      // ✅ PRODUCTION: Use HTTPS with your production domain
      return 'https://api.admission-portal.com/api';
    } else {
      // ✅ DEVELOPMENT: Use HTTP with local IP
      // For real device testing, use your PC's IP (192.168.x.x)
      // For emulator testing, use 10.0.2.2
      return 'http://192.168.100.169:8000/api';
    }
  }

  static const String biometricPrefix = '/biometric';
  static const String attendancePrefix = '/attendance';
  static const String operatorPrefix = '/operator';
  static const String authPrefix = '/auth';
  static const String syncPrefix = '/sync';
  static const String bulkPrefix = '/bulk';

  // Auth API Endpoints
  static const String loginEndpoint = '$authPrefix/biometric-operator/login';
  static const String logoutEndpoint = '$operatorPrefix/logout';
  static const String refreshTokenEndpoint = '$operatorPrefix/refresh-token';
  static const String operatorMeEndpoint = '$operatorPrefix/me';

  // Biometric API Endpoints (existing)
  static const String collegesEndpoint = '/colleges';
  static const String studentInfoEndpoint = '/student/info';
  static const String uploadPhotoEndpoint = '/photos/upload';
  static const String uploadPhotoBase64Endpoint = '/photos/upload-base64';

  // Attendance API Endpoints
  static const String attendanceStudentInfoEndpoint =
      '$attendancePrefix/student-info';
  static const String markAttendanceEndpoint = '$attendancePrefix/mark';
  static const String bulkMarkAttendanceEndpoint =
      '$attendancePrefix/bulk-mark';
  static const String updateAttendanceEndpoint = '$attendancePrefix/update';
  static const String attendanceStatsEndpoint = '$attendancePrefix/stats';
  static const String attendanceListEndpoint = '$attendancePrefix/list';

  // Sync API Endpoints
  static const String syncQueueEndpoint = '$syncPrefix/queue';
  static const String syncProcessEndpoint = '$syncPrefix/process';
  static const String syncStatusEndpoint = '$syncPrefix/status';
  static const String syncClearCompletedEndpoint =
      '$syncPrefix/clear-completed';

  // Bulk API Endpoints
  static const String bulkDownloadStudentsEndpoint =
      '$bulkPrefix/students/download';

  // Storage Keys
  static const String pinKey = 'app_pin';
  static const String isAuthenticatedKey = 'is_authenticated';
  static const String selectedCollegeKey = 'selected_college';
  static const String assignedCollegesKey = 'assigned_colleges';
  static const String operatorNameKey = 'operator_name';
  static const String operatorIdKey = 'operator_id';
  static const String currentTestIdKey = 'current_test_id';
  static const String pendingAttendanceKey = 'pending_attendance';

  // App Settings
  static const String appName = 'BACT Attendance Client';
  static const String appPin =
      'BACT2025'; // Default PIN - change this in production

  // Camera Settings
  static const int imageQuality = 85;
  static const int maxImageSize = 2048; // pixels

  // Timeouts
  static const int connectionTimeout = 60000; // ✅ Increased to 60 seconds
  static const int receiveTimeout = 60000; // ✅ Increased to 60 seconds

  // Attendance Settings
  static const int maxOfflineRecords = 1000;
  static const int syncRetryAttempts = 3;
}
