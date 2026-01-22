import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

/// Secure storage service for sensitive data like tokens
/// Uses AES encryption for Android and Keychain for iOS
class SecureStorageService extends GetxService {
  late FlutterSecureStorage _secureStorage;

  // Storage keys
  static const String _tokenKey = 'auth_token';
  static const String _operatorDataKey = 'operator_data';
  static const String _tokenExpiryKey = 'token_expiry';

  @override
  void onInit() {
    super.onInit();
    _initializeStorage();
  }

  void _initializeStorage() {
    // Configure secure storage with AES encryption
    const androidOptions = AndroidOptions(
      encryptedSharedPreferences: true,
    );

    _secureStorage = const FlutterSecureStorage(
      aOptions: androidOptions,
    );
  }

  // ✅ Save auth token securely
  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
      print('Token saved securely');
    } catch (e) {
      print('Error saving token: $e');
      rethrow;
    }
  }

  // ✅ Read auth token
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      print('Error reading token: $e');
      return null;
    }
  }

  // ✅ Delete auth token
  Future<void> deleteToken() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
      print('Token deleted securely');
    } catch (e) {
      print('Error deleting token: $e');
    }
  }

  // ✅ Save operator data (as JSON string)
  Future<void> saveOperatorData(String jsonData) async {
    try {
      await _secureStorage.write(key: _operatorDataKey, value: jsonData);
      print('Operator data saved securely');
    } catch (e) {
      print('Error saving operator data: $e');
      rethrow;
    }
  }

  // ✅ Read operator data
  Future<String?> getOperatorData() async {
    try {
      return await _secureStorage.read(key: _operatorDataKey);
    } catch (e) {
      print('Error reading operator data: $e');
      return null;
    }
  }

  // ✅ Delete operator data
  Future<void> deleteOperatorData() async {
    try {
      await _secureStorage.delete(key: _operatorDataKey);
      print('Operator data deleted securely');
    } catch (e) {
      print('Error deleting operator data: $e');
    }
  }

  // ✅ Save token expiry
  Future<void> saveTokenExpiry(String expiry) async {
    try {
      await _secureStorage.write(key: _tokenExpiryKey, value: expiry);
    } catch (e) {
      print('Error saving token expiry: $e');
      rethrow;
    }
  }

  // ✅ Read token expiry
  Future<String?> getTokenExpiry() async {
    try {
      return await _secureStorage.read(key: _tokenExpiryKey);
    } catch (e) {
      print('Error reading token expiry: $e');
      return null;
    }
  }

  // ✅ Delete token expiry
  Future<void> deleteTokenExpiry() async {
    try {
      await _secureStorage.delete(key: _tokenExpiryKey);
    } catch (e) {
      print('Error deleting token expiry: $e');
    }
  }

  // ✅ Clear all secure data
  Future<void> clearAll() async {
    try {
      await _secureStorage.deleteAll();
      print('All secure data cleared');
    } catch (e) {
      print('Error clearing secure data: $e');
    }
  }

  // ✅ Check if auth data exists
  Future<bool> hasAuthData() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
