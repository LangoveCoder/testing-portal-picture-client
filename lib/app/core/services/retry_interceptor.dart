import 'package:dio/dio.dart';
import 'api_error_handler.dart';

/// Retry Interceptor for Dio
/// Implements retry logic with exponential backoff as per context requirements:
/// - Network Timeout: Retry up to 3 times with exponential backoff
/// - 429 Rate Limit: Wait 60 seconds before retry
/// - 500 Server Error: Retry once after 5 seconds
/// - 401 Unauthorized: Do not retry - logout immediately
class RetryInterceptor extends Interceptor {
  final Dio dio;

  RetryInterceptor({required this.dio});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 429) {
      // Rate limit: wait 60 seconds
      await _handleRateLimit(err, handler);
    } else if (err.response?.statusCode != null &&
        err.response!.statusCode! >= 500) {
      // Server error: retry once after 5 seconds
      await _handleServerError(err, handler);
    } else if (ApiErrorHandler.shouldRetry(err)) {
      // Network errors: retry with exponential backoff
      await _handleNetworkError(err, handler);
    } else {
      // No retry needed
      return handler.next(err);
    }
  }

  /// Handle 429 Rate Limit - wait 60 seconds before retry
  Future<void> _handleRateLimit(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    print('Rate limit hit - waiting 60 seconds...');

    await Future.delayed(Duration(milliseconds: ApiErrorHandler.rateLimitWait));

    try {
      print('Retrying after rate limit...');
      final options = err.requestOptions;
      final response = await dio.fetch(options);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  /// Handle 500+ Server Error - retry once after 5 seconds
  Future<void> _handleServerError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final retryCount = err.requestOptions.extra['retry_count'] ?? 0;

    if (retryCount >= 1) {
      // Already retried once, give up
      return handler.next(err);
    }

    print('Server error - retrying after 5 seconds... (attempt ${retryCount + 1}/1)');
    await Future.delayed(Duration(seconds: 5));

    try {
      final options = err.requestOptions;
      options.extra['retry_count'] = retryCount + 1;
      final response = await dio.fetch(options);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  /// Handle Network Error - retry up to 3 times with exponential backoff
  Future<void> _handleNetworkError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final retryCount = err.requestOptions.extra['retry_count'] ?? 0;

    if (retryCount >= ApiErrorHandler.maxRetries) {
      // Max retries reached
      print('Max retries reached ($retryCount/${ApiErrorHandler.maxRetries})');
      return handler.next(err);
    }

    final delay = ApiErrorHandler.getRetryDelay(retryCount);
    print('Network error - retrying in ${delay}ms... (attempt ${retryCount + 1}/${ApiErrorHandler.maxRetries})');

    await Future.delayed(Duration(milliseconds: delay));

    try {
      final options = err.requestOptions;
      options.extra['retry_count'] = retryCount + 1;
      final response = await dio.fetch(options);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }
}
