import 'package:dio/dio.dart';
import '../../core/values/app_constants.dart';
import '../../core/services/retry_interceptor.dart';
import '../../core/services/api_error_handler.dart';

class ApiProvider {
  late Dio _dio;

  ApiProvider() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 60), // ✅ 60 seconds
      receiveTimeout: const Duration(seconds: 60), // ✅ 60 seconds
      headers: {
        'Accept': 'application/json',
      },
    ));

    // Add retry interceptor FIRST (before logging)
    _dio.interceptors.add(RetryInterceptor(dio: _dio));

    // Add logging interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('REQUEST[${options.method}] => PATH: ${options.path}');
        print('REQUEST DATA TYPE: ${options.data.runtimeType}');
        print('REQUEST HEADERS: ${options.headers}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('RESPONSE[${response.statusCode}] => DATA: ${response.data}');
        return handler.next(response);
      },
      onError: (error, handler) {
        print('ERROR[${error.response?.statusCode}] => MESSAGE: ${error.message}');
        print('ERROR DATA: ${error.response?.data}');

        // Handle error with ApiErrorHandler
        final errorMessage = ApiErrorHandler.handleError(error);
        ApiErrorHandler.showErrorToast(errorMessage);

        return handler.next(error);
      },
    ));
  }

  // ✅ Set Auth Token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    print('Auth token set: Bearer ${token.substring(0, 10)}...');
  }

  // ✅ Clear Auth Token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
    print('Auth token cleared');
  }

  // ✅ Biometric Operator Login
  Future<Response> biometricOperatorLogin({
    required String email,
    required String password,
  }) async {
    try {
      print('=== BIOMETRIC OPERATOR LOGIN ===');
      print('Base URL: ${AppConstants.baseUrl}');
      print('Endpoint: /auth/biometric-operator/login');
      print('Full URL: ${AppConstants.baseUrl}/auth/biometric-operator/login');
      print('Email: $email');
      print('Password length: ${password.length}');

      final requestData = {
        'email': email,
        'password': password,
        'device_type': 'android',
        'device_info': 'Flutter App v1.0.0 - Mobile Device',
      };

      print('Request data: $requestData');

      final response = await _dio.post(
        '/auth/biometric-operator/login',
        data: requestData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          validateStatus: (status) {
            // Accept all status codes to handle them manually
            return status != null && status < 500;
          },
        ),
      );

      print('=== API RESPONSE RECEIVED ===');
      print('Status Code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Data Type: ${response.data.runtimeType}');
      print('Raw Response: ${response.data}');

      return response;
    } catch (e) {
      print('=== API PROVIDER ERROR ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');

      if (e is DioException) {
        print('DioException details:');
        print('- Type: ${e.type}');
        print('- Message: ${e.message}');
        print('- Response status: ${e.response?.statusCode}');
        print('- Response data: ${e.response?.data}');
        print('- Request path: ${e.requestOptions.path}');
        print('- Request data: ${e.requestOptions.data}');
      }

      rethrow;
    }
  }

  // ✅ KEEP: Authenticate Operator (legacy - for compatibility)
  Future<Response> authenticateOperator(String email, String password) async {
    // Redirect to new method
    return await biometricOperatorLogin(email: email, password: password);
  }

  // ✅ Logout - calls API endpoint
  Future<Response> logout() async {
    try {
      print('=== LOGOUT API CALL ===');
      final response = await _dio.post(
        AppConstants.logoutEndpoint,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      print('Logout response: ${response.statusCode}');
      return response;
    } catch (e) {
      print('Logout error: $e');
      rethrow;
    }
  }

  // ✅ Refresh Token
  Future<Response> refreshToken() async {
    try {
      print('=== REFRESH TOKEN ===');
      final response = await _dio.post(
        AppConstants.refreshTokenEndpoint,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      print('Token refreshed: ${response.statusCode}');
      return response;
    } catch (e) {
      print('Token refresh error: $e');
      rethrow;
    }
  }

  // ✅ Get Current Operator Profile
  Future<Response> getCurrentOperator() async {
    try {
      print('=== GET CURRENT OPERATOR ===');
      final response = await _dio.get(
        AppConstants.operatorMeEndpoint,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      print('Operator profile: ${response.statusCode}');
      return response;
    } catch (e) {
      print('Get operator error: $e');
      rethrow;
    }
  }

  // Get Available Tests for College and Operator
  Future<Response> getAvailableTests({
    required int collegeId,
    required int operatorId,
  }) async {
    try {
      print(
          'Getting available tests for college: $collegeId, operator: $operatorId');
      return await _dio.get(
        '/attendance/tests/available',
        queryParameters: {
          'college_id': collegeId,
          'operator_id': operatorId,
        },
      );
    } catch (e) {
      print('Error getting tests: $e');
      rethrow;
    }
  }

  // Get Active Colleges
  Future<Response> getActiveColleges() async {
    try {
      return await _dio.get(AppConstants.collegesEndpoint);
    } catch (e) {
      rethrow;
    }
  }

  // Get Student Info
  Future<Response> getStudentInfo(String rollNumber) async {
    try {
      print('Fetching student info for: $rollNumber');
      final response = await _dio.post(
        AppConstants.studentInfoEndpoint,
        data: {'roll_number': rollNumber},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      print('Student info response: ${response.data}');
      return response;
    } catch (e) {
      print('Error fetching student: $e');
      rethrow;
    }
  }

  // Upload Photo (Multipart)
  Future<Response> uploadPhoto(String rollNumber, String imagePath) async {
    try {
      print('=== UPLOAD PHOTO DEBUG ===');
      print('Roll Number: $rollNumber');
      print('Image Path: $imagePath');
      print(
          'Full URL: ${AppConstants.baseUrl}${AppConstants.uploadPhotoEndpoint}');

      // Create filename with timestamp
      String fileName =
          '${rollNumber}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      print('Filename: $fileName');

      // Create form data
      FormData formData = FormData.fromMap({
        'roll_number': rollNumber,
        'test_photo': await MultipartFile.fromFile(
          imagePath,
          filename: fileName,
        ),
      });

      print('FormData created successfully');
      print('Sending POST request...');

      final response = await _dio.post(
        AppConstants.uploadPhotoEndpoint,
        data: formData,
      );

      print('Upload response received: ${response.statusCode}');
      print('Response data: ${response.data}');
      return response;
    } catch (e) {
      print('Upload error: $e');
      if (e is DioException) {
        print('DioException type: ${e.type}');
        print('DioException response: ${e.response?.data}');
        print('DioException status: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }

  // ✅ Bulk download students with college filter
  Future<Response> bulkDownloadStudents({
    int? testId,
    int? collegeId, // ✅ ADDED
  }) async {
    try {
      print('Bulk downloading students...');
      print('Test ID filter: $testId');
      print('College ID filter: $collegeId');

      Map<String, dynamic> data = {};
      if (testId != null) {
        data['test_id'] = testId;
      }
      if (collegeId != null) {
        // ✅ ADDED
        data['college_id'] = collegeId;
      }

      final response = await _dio.post(
        AppConstants.bulkDownloadStudentsEndpoint,
        data: data,
      );

      print('Downloaded ${response.data['count']} students');
      return response;
    } catch (e) {
      print('Bulk download error: $e');
      rethrow;
    }
  }
}
