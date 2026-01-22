import 'package:dio/dio.dart';
import '../../core/values/app_constants.dart';

/// Sync API Provider
/// Implements sync endpoints as per context requirements:
/// - POST /api/sync/queue - Queue data for synchronization
/// - POST /api/sync/process - Process pending sync
/// - GET /api/sync/status - Get sync status
/// - DELETE /api/sync/clear-completed - Clear completed sync records
class SyncApiProvider {
  late Dio _dio;

  SyncApiProvider() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: Duration(milliseconds: AppConstants.connectionTimeout),
      receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add logging interceptor
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('SYNC API: $obj'),
    ));
  }

  /// Set authentication token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    print('[SyncApiProvider] Auth token set');
  }

  /// Clear authentication token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
    print('[SyncApiProvider] Auth token cleared');
  }

  /// Queue data for synchronization
  /// POST /api/sync/queue
  Future<Response> queueSync({
    required String deviceId,
    required String syncType,
    required List<Map<String, dynamic>> payload,
  }) async {
    try {
      print('=== QUEUE SYNC ===');
      print('Device ID: $deviceId');
      print('Sync Type: $syncType');
      print('Payload count: ${payload.length}');

      final response = await _dio.post(
        AppConstants.syncQueueEndpoint,
        data: {
          'device_id': deviceId,
          'sync_type': syncType,
          'payload': payload,
        },
      );

      print('Queue response: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      print('Queue sync error: ${e.message}');
      print('Response: ${e.response?.data}');
      rethrow;
    }
  }

  /// Process pending sync
  /// POST /api/sync/process
  Future<Response> processSync({
    required String deviceId,
  }) async {
    try {
      print('=== PROCESS SYNC ===');
      print('Device ID: $deviceId');

      final response = await _dio.post(
        AppConstants.syncProcessEndpoint,
        data: {
          'device_id': deviceId,
        },
      );

      print('Process response: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      print('Process sync error: ${e.message}');
      print('Response: ${e.response?.data}');
      rethrow;
    }
  }

  /// Get sync status
  /// GET /api/sync/status?device_id=xxx
  Future<Response> getSyncStatus({
    required String deviceId,
  }) async {
    try {
      print('=== GET SYNC STATUS ===');
      print('Device ID: $deviceId');

      final response = await _dio.get(
        '${AppConstants.syncStatusEndpoint}?device_id=$deviceId',
      );

      print('Status response: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      print('Get sync status error: ${e.message}');
      print('Response: ${e.response?.data}');
      rethrow;
    }
  }

  /// Clear completed sync records
  /// DELETE /api/sync/clear-completed?device_id=xxx
  Future<Response> clearCompletedSync({
    required String deviceId,
  }) async {
    try {
      print('=== CLEAR COMPLETED SYNC ===');
      print('Device ID: $deviceId');

      final response = await _dio.delete(
        '${AppConstants.syncClearCompletedEndpoint}?device_id=$deviceId',
      );

      print('Clear response: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      print('Clear completed sync error: ${e.message}');
      print('Response: ${e.response?.data}');
      rethrow;
    }
  }
}
