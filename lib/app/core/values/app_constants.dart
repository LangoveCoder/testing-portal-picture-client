class AppConstants {
  // API Configuration
  static const String baseUrl =
      'http://192.168.100.169/admission-portal/public/api';
  static const String biometricPrefix = '/biometric';

  // API Endpoints
  static const String collegesEndpoint = '$biometricPrefix/colleges';
  static const String studentInfoEndpoint = '$biometricPrefix/student/info';
  static const String uploadPhotoEndpoint =
      '$biometricPrefix/student/upload-photo';

  // Storage Keys
  static const String pinKey = 'app_pin';
  static const String isAuthenticatedKey = 'is_authenticated';
  static const String selectedCollegeKey = 'selected_college'; // ADD THIS
  static const String assignedCollegesKey = 'assigned_colleges'; // ADD THIS
  static const String operatorNameKey = 'operator_name';

  // App Settings
  static const String appName = 'BACT Photo Capture';
  static const String appPin =
      'BACT2025'; // Default PIN - change this in production

  // Camera Settings
  static const int imageQuality = 85;
  static const int maxImageSize = 2048; // pixels

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;
}
