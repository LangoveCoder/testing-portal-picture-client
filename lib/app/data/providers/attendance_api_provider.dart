import 'package:dio/dio.dart';
import '../../core/values/app_constants.dart';
import '../models/attendance_request_model.dart';

class AttendanceApiProvider {
  late Dio _dio;

  AttendanceApiProvider() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: Duration(milliseconds: AppConstants.connectionTimeout),
      receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors for logging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('API: $obj'),
    ));
  }

  /// Get student information for attendance
  Future<Response> getAttendanceStudentInfo(String rollNumber, int testId) async {
    try {
      print('=== GET ATTENDANCE STUDENT INFO ===');
      print('Roll Number: $rollNumber');
      print('Test ID: $testId');

      final response = await _dio.post(
        AppConstants.attendanceStudentInfoEndpoint,
        data: {
          'roll_number': rollNumber,
          'test_id': testId,
        },
      );

      print('Response: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      print('API Error: ${e.message}');
      print('Response: ${e.response?.data}');
      rethrow;
    }
  }

  /// Mark student attendance
  Future<Response> markAttendance(AttendanceRequestModel request) async {
    try {
      print('=== MARK ATTENDANCE ===');
      print('Roll Number: ${request.rollNumber}');
      print('Status: ${request.attendanceStatus}');
      print('Test ID: ${request.testId}');

      final response = await _dio.post(
        AppConstants.markAttendanceEndpoint,
        data: request.toJson(),
      );

      print('Response: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      print('API Error: ${e.message}');
      print('Response: ${e.response?.data}');
      rethrow;
    }
  }

  /// Bulk mark attendance (for offline sync)
  Future<Response> bulkMarkAttendance(List<AttendanceRequestModel> requests) async {
    try {
      print('=== BULK MARK ATTENDANCE ===');
      print('Records count: ${requests.length}');

      final response = await _dio.post(
        AppConstants.bulkMarkAttendanceEndpoint,
        data: {
          'attendance_records': requests.map((r) => r.toJson()).toList(),
        },
      );

      print('Response: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      print('API Error: ${e.message}');
      print('Response: ${e.response?.data}');
      rethrow;
    }
  }

  /// Update existing attendance
  Future<Response> updateAttendance({
    required String rollNumber,
    required int testId,
    required String attendanceStatus,
    required String updatedBy,
    String? reason,
  }) async {
    try {
      print('=== UPDATE ATTENDANCE ===');
      print('Roll Number: $rollNumber');
      print('New Status: $attendanceStatus');

      final response = await _dio.put(
        AppConstants.updateAttendanceEndpoint,
        data: {
          'roll_number': rollNumber,
          'test_id': testId,
          'attendance_status': attendanceStatus,
          'updated_by': updatedBy,
          'reason': reason,
        },
      );

      print('Response: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      print('API Error: ${e.message}');
      print('Response: ${e.response?.data}');
      rethrow;
    }
  }

  /// Get attendance statistics
  Future<Response> getAttendanceStats(int testId) async {
    try {
      print('=== GET ATTENDANCE STATS ===');
      print('Test ID: $testId');

      final response = await _dio.get(
        '${AppConstants.attendanceStatsEndpoint}?test_id=$testId',
      );

      print('Response: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      print('API Error: ${e.message}');
      print('Response: ${e.response?.data}');
      rethrow;
    }
  }

  /// Get attendance list
  Future<Response> getAttendanceList({
    required int testId,
    String? status,
    int page = 1,
    int perPage = 50,
  }) async {
    try {
      print('=== GET ATTENDANCE LIST ===');
      print('Test ID: $testId');
      print('Status: $status');
      print('Page: $page');

      String url = '${AppConstants.attendanceListEndpoint}?test_id=$testId&page=$page&per_page=$perPage';
      if (status != null) {
        url += '&status=$status';
      }

      final response = await _dio.get(url);

      print('Response: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      print('API Error: ${e.message}');
      print('Response: ${e.response?.data}');
      rethrow;
    }
  }

  /// Check network connectivity
  Future<bool> checkConnectivity() async {
    try {
      final response = await _dio.get(
        AppConstants.attendanceStatsEndpoint,
        options: Options(
          sendTimeout: Duration(milliseconds: 5000),
          receiveTimeout: Duration(milliseconds: 5000),
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}