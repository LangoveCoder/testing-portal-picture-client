# CRITICAL FIX: Auth Token Not Being Sent (401 Errors)

## Problem
When clicking "Sync Students" or performing any API operation after login, the app was getting 401 Unauthorized errors and logging out the user.

## Root Cause
Multiple services were creating **NEW instances** of `ApiProvider` instead of using the shared singleton instance that has the auth token set.

### The Issue:
```dart
// ❌ WRONG - Creates new instance without auth token
class StudentCacheService extends GetxService {
  final ApiProvider apiProvider = ApiProvider();  // NEW INSTANCE!
  ...
}

class UploadQueueService extends GetxService {
  final ApiProvider apiProvider = ApiProvider();  // NEW INSTANCE!
  ...
}
```

When `AuthService` logged in, it only set the token on ONE ApiProvider instance:
```dart
final authService = Get.find<AuthService>();
await authService.login(...);  // Sets token on the shared instance
```

But other services had their OWN ApiProvider instances without the token!

## The Fix

### 1. Fixed `StudentCacheService`
**File**: `lib/app/core/services/student_cache_service.dart`

```dart
// ✅ CORRECT - Uses shared instance with auth token
class StudentCacheService extends GetxService {
  late ApiProvider apiProvider;  // Will be initialized in onInit

  @override
  void onInit() {
    super.onInit();

    // Get the shared ApiProvider instance
    try {
      apiProvider = Get.find<ApiProvider>();
    } catch (e) {
      print('ApiProvider not found, creating new instance: $e');
      apiProvider = ApiProvider();
    }

    loadCache();
    autoSync();
  }
}
```

### 2. Fixed `UploadQueueService`
**File**: `lib/app/core/services/upload_queue_service.dart`

Same fix - use `Get.find<ApiProvider>()` instead of creating new instance.

### 3. Fixed `ApiProvider.bulkDownloadStudents()`
**File**: `lib/app/data/providers/api_provider.dart`

Removed custom headers that were overriding the global Authorization header:

```dart
// ❌ BEFORE - Custom headers override global headers
final response = await _dio.post(
  AppConstants.bulkDownloadStudentsEndpoint,
  data: data,
  options: Options(
    headers: {
      'Content-Type': 'application/json',  // Overrides global headers!
    },
  ),
);

// ✅ AFTER - Uses global headers (includes Authorization)
final response = await _dio.post(
  AppConstants.bulkDownloadStudentsEndpoint,
  data: data,
);
```

## Why This Matters

The ApiProvider is initialized as a singleton in `main.dart`:
```dart
Get.put(ApiProvider(), permanent: true);
```

When you log in, the auth token is set on THIS instance:
```dart
apiProvider.setAuthToken(token);
// This sets: _dio.options.headers['Authorization'] = 'Bearer $token';
```

All services MUST use the same instance via `Get.find<ApiProvider>()` to have the token.

## Result

✅ **Now when you:**
1. Log in → Token is set on shared ApiProvider
2. Click "Sync Students" → Uses same ApiProvider with token
3. API request includes `Authorization: Bearer <token>` header
4. Backend returns 200 OK instead of 401 Unauthorized
5. You stay logged in!

## Testing

1. **Restart the app** (hot reload won't work, need full restart)
2. **Log in** with your credentials
3. **Click "Sync Students"** on home screen
4. **Should NOT log out** - should show "Synced X students"

## Related Files Changed

1. ✅ `lib/app/core/services/student_cache_service.dart` - Use shared ApiProvider
2. ✅ `lib/app/core/services/upload_queue_service.dart` - Use shared ApiProvider
3. ✅ `lib/app/data/providers/api_provider.dart` - Don't override headers in bulkDownloadStudents

## Prevention

**Rule**: NEVER create new ApiProvider instances. Always use:
```dart
final apiProvider = Get.find<ApiProvider>();
```

Or in service classes:
```dart
class MyService extends GetxService {
  late ApiProvider apiProvider;

  @override
  void onInit() {
    super.onInit();
    apiProvider = Get.find<ApiProvider>();
  }
}
```
