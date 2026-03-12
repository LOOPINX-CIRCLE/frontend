import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

/// Service for securely storing and retrieving sensitive data
/// Uses flutter_secure_storage which provides encrypted storage
class SecureStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _firstLaunchKey = 'is_first_launch';
  static const String _pendingPaymentOrderIdKey = 'pending_payment_order_id';
  static const String _pendingPaymentEventIdKey = 'pending_payment_event_id';
  static const String _pendingPaymentTimestampKey = 'pending_payment_timestamp';
  
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
      // âœ… Ensure no whitespace in stored token
      final cleanToken = token.trim();
      await _storage.write(key: _tokenKey, value: cleanToken);
      if (kDebugMode) {
      }
    } catch (e) {
      if (kDebugMode) {
      }
      rethrow;
    }
  }

  /// Retrieve authentication token
  Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      return token;
    } catch (e) {
      if (kDebugMode) {
      }
      return null;
    }
  }

  /// Remove authentication token
  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
      if (kDebugMode) {
      }
    } catch (e) {
      if (kDebugMode) {
      }
    }
  }

  /// Check if token exists
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ============ First Launch Flag Methods ============
  // Used to show intro video only on first app launch

  /// Check if this is the first time the app is being launched
  Future<bool> isFirstLaunch() async {
    try {
      final value = await _storage.read(key: _firstLaunchKey);
      return value == null; // null means first launch
    } catch (e) {
      if (kDebugMode) {
      }
      return true; // Assume first launch on error
    }
  }

  /// Mark that the app has been launched (after first launch)
  Future<void> markFirstLaunchComplete() async {
    try {
      await _storage.write(key: _firstLaunchKey, value: 'false');
      if (kDebugMode) {
      }
    } catch (e) {
      if (kDebugMode) {
      }
    }
  }

  // ============ Pending Payment Methods ============
  // Used to recover payment state if app is killed during UPI payment

  /// Save pending payment info before launching UPI app
  Future<void> savePendingPayment({
    required String orderId,
    required int eventId,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      await _storage.write(key: _pendingPaymentOrderIdKey, value: orderId);
      await _storage.write(key: _pendingPaymentEventIdKey, value: eventId.toString());
      await _storage.write(key: _pendingPaymentTimestampKey, value: timestamp);
      if (kDebugMode) {
      }
    } catch (e) {
      if (kDebugMode) {
      }
    }
  }

  /// Get pending payment info
  Future<Map<String, dynamic>?> getPendingPayment() async {
    try {
      final orderId = await _storage.read(key: _pendingPaymentOrderIdKey);
      final eventIdStr = await _storage.read(key: _pendingPaymentEventIdKey);
      final timestampStr = await _storage.read(key: _pendingPaymentTimestampKey);

      if (orderId == null || eventIdStr == null || timestampStr == null) {
        return null;
      }

      final eventId = int.tryParse(eventIdStr);
      final timestamp = int.tryParse(timestampStr);

      if (eventId == null || timestamp == null) {
        return null;
      }

      // Check if payment is still valid (within 10 minutes)
      final paymentTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(paymentTime);

      if (difference.inMinutes > 10) {
        // Payment expired, clear it
        await clearPendingPayment();
        if (kDebugMode) {
        }
        return null;
      }

      if (kDebugMode) {
      }

      return {
        'orderId': orderId,
        'eventId': eventId,
        'timestamp': timestamp,
      };
    } catch (e) {
      if (kDebugMode) {
      }
      return null;
    }
  }

  /// Clear pending payment info (after successful verification or expiry)
  Future<void> clearPendingPayment() async {
    try {
      await _storage.delete(key: _pendingPaymentOrderIdKey);
      await _storage.delete(key: _pendingPaymentEventIdKey);
      await _storage.delete(key: _pendingPaymentTimestampKey);
      if (kDebugMode) {
      }
    } catch (e) {
      if (kDebugMode) {
      }
    }
  }

  /// Check if there's a pending payment
  Future<bool> hasPendingPayment() async {
    final payment = await getPendingPayment();
    return payment != null;
  }
}

