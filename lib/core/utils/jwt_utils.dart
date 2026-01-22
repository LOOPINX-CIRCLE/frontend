import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Utility class for JWT token operations
class JwtUtils {
  /// Decode JWT token and extract payload
  static Map<String, dynamic>? decodeToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        if (kDebugMode) {
          print('Invalid JWT token format');
        }
        return null;
      }

      // Decode the payload (second part)
      final payload = parts[1];
      // Add padding if needed
      String normalizedPayload = payload;
      switch (payload.length % 4) {
        case 1:
          normalizedPayload += '===';
          break;
        case 2:
          normalizedPayload += '==';
          break;
        case 3:
          normalizedPayload += '=';
          break;
      }

      final decoded = utf8.decode(base64Url.decode(normalizedPayload));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('Error decoding JWT token: $e');
      }
      return null;
    }
  }

  /// Extract user ID from JWT token
  static int? getUserId(String token) {
    final payload = decodeToken(token);
    if (payload == null) return null;

    final userId = payload['user_id'];
    if (userId is int) {
      return userId;
    } else if (userId is String) {
      return int.tryParse(userId);
    }
    return null;
  }

  /// Extract phone number from JWT token
  static String? getPhoneNumber(String token) {
    final payload = decodeToken(token);
    if (payload == null) return null;
    return payload['phone_number'] as String?;
  }

  /// Check if token is expired
  static bool isTokenExpired(String token) {
    final payload = decodeToken(token);
    if (payload == null) return true;

    final exp = payload['exp'];
    if (exp == null) return false; // No expiration claim

    if (exp is int) {
      final expirationTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expirationTime);
    }
    return false;
  }
}




