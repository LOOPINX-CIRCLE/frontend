import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:text_code/core/services/auth_service.dart';
import 'package:text_code/core/network/api_client.dart';

class NotificationDeviceService {
  final AuthService _authService = AuthService();
  final ApiClient _apiClient = ApiClient();

  // Removed: static const String _baseUrl
  // Now using ApiClient which respects ApiConstants.baseUrl

  /// Register device for push notifications
  /// Associates OneSignal player ID with user profile
  /// One user can have multiple devices (iOS, Android)
  Future<Map<String, dynamic>> registerDevice({
    required String oneSignalPlayerId,
    required String platform, // 'ios' or 'android'
  }) async {
    try {
      final token = await _authService.getStoredToken();

      if (token == null || token.isEmpty) {
        throw Exception('Authentication required - No token found');
      }

      if (oneSignalPlayerId.isEmpty) {
        throw Exception('OneSignal player ID is required');
      }

      if (platform != 'ios' && platform != 'android') {
        throw Exception('Platform must be "ios" or "android"');
      }

      // âœ… Trim token and validate
      final cleanToken = token.trim();
      if (cleanToken.isEmpty || !cleanToken.contains('.')) {
        throw Exception('Invalid token format - Please login again');
      }

      final requestBody = {
        'onesignal_player_id': oneSignalPlayerId,
        'platform': platform,
      };

      if (kDebugMode) {
      }

      // âœ… USE APICLIENT (Same one that works for authentication)
      final response = await _apiClient.post(
        '/api/notifications/devices/register',
        body: requestBody,
        headers: {
          'Authorization': 'Bearer $cleanToken',
        },
      );

      if (kDebugMode) {
      }
      return response;
    } catch (e) {
      if (kDebugMode) {
      }
      rethrow;
    }
  }

  /// Deactivate device for push notifications
  /// Marks device as inactive (soft delete)
  /// Device records are preserved for audit purposes
  Future<Map<String, dynamic>> deactivateDevice({
    required String oneSignalPlayerId,
  }) async {
    try {
      final token = await _authService.getStoredToken();

      if (token == null || token.isEmpty) {
        throw Exception('Authentication required - No token found');
      }

      if (oneSignalPlayerId.isEmpty) {
        throw Exception('OneSignal player ID is required');
      }

      // âœ… Trim token and validate
      final cleanToken = token.trim();
      if (cleanToken.isEmpty || !cleanToken.contains('.')) {
        throw Exception('Invalid token format - Please login again');
      }

      if (kDebugMode) {
      }

      // âœ… Use raw http.delete with properly trimmed token
      final Uri url = Uri.parse('https://loopinbackend-g17e.onrender.com/api/notifications/devices/$oneSignalPlayerId');
      
      final response = await http.delete(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $cleanToken',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (kDebugMode) {
        }
        return data;
      } else if (response.statusCode == 401) {
        if (kDebugMode) {
        }
        throw Exception('Not authenticated');
      } else if (response.statusCode == 404) {
        if (kDebugMode) {
        }
        throw Exception('Device not found or does not belong to this user');
      } else {
        if (kDebugMode) {
        }
        throw Exception(
          'Device deactivation failed: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
      }
      rethrow;
    }
  }
}
