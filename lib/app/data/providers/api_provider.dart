import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import '../../core/values/app_constants.dart';

class ApiProvider {
  late Dio _dio;

  ApiProvider() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout:
          const Duration(milliseconds: AppConstants.connectionTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {
        'Accept': 'application/json',
      },
    ));

    // Add interceptors for logging
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
        print(
            'ERROR[${error.response?.statusCode}] => MESSAGE: ${error.message}');
        print('ERROR DATA: ${error.response?.data}');
        return handler.next(error);
      },
    ));
  }

  // Validate PIN
  Future<Response> validatePin(String pin) async {
    try {
      // For now, validate locally
      if (pin == AppConstants.appPin) {
        return Response(
          requestOptions: RequestOptions(path: ''),
          data: {'success': true, 'message': 'Access granted'},
          statusCode: 200,
        );
      } else {
        return Response(
          requestOptions: RequestOptions(path: ''),
          data: {'success': false, 'message': 'Invalid PIN'},
          statusCode: 401,
        );
      }
    } catch (e) {
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

  // Bulk download students
  Future<Response> bulkDownloadStudents({int? testId}) async {
    try {
      print('Bulk downloading students...');

      Map<String, dynamic> data = {};
      if (testId != null) {
        data['test_id'] = testId;
      }

      final response = await _dio.post(
        '/biometric/students/bulk-download',
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Downloaded ${response.data['count']} students');
      return response;
    } catch (e) {
      print('Bulk download error: $e');
      rethrow;
    }
  }
}
