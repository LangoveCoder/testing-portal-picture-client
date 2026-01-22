import 'dart:convert';
import 'package:get/get.dart';
import '../../data/models/biometric_operator_model.dart';
import '../../data/providers/api_provider.dart';
import '../utils/custom_toast.dart';
import 'secure_storage_service.dart';

class AuthService extends GetxService {
  late ApiProvider _apiProvider;
  late SecureStorageService _secureStorage;

  final Rx<BiometricOperatorModel?> currentOperator =
      Rx<BiometricOperatorModel?>(null);
  final RxBool isAuthenticated = false.obs;
  final RxString authToken = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _apiProvider = Get.find<ApiProvider>();
    _secureStorage = Get.find<SecureStorageService>();
    _loadStoredAuth();
  }

  // ✅ Load stored authentication from secure storage
  Future<void> _loadStoredAuth() async {
    try {
      final token = await _secureStorage.getToken();
      final operatorDataJson = await _secureStorage.getOperatorData();
      final expiry = await _secureStorage.getTokenExpiry();

      if (token != null && operatorDataJson != null && expiry != null) {
        final expiryDate = DateTime.parse(expiry);

        if (expiryDate.isAfter(DateTime.now())) {
          authToken.value = token;
          final operatorData = jsonDecode(operatorDataJson);
          currentOperator.value = BiometricOperatorModel.fromJson(operatorData);
          isAuthenticated.value = true;
          _apiProvider.setAuthToken(token);
          print('Auth loaded from secure storage');
          print('Token: Bearer ${token.substring(0, 20)}...');
          print('Operator: ${currentOperator.value?.name}');
          print('College: ${currentOperator.value?.assignedCollege?.name}');
        } else {
          print('Token expired - clearing stored data silently');
          // ✅ Just clear data silently - don't call logout API
          await _secureStorage.clearAll();
          authToken.value = '';
          currentOperator.value = null;
          isAuthenticated.value = false;
        }
      } else {
        print('No stored auth found');
      }
    } catch (e) {
      print('Error loading stored auth: $e');
      // ✅ Just clear data silently - don't call logout API
      await _secureStorage.clearAll();
      authToken.value = '';
      currentOperator.value = null;
      isAuthenticated.value = false;
    }
  }

  // ✅ Login - BIOMETRIC OPERATORS ONLY
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiProvider.biometricOperatorLogin(
        email: email,
        password: password,
      );

      print('=== RAW API RESPONSE ===');
      print('Response data: ${response.data}');
      print('=======================');

      final loginResponse = LoginResponse.fromJson(response.data);

      print('=== PARSED LOGIN RESPONSE ===');
      print('Success: ${loginResponse.success}');
      print('Operator: ${loginResponse.operator?.name}');
      print('Tests in operator: ${loginResponse.operator?.tests.length}');
      print('=============================');

      if (loginResponse.success && loginResponse.operator != null) {
        // Store authentication data in secure storage
        authToken.value = loginResponse.token ?? '';
        currentOperator.value = loginResponse.operator;
        isAuthenticated.value = true;

        // Save to secure storage
        await _secureStorage.saveToken(loginResponse.token ?? '');
        await _secureStorage.saveOperatorData(
          jsonEncode(loginResponse.operator!.toJson()),
        );

        // Calculate expiry (30 days from now if not provided)
        final expiry = loginResponse.expiresAt ??
                       DateTime.now().add(Duration(days: 30)).toIso8601String();
        await _secureStorage.saveTokenExpiry(expiry);

        _apiProvider.setAuthToken(loginResponse.token ?? '');

        CustomToast.success('Welcome, ${loginResponse.operator!.name}!');
        return true;
      } else {
        CustomToast.error(loginResponse.message);
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      CustomToast.error('Login failed. Please check your credentials.');
      return false;
    }
  }

  // ✅ Logout - calls API endpoint
  Future<void> logout() async {
    print('=== LOGOUT API CALL ===');

    try {
      // ✅ Only call logout API if we have a valid token
      if (authToken.value.isNotEmpty) {
        print('Calling logout API with token');
        await _apiProvider.logout();
        print('Logout response: 200');
      } else {
        print('No token - skipping API logout call');
      }
    } catch (e) {
      print('Logout API error (continuing with local logout): $e');
    } finally {
      // Clear local data regardless of API call success
      authToken.value = '';
      currentOperator.value = null;
      isAuthenticated.value = false;

      // Clear secure storage
      await _secureStorage.clearAll();
      print('All secure data cleared');

      _apiProvider.clearAuthToken();
      print('Auth token cleared');
    }
  }

  // ✅ Refresh Token
  Future<bool> refreshToken() async {
    try {
      print('Refreshing token...');
      final response = await _apiProvider.refreshToken();

      if (response.statusCode == 200 && response.data['success'] == true) {
        final newToken = response.data['token'];
        authToken.value = newToken;

        // Save new token to secure storage
        await _secureStorage.saveToken(newToken);

        // Update expiry (30 days from now)
        final newExpiry = DateTime.now().add(Duration(days: 30)).toIso8601String();
        await _secureStorage.saveTokenExpiry(newExpiry);

        _apiProvider.setAuthToken(newToken);
        print('Token refreshed successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('Token refresh failed: $e');
      return false;
    }
  }

  // ✅ Get current operator profile from API
  Future<BiometricOperatorModel?> fetchCurrentOperator() async {
    try {
      final response = await _apiProvider.getCurrentOperator();

      if (response.statusCode == 200 && response.data['success'] == true) {
        final operator = BiometricOperatorModel.fromJson(response.data['operator']);
        currentOperator.value = operator;

        // Save updated operator data to secure storage
        await _secureStorage.saveOperatorData(
          jsonEncode(operator.toJson()),
        );
        return operator;
      }
      return null;
    } catch (e) {
      print('Fetch operator error: $e');
      return null;
    }
  }

  // ✅ Check if token is still valid
  Future<bool> isTokenValid() async {
    try {
      final expiry = await _secureStorage.getTokenExpiry();
      if (expiry == null) return false;

      final expiryDate = DateTime.parse(expiry);
      return expiryDate.isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  // ✅ Get operator info
  BiometricOperatorModel? getOperator() {
    return currentOperator.value;
  }

  // ✅ Get operator name
  String getOperatorName() {
    return currentOperator.value?.name ?? 'Operator';
  }

  // ✅ Get operator email
  String getOperatorEmail() {
    return currentOperator.value?.email ?? '';
  }

  // ✅ Get assigned college
  CollegeInfo? getAssignedCollege() {
    return currentOperator.value?.assignedCollege;
  }

  // ✅ Get assigned college name
  String getAssignedCollegeName() {
    return currentOperator.value?.assignedCollege?.name ??
        'No College Assigned';
  }

  // ✅ Check permissions
  bool canViewStudents() {
    return currentOperator.value?.permissions.canViewStudents ?? false;
  }

  bool canRegisterFingerprints() {
    return currentOperator.value?.permissions.canRegisterFingerprints ?? false;
  }

  bool canVerifyFingerprints() {
    return currentOperator.value?.permissions.canVerifyFingerprints ?? false;
  }
}
