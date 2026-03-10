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
      final url = Uri.parse('${ApiConstants.baseUrl}/api/events/$eventId/requests');
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

      // Send the request with increased timeout
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      ).timeout(
        const Duration(seconds: 60), // Increased to 60 seconds
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

  /// Get user's request status for an event
  /// Returns the full request data if found, null if no request exists (404)
  Future<Map<String, dynamic>?> getUserRequestStatus(int eventId) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) {
        return null;
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/api/events/$eventId/my-request');
      final headers = {
        'Authorization': 'Bearer $token',
        'accept': 'application/json',
      };

      if (kDebugMode) {
        print('Fetching request status for event $eventId: $url');
      }

      final response = await http.get(url, headers: headers).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw ApiException(
          message: 'Connection timeout',
          statusCode: 408,
        ),
      );

      if (response.statusCode == 200) {
        // User has a request, return the full data
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (kDebugMode) {
          print('Request status for event $eventId: ${data['status']}');
        }
        return data;
      } else if (response.statusCode == 404) {
        // No request found - this is normal
        if (kDebugMode) {
          print('No request found for event $eventId (404)');
        }
        return null;
      } else {
        // Other errors
        if (kDebugMode) {
          print('Error fetching request status: ${response.statusCode}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking user request status: $e');
      }
      // Return null on error (treat as no request)
      return null;
    }
  }

  /// Check if user has already sent a request for an event
  Future<bool> hasUserRequestedEvent(int eventId) async {
    final status = await getUserRequestStatus(eventId);
    return status != null;
  }

  /// Get all user requests across all events
  /// API: GET /api/events/my-requests
  /// Returns: List of request objects with event_id, status, can_confirm, etc.
  Future<List<Map<String, dynamic>>> getAllUserRequests() async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) {
        return [];
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/api/events/my-requests');
      final headers = {
        'Authorization': 'Bearer $token',
        'accept': 'application/json',
      };

      if (kDebugMode) {
        print('Fetching all user requests: $url');
      }

      final response = await http.get(url, headers: headers).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw ApiException(
          message: 'Connection timeout',
          statusCode: 408,
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> requestsList = jsonDecode(response.body);
        final List<Map<String, dynamic>> requests = requestsList
            .map((request) => request as Map<String, dynamic>)
            .toList();

        if (kDebugMode) {
          print('Fetched ${requests.length} requests from API');
        }

        return requests;
      } else if (response.statusCode == 404) {
        // No requests found - return empty list
        if (kDebugMode) {
          print('No requests found (404)');
        }
        return [];
      } else {
        if (kDebugMode) {
          print('Error fetching all requests: ${response.statusCode}');
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching all user requests: $e');
      }
      // Return empty list on error
      return [];
    }
  }

  /// Confirm attendance for a FREE event after request acceptance
  /// 
  /// CRITICAL: This endpoint is ONLY for FREE events
  /// - FREE events: Confirms attendance and generates ticket immediately
  /// - PAID events: This endpoint will REJECT paid events
  ///   For paid events, seats are ONLY confirmed after payment success
  /// 
  /// Flow for FREE events:
  /// 1. User's request must be accepted
  /// 2. User confirms attendance with number of seats
  /// 3. System creates EventAttendee immediately (seat confirmed)
  /// 4. System generates ticket with unique secret code
  /// 5. User can view ticket anytime
  /// 
  /// Returns: Generated ticket with secret code (free events only)
  Future<Map<String, dynamic>> confirmAttendance({
    required int eventId,
    required int seats,
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

      // Prepare request
      final url = Uri.parse('${ApiConstants.baseUrl}/api/events/$eventId/confirm-attendance');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'accept': 'application/json',
      };

      final body = jsonEncode({
        'seats': seats,
      });

      if (kDebugMode) {
        print('Confirming attendance for event $eventId');
        print('URL: $url');
        print('Seats: $seats');
      }

      // Send the request
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw ApiException(
            message: 'Request timed out. Please check your connection and try again.',
            statusCode: 408,
          );
        },
      );

      if (kDebugMode) {
        print('Confirm attendance response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      // Handle response
      if (response.statusCode == 200) {
        // Success - ticket generated
        final ticketData = jsonDecode(response.body) as Map<String, dynamic>;
        if (kDebugMode) {
          print('Attendance confirmed successfully');
          print('Ticket ID: ${ticketData['ticket_id']}');
          print('Ticket Secret: ${ticketData['ticket_secret']}');
        }
        return ticketData;
      } else if (response.statusCode == 400) {
        // Bad request - might be paid event or other validation error
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['detail'] ?? errorData['error'] ?? 'Invalid request';
          throw ApiException(
            message: errorMessage.toString(),
            statusCode: 400,
          );
        } catch (_) {
          throw ApiException(
            message: 'This endpoint is only for FREE events. Paid events require payment first.',
            statusCode: 400,
          );
        }
      } else if (response.statusCode == 403) {
        // Forbidden - request not accepted or other permission issue
        try {
          final errorData = jsonDecode(response.body);
          final detail = errorData['detail'];
          throw ApiException(
            message: detail?.toString() ?? 'Your request must be accepted before confirming attendance.',
            statusCode: 403,
          );
        } catch (_) {
          throw ApiException(
            message: 'Your request must be accepted before confirming attendance.',
            statusCode: 403,
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
          message: 'Failed to confirm attendance: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      if (kDebugMode) {
        print('Error confirming attendance: $e');
      }
      throw ApiException(
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  /// Get ticket for a specific event
  /// Returns ticket data including ticket_secret, event details, etc.
  Future<Map<String, dynamic>> getTicket(int eventId) async {
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
      final url = Uri.parse('${ApiConstants.baseUrl}/api/events/$eventId/my-ticket');
      final headers = {
        'Authorization': 'Bearer $token',
        'accept': 'application/json',
      };

      if (kDebugMode) {
        print('Fetching ticket for event $eventId: $url');
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
        print('Get ticket response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      // Handle response
      if (response.statusCode == 200) {
        // Success - ticket found
        final ticketData = jsonDecode(response.body) as Map<String, dynamic>;
        if (kDebugMode) {
          print('Ticket fetched successfully');
          print('Ticket ID: ${ticketData['ticket_id']}');
          print('Ticket Secret: ${ticketData['ticket_secret']}');
        }
        return ticketData;
      } else if (response.statusCode == 403) {
        // Forbidden - payment required for paid event or other permission issue
        try {
          final errorData = jsonDecode(response.body);
          final detail = errorData['detail'];
          throw ApiException(
            message: detail?.toString() ?? 'Payment required for this event.',
            statusCode: 403,
          );
        } catch (_) {
          throw ApiException(
            message: 'Payment required for this event.',
            statusCode: 403,
          );
        }
      } else if (response.statusCode == 404) {
        // No ticket found
        throw ApiException(
          message: 'No ticket found for this event.',
          statusCode: 404,
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
          message: 'Failed to get ticket: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      if (kDebugMode) {
        print('Error getting ticket: $e');
      }
      throw ApiException(
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  void dispose() {
    // Clean up any resources if needed
  }
}