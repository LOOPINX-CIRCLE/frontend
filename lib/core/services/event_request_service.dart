import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:text_code/core/constants/api_constants.dart';
import 'package:text_code/core/network/api_exception.dart';
import 'package:text_code/core/services/secure_storage_service.dart';

class EventRequestService {
  final SecureStorageService _secureStorage = SecureStorageService();

  /// Send request to join an event
  Future<Map<String, dynamic>> sendEventRequest({
    required int eventId,
    required String message,
    required int seatsRequested,
  }) async {
    try {
      // Get auth token
      final token = await _secureStorage.getToken();
      if (token == null) {
        throw ApiException(
          message: 'Authentication token not found',
          statusCode: 401,
        );
      }

      if (kDebugMode) {
        print('Token exists: ${token.isNotEmpty}');
        print('Token length: ${token.length}');
      }

      // Prepare request
      final url = Uri.parse('${ApiConstants.baseUrl}/events/$eventId/requests');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'accept': 'application/json',
      };

      final body = jsonEncode({
        'message': message,
        'seats_requested': seatsRequested,
      });

      if (kDebugMode) {
        print('Sending request to: $url');
        print('Headers: $headers');
        print('Authorization Token: ${headers['Authorization']}');
        print('Request Body: $body');
      }

      // Send the request
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      ).timeout(
        const Duration(seconds: 30), // 30 second timeout
        onTimeout: () {
          throw ApiException(
            message: 'Request timed out. Please check your connection and try again.',
            statusCode: 408,
          );
        },
      );

      if (kDebugMode) {
        print('========== RESPONSE ==========');
        print('Status Code: ${response.statusCode}');
        print('Response Headers: ${response.headers}');
        print('Response Body: ${response.body}');
        print('========== END RESPONSE ==========');
      }

      // Handle response
      if (response.statusCode == 201) {
        // Success
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 403) {
        // Forbidden - could be host, already requested, or account not activated
        if (kDebugMode) {
          print('403 Forbidden Response: ${response.body}');
        }
        
        // Try to get the actual error message from the server
        try {
          final errorData = jsonDecode(response.body);
          final detail = errorData['detail'];
          throw ApiException(
            message: detail?.toString() ?? 'You do not have permission to send a request for this event.',
            statusCode: 403,
          );
        } catch (_) {
          throw ApiException(
            message: 'You do not have permission to send a request for this event. You may be the host or have already sent a request.',
            statusCode: 403,
          );
        }
      } else if (response.statusCode == 400) {
        // Bad request - might contain server error message
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['detail'] ?? errorData['error'] ?? 'Invalid request';
          throw ApiException(
            message: errorMessage.toString(),
            statusCode: 400,
          );
        } catch (_) {
          throw ApiException(
            message: 'Invalid request: please check your input',
            statusCode: 400,
          );
        }
      } else if (response.statusCode == 422) {
        // Validation error
        final errorData = jsonDecode(response.body);
        final detail = errorData['detail'] as List?;
        if (detail != null && detail.isNotEmpty) {
          final firstError = detail[0] as Map<String, dynamic>;
          throw ApiException(
            message: firstError['msg'] as String? ?? 'Validation error',
            statusCode: 422,
          );
        }
        throw ApiException(
          message: 'Validation error occurred',
          statusCode: 422,
        );
      } else if (response.statusCode == 401) {
        throw ApiException(
          message: 'Authentication failed. Please log in again.',
          statusCode: 401,
        );
      } else if (response.statusCode >= 500) {
        throw ApiException(
          message: 'Server error. Please try again later.',
          statusCode: response.statusCode,
        );
      } else {
        throw ApiException(
          message: 'Failed to send request: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      if (kDebugMode) {
        print('Error sending event request: $e');
      }
      throw ApiException(
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  /// Check if user has already sent a request for an event
  Future<bool> hasUserRequestedEvent(int eventId) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) {
        return false;
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/events/$eventId/requests/my-request');
      final headers = {
        'Authorization': 'Bearer $token',
        'accept': 'application/json',
      };

      final response = await http.get(url, headers: headers).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw ApiException(
          message: 'Connection timeout',
          statusCode: 408,
        ),
      );

      if (response.statusCode == 200) {
        // User has a pending request
        return true;
      } else if (response.statusCode == 404) {
        // No request found
        return false;
      } else {
        // Other errors, assume no request
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking user request status: $e');
      }
      return false;
    }
  }

  void dispose() {
    // Clean up any resources if needed
  }
}