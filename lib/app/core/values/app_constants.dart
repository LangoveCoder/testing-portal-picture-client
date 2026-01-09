class AppConstants {
  // API Configuration - Use localhost for local development
  static const String baseUrl = 'http://10.0.2.2:8000/api';  // Android emulator localhost
  static const String biometricPrefix = '/biometric';
  static const String attendancePrefix = '/attendance';

  // Biometric API Endpoints (existing)
  static const String collegesEndpoint = '$biometricPrefix/colleges';
  static const String studentInfoEndpoint = '$biometricPrefix/student/info';
  static const String uploadPhotoEndpoint = '$biometricPrefix/student/upload-photo';

  // Attendance API Endpoints (new)
  static const String attendanceStudentInfoEndpoint = '$attendancePrefix/student-info';
  static const String markAttendanceEndpoint = '$attendancePrefix/mark';
  static const String bulkMarkAttendanceEndpoint = '$attendancePrefix/bulk-mark';
  static const String updateAttendanceEndpoint = '$attendancePrefix/update';
  static const String attendanceStatsEndpoint = '$attendancePrefix/stats';
  static const String attendanceListEndpoint = '$attendancePrefix/list';

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
  static const String appPin = 'BACT2025'; // Default PIN - change this in production

  // Camera Settings
  static const int imageQuality = 85;
  static const int maxImageSize = 2048; // pixels

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;

  // Attendance Settings
  static const int maxOfflineRecords = 1000;
  static const int syncRetryAttempts = 3;
}
