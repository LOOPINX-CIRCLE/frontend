import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:text_code/core/constants/api_constants.dart';
import 'package:text_code/core/network/api_exception.dart';
import 'package:text_code/core/services/secure_storage_service.dart';

/// Service for fetching user tickets
class TicketService {
  final SecureStorageService _secureStorage = SecureStorageService();

  /// Fetch all tickets for the current user
  /// API: GET /api/events/my-tickets
  /// Returns: List of ticket objects
  Future<List<Map<String, dynamic>>> getAllUserTickets() async {
    try {
      // Get auth token
      final token = await _secureStorage.getToken();
      if (token == null) {
        throw ApiException(
          message: 'Authentication token not found',
          statusCode: 401,
        );
      }

      // Prepare request
      final url = Uri.parse('${ApiConstants.baseUrl}/api/events/my-tickets');
      final headers = {
        'Authorization': 'Bearer $token',
        'accept': 'application/json',
      };

      if (kDebugMode) {
      }

      // Send the request
      final response = await http.get(url, headers: headers).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw ApiException(
            message: 'Request timed out. Please check your connection and try again.',
            statusCode: 408,
          );
        },
      );

      if (kDebugMode) {
      }

      // Handle response
      if (response.statusCode == 200) {
        // Success - parse list of tickets
        final List<dynamic> ticketsList = jsonDecode(response.body);
        final List<Map<String, dynamic>> tickets = ticketsList
            .map((ticket) => ticket as Map<String, dynamic>)
            .toList();

        if (kDebugMode) {
        }

        return tickets;
      } else if (response.statusCode == 401) {
        throw ApiException(
          message: 'Authentication failed. Please log in again.',
          statusCode: 401,
        );
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
      } else if (response.statusCode >= 500) {
        throw ApiException(
          message: 'Server error. Please try again later.',
          statusCode: response.statusCode,
        );
      } else {
        throw ApiException(
          message: 'Failed to fetch tickets: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      if (kDebugMode) {
      }
      throw ApiException(
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }
}

