import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import '../utils/custom_toast.dart';
import 'auth_service.dart';

/// API Error Handler Service
/// Handles HTTP status codes according to context requirements:
/// - 401: Unauthorized - logout and redirect
/// - 403: Forbidden - access denied
/// - 404: Not Found - resource doesn't exist
/// - 409: Conflict - duplicate operation
/// - 422: Validation Error - invalid input
/// - 429: Too Many Requests - rate limit exceeded
/// - 500: Server Error - backend error
class ApiErrorHandler {
  // Retry configuration
  static const int maxRetries = 3;
  static const int retryDelay = 1000; // milliseconds
  static const int rateLimitWait = 60000; // 60 seconds for 429

  /// Handle Dio error and return user-friendly message
  static String handleError(DioException error) {
    final statusCode = error.response?.statusCode;

    switch (statusCode) {
      case 401:
        return _handle401Unauthorized(error);
      case 403:
        return _handle403Forbidden(error);
      case 404:
        return _handle404NotFound(error);
      case 409:
        return _handle409Conflict(error);
      case 422:
        return _handle422ValidationError(error);
      case 429:
        return _handle429RateLimit(error);
      case 500:
      case 502:
      case 503:
        return _handle500ServerError(error);
      default:
        return _handleGenericError(error);
    }
  }

  /// 401 Unauthorized - Token invalid/expired
  /// Action: Logout immediately and redirect to login
  static String _handle401Unauthorized(DioException error) {
    print('=== 401 UNAUTHORIZED ===');

    // ✅ PREVENT INFINITE LOOP: Don't logout if we're already calling logout endpoint
    final path = error.requestOptions.path;
    if (path.contains('/logout')) {
      print('401 during logout - skipping auto-logout to prevent loop');
      return 'Session expired. Please login again.';
    }

    print('Token expired or invalid - logging out');

    // Logout user immediately
    try {
      final authService = getx.Get.find<AuthService>();
      authService.logout();
      getx.Get.offAllNamed('/auth');
    } catch (e) {
      print('Error during auto-logout: $e');
    }

    return 'Session expired. Please login again.';
  }

  /// 403 Forbidden - Access denied
  /// Action: Show error message
  static String _handle403Forbidden(DioException error) {
    print('=== 403 FORBIDDEN ===');

    final data = error.response?.data;
    if (data != null && data is Map) {
      final message = data['message'] ?? 'Access denied';
      print('Forbidden: $message');
      return message;
    }

    return 'Access denied. You do not have permission to access this resource.';
  }

  /// 404 Not Found - Resource doesn't exist
  /// Action: Show error message
  static String _handle404NotFound(DioException error) {
    print('=== 404 NOT FOUND ===');

    final data = error.response?.data;
    if (data != null && data is Map) {
      final message = data['message'] ?? 'Resource not found';
      print('Not found: $message');
      return message;
    }

    return 'Resource not found. Please check and try again.';
  }

  /// 409 Conflict - Duplicate operation
  /// Action: Show error message (e.g., attendance already marked)
  static String _handle409Conflict(DioException error) {
    print('=== 409 CONFLICT ===');

    final data = error.response?.data;
    if (data != null && data is Map) {
      final message = data['message'] ?? 'Duplicate operation';
      print('Conflict: $message');
      return message;
    }

    return 'This operation has already been completed.';
  }

  /// 422 Validation Error - Invalid input
  /// Action: Show validation errors
  static String _handle422ValidationError(DioException error) {
    print('=== 422 VALIDATION ERROR ===');

    final data = error.response?.data;
    if (data != null && data is Map) {
      // Extract validation errors
      if (data.containsKey('errors') && data['errors'] is Map) {
        final errors = data['errors'] as Map;
        final errorMessages = <String>[];

        errors.forEach((field, messages) {
          if (messages is List) {
            errorMessages.addAll(messages.cast<String>());
          } else if (messages is String) {
            errorMessages.add(messages);
          }
        });

        if (errorMessages.isNotEmpty) {
          final combined = errorMessages.join('\n');
          print('Validation errors: $combined');
          return combined;
        }
      }

      // Fallback to message field
      if (data.containsKey('message')) {
        return data['message'];
      }
    }

    return 'Invalid input. Please check your data and try again.';
  }

  /// 429 Too Many Requests - Rate limit exceeded
  /// Action: Wait 60 seconds before retry
  static String _handle429RateLimit(DioException error) {
    print('=== 429 RATE LIMIT EXCEEDED ===');
    print('Waiting 60 seconds before retry...');

    final data = error.response?.data;
    if (data != null && data is Map) {
      final message = data['message'] ?? 'Rate limit exceeded';
      print('Rate limit: $message');
      return '$message Please wait a minute before trying again.';
    }

    return 'Too many requests. Please wait a minute before trying again.';
  }

  /// 500/502/503 Server Error - Backend error
  /// Action: Show generic error message
  static String _handle500ServerError(DioException error) {
    print('=== ${error.response?.statusCode} SERVER ERROR ===');
    print('Server error occurred');

    final data = error.response?.data;
    if (data != null && data is Map && data.containsKey('message')) {
      return 'Server error: ${data['message']}';
    }

    return 'Server error occurred. Please try again later.';
  }

  /// Handle generic errors (network timeout, connection failed, etc.)
  static String _handleGenericError(DioException error) {
    print('=== GENERIC ERROR ===');
    print('Error type: ${error.type}');
    print('Error message: ${error.message}');

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';

      case DioExceptionType.connectionError:
        return 'Connection failed. Please check your internet connection.';

      case DioExceptionType.badResponse:
        return 'Server returned an error. Please try again.';

      case DioExceptionType.cancel:
        return 'Request cancelled.';

      default:
        return 'An error occurred. Please try again.';
    }
  }

  /// Check if error should be retried
  static bool shouldRetry(DioException error) {
    final statusCode = error.response?.statusCode;

    // Do not retry 401 (handled by logout)
    if (statusCode == 401) return false;

    // Do not retry 403, 404, 409, 422 (client errors)
    if (statusCode != null && statusCode >= 400 && statusCode < 500) {
      return false;
    }

    // Retry on 500+ errors or network issues
    if (statusCode != null && statusCode >= 500) {
      return true;
    }

    // Retry on timeouts and connection errors
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return true;
    }

    return false;
  }

  /// Calculate retry delay with exponential backoff
  static int getRetryDelay(int attemptNumber) {
    // Exponential backoff: 1s, 2s, 4s, 8s, etc.
    return retryDelay * (1 << attemptNumber);
  }

  /// Show error toast to user
  static void showErrorToast(String message) {
    CustomToast.error(message);
  }
}
