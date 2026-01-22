# Development Mode - Simplified Setup

## What Was Changed

We've temporarily disabled authentication and complex service initialization to focus on fixing core attendance functionality.

### Changes Made:

1. **Auth Controller** (`lib/app/modules/auth/controllers/auth_controller.dart`)
   - Bypassed real API authentication
   - Any email/password now creates a dummy operator
   - Creates dummy college and test data
   - Goes directly to home screen

2. **Main.dart** (`lib/main.dart`)
   - Removed all service initialization except ApiProvider
   - Simplified startup to prevent circular dependencies
   - Services will be initialized on-demand when needed

### How to Use:

1. **Login**: Enter ANY email and password
   - Example: `test@test.com` / `password`
   - Will create a test operator and go to home

2. **Features Available**:
   - ✅ Student list (if you have cached students)
   - ✅ Search students
   - ✅ Mark attendance (present/late/absent)
   - ✅ View synced students

3. **Features NOT Available** (temporarily):
   - ❌ Real authentication with backend
   - ❌ Token-based API calls
   - ❌ Offline sync
   - ❌ Upload queue

## Next Steps:

Once we fix the core attendance marking flow, we'll:
1. Re-enable proper service initialization
2. Add back authentication
3. Fix token propagation
4. Enable offline sync and upload queue

## To Re-Enable Full Auth:

When ready to restore full authentication:
1. Restore the original `authenticateOperator()` method in auth_controller.dart
2. Restore full service initialization in main.dart
3. Ensure services initialize in correct order to avoid circular dependencies
