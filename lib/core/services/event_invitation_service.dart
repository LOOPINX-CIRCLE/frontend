import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:text_code/core/constants/api_constants.dart';
import 'package:text_code/core/models/event_invitation.dart';
import 'package:text_code/core/network/api_exception.dart';
import 'package:text_code/core/services/secure_storage_service.dart';

/// Service responsible for fetching event invitations for the current user.
class EventInvitationService {
  final SecureStorageService _secureStorage = SecureStorageService();

  /// Fetch all invitations for the current user.
  ///
  /// GET /api/events/my-invitations
  Future<List<EventInvitation>> fetchInvitations() async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null || token.isEmpty) {
        throw ApiException(
          message: 'Authentication token not found',
          statusCode: 401,
        );
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/api/events/my-invitations');
      final headers = <String, String>{
        'Authorization': 'Bearer $token',
        'accept': 'application/json',
      };

      if (kDebugMode) {
        print('Fetching event invitations from: $url');
      }

      final response = await http.get(url, headers: headers).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw ApiException(
          message: 'Request timed out. Please check your connection and try again.',
          statusCode: 408,
        ),
      );

      if (kDebugMode) {
        print('Invitations response status: ${response.statusCode}');
        print('Invitations response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((e) => EventInvitation.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (response.statusCode == 401) {
        throw ApiException(
          message: 'Authentication failed. Please log in again.',
          statusCode: 401,
        );
      }

      if (response.statusCode == 422) {
        final body = jsonDecode(response.body);
        final detail = body['detail'];
        throw ApiException(
          message: detail?.toString() ?? 'Validation error while fetching invitations',
          statusCode: 422,
        );
      }

      if (response.statusCode >= 500) {
        throw ApiException(
          message: 'Server error while fetching invitations. Please try again later.',
          statusCode: response.statusCode,
        );
      }

      throw ApiException(
        message: 'Failed to fetch invitations: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error fetching invitations: $e');
      }
      throw ApiException(
        message: 'Unexpected error fetching invitations: $e',
        statusCode: 500,
      );
    }
  }

  /// Respond to an event invitation (going or declined).
  ///
  /// PUT /api/events/invitations/{inviteId}/respond
  /// response: "going" or "declined"
  Future<Map<String, dynamic>> respondToInvitation({
    required int inviteId,
    required String response, // "going" or "declined"
    String? message,
  }) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null || token.isEmpty) {
        throw ApiException(
          message: 'Authentication token not found',
          statusCode: 401,
        );
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/api/events/invitations/$inviteId/respond');
      final headers = <String, String>{
        'Authorization': 'Bearer $token',
        'accept': 'application/json',
        'Content-Type': 'application/json',
      };

      final body = jsonEncode({
        'response': response,
        'message': message ?? '',
      });

      if (kDebugMode) {
        print('Responding to invitation: $url');
        print('Request body: $body');
      }

      final httpResponse = await http.put(
        url,
        headers: headers,
        body: body,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw ApiException(
          message: 'Request timed out. Please check your connection and try again.',
          statusCode: 408,
        ),
      );

      if (kDebugMode) {
        print('Respond invitation response status: ${httpResponse.statusCode}');
        print('Respond invitation response body: ${httpResponse.body}');
      }

      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 204) {
        if (httpResponse.body.isNotEmpty) {
          return jsonDecode(httpResponse.body) as Map<String, dynamic>;
        }
        return {'success': true};
      }

      if (httpResponse.statusCode == 401) {
        throw ApiException(
          message: 'Authentication failed. Please log in again.',
          statusCode: 401,
        );
      }

      if (httpResponse.statusCode == 404) {
        throw ApiException(
          message: 'Invitation not found',
          statusCode: 404,
        );
      }

      if (httpResponse.statusCode >= 500) {
        throw ApiException(
          message: 'Server error while responding to invitation. Please try again later.',
          statusCode: httpResponse.statusCode,
        );
      }

      final responseBody = httpResponse.body.isNotEmpty ? jsonDecode(httpResponse.body) : {};
      final errorMessage = responseBody['detail']?.toString() ?? 
                     responseBody['message']?.toString() ?? 
                     'Failed to respond to invitation: ${httpResponse.statusCode}';
      
      throw ApiException(
        message: errorMessage,
        statusCode: httpResponse.statusCode,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error responding to invitation: $e');
      }
      throw ApiException(
        message: 'Unexpected error responding to invitation: $e',
        statusCode: 500,
      );
    }
  }
}


