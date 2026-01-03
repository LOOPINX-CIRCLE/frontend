import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

/// Service for securely storing and retrieving sensitive data
/// Uses flutter_secure_storage which provides encrypted storage
class SecureStorageService {
  static const String _tokenKey = 'auth_token';
  
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Store authentication token securely
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
      if (kDebugMode) {
        print('Token saved securely');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving token: $e');
      }
      rethrow;
    }
  }

  /// Retrieve authentication token
  Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (kDebugMode) {
        print('Token retrieved: ${token != null ? 'exists' : 'null'}');
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving token: $e');
      }
      return null;
    }
  }

  /// Remove authentication token
  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
      if (kDebugMode) {
        print('Token deleted');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting token: $e');
      }
    }
  }

  /// Check if token exists
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}

