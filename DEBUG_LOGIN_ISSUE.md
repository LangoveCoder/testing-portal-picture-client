# Debug Login Issue - Infinite Loading

## Problem
Login button shows infinite loading (spinning circle) and never completes.

## Possible Causes

### 1. **Backend Server Not Running**
- The API server at `http://192.168.0.115:8000` must be running
- Check if your Laravel/backend server is started

**How to test:**
```bash
# In your backend project directory, run:
php artisan serve --host=192.168.0.115 --port=8000
```

### 2. **Wrong IP Address**
- Current configuration uses: `192.168.0.115`
- Your PC's IP might have changed

**How to check:**
1. Open Command Prompt
2. Run: `ipconfig`
3. Look for "IPv4 Address" under your active network adapter
4. Update `app_constants.dart` if IP changed:

```dart
// File: lib/app/core/values/app_constants.dart
return 'http://YOUR_ACTUAL_IP:8000/api';  // Line 15
```

### 3. **Network/Firewall Issues**
- Firewall might be blocking the connection
- Device and PC must be on same WiFi network

**How to test:**
```bash
# From your device/emulator, try to ping:
ping 192.168.0.115

# Or test with browser on device:
# Open: http://192.168.0.115:8000/api/health
```

### 4. **CORS Issues (Web/Chrome)**
- If running on Chrome/Web, CORS might be blocking requests
- Backend must have proper CORS configuration

### 5. **Timeout Not Working**
- Even with 30-second timeout, the request might hang at TCP level

## What I Fixed

1. ✅ Added `TimeoutException` import to auth controller
2. ✅ Added 30-second timeout to login request
3. ✅ Improved error messages for better debugging
4. ✅ Added specific error handling for:
   - Connection timeout
   - Socket exceptions
   - Connection refused

## How to Debug

### Step 1: Check Console Output
When you click login, you should see these logs in the terminal:

```
=== AUTHENTICATING BIOMETRIC OPERATOR ===
Email: your-email@example.com
=== BIOMETRIC OPERATOR LOGIN ===
Base URL: http://192.168.0.115:8000/api
Endpoint: /auth/biometric-operator/login
Full URL: http://192.168.0.115:8000/api/auth/biometric-operator/login
...
```

**If you see nothing after "Full URL"**, the request is hanging.

### Step 2: Check Backend Server
Make sure your backend server is running and accessible:

```bash
# Test endpoint directly
curl http://192.168.0.115:8000/api/auth/biometric-operator/login

# Or open in browser:
http://192.168.0.115:8000/api/health
```

### Step 3: Verify App Constants
Check the IP address in `app_constants.dart`:

```dart
// Current setting (line 15):
return 'http://192.168.0.115:8000/api';

// Make sure this matches your PC's actual IP
```

### Step 4: Test with Different Email/Password
The error might be that the API is working but:
- Email doesn't exist
- Password is wrong
- User is not a biometric operator

## Quick Fix Options

### Option 1: Use Emulator 10.0.2.2
If testing with Android emulator:
```dart
// app_constants.dart line 15:
return 'http://10.0.2.2:8000/api';
```

### Option 2: Test with Postman First
Before testing in app, verify the API works:
```
POST http://192.168.0.115:8000/api/auth/biometric-operator/login
Content-Type: application/json

{
  "email": "operator@example.com",
  "password": "password123",
  "device_type": "android",
  "device_info": "Test"
}
```

### Option 3: Enable More Logging
Add this to your backend to see if requests are arriving:

```php
// In Laravel, add to routes or middleware:
Log::info('Login request received', $request->all());
```

## Next Steps

1. **Verify backend server is running**
2. **Check IP address is correct**
3. **Look at console output when login is clicked**
4. **Share the console output** so I can help debug further

## Test Credentials

Make sure you have a valid biometric operator account in your database with:
- Email
- Password
- Assigned college
- Assigned tests (at least one)

You can create one using Laravel tinker or seeders.
