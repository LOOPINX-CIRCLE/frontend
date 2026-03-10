import 'package:flutter/foundation.dart';
import 'package:text_code/core/models/event.dart';
import 'package:text_code/core/network/api_client.dart';
import 'package:text_code/core/network/api_exception.dart';
import 'package:text_code/core/services/secure_storage_service.dart';

class EventService {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

  EventService({
    ApiClient? apiClient,
    SecureStorageService? secureStorage,
  })  : _apiClient = apiClient ?? ApiClient(),
        _secureStorage = secureStorage ?? SecureStorageService();

  /// Fetch a single event by ID
  /// Requires authentication token in Authorization header
  /// Returns an Event object
  Future<Event> fetchEventById(int eventId) async {
    try {
      // Retrieve token from secure storage
      final token = await _secureStorage.getToken();

      if (token == null || token.isEmpty) {
        throw ApiException(
          message: 'Authentication required. Please verify OTP first.',
          statusCode: 401,
          error: 'No token found',
        );
      }

      if (kDebugMode) {
        print('Fetching event $eventId with token...');
      }

      final response = await _apiClient.get(
        '/events/$eventId',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('Event response: $response');
      }

      // Handle validation errors
      if (response.containsKey('detail')) {
        final detail = response['detail'];
        String errorMessage = 'Failed to fetch event';
        
        if (detail is List) {
          final errorMessages = detail.map((error) {
            if (error is Map && error['msg'] != null) {
              return error['msg'].toString();
            }
            return '';
          }).where((msg) => msg.isNotEmpty).toList();
          
          if (errorMessages.isNotEmpty) {
            errorMessage = errorMessages.join('; ');
          }
        } else if (detail is String) {
          errorMessage = detail;
        }
        
        throw ApiException(
          message: errorMessage,
          statusCode: 400,
          error: response,
        );
      }

      // Parse response - API might return event directly or wrapped in data
      Map<String, dynamic> eventData;
      if (response['data'] != null) {
        eventData = response['data'] as Map<String, dynamic>;
      } else {
        eventData = response;
      }

      return Event.fromJson(eventData);
    } on ApiException catch (e) {
      rethrow;
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching event: $error');
      }
      throw ApiException(
        message: 'An error occurred while fetching event: ${error.toString()}',
        error: error,
      );
    }
  }

  /// Fetch list of events
  /// Requires authentication token in Authorization header
  /// Returns a list of Event objects
  Future<List<Event>> fetchEvents() async {
    try {
      // Retrieve token from secure storage
      final token = await _secureStorage.getToken();

      if (token == null || token.isEmpty) {
        throw ApiException(
          message: 'Authentication required. Please verify OTP first.',
          statusCode: 401,
          error: 'No token found',
        );
      }

      if (kDebugMode) {
        print('Fetching events list with token...');
      }

      // Try to fetch from /events endpoint (list endpoint)
      final response = await _apiClient.get(
        '/events',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('Events list response: $response');
      }

      // Handle validation errors
      if (response.containsKey('detail')) {
        final detail = response['detail'];
        String errorMessage = 'Failed to fetch events';
        
        if (detail is List) {
          final errorMessages = detail.map((error) {
            if (error is Map && error['msg'] != null) {
              return error['msg'].toString();
            }
            return '';
          }).where((msg) => msg.isNotEmpty).toList();
          
          if (errorMessages.isNotEmpty) {
            errorMessage = errorMessages.join('; ');
          }
        } else if (detail is String) {
          errorMessage = detail;
        }
        
        throw ApiException(
          message: errorMessage,
          statusCode: 400,
          error: response,
        );
      }

      // Parse response - API might return events directly or wrapped in data
      List<dynamic> eventsList;
      if (response['data'] != null) {
        final data = response['data'];
        if (data is List) {
          eventsList = data;
        } else {
          eventsList = [];
        }
      } else {
        eventsList = [];
      }

      return eventsList
          .map((json) => Event.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching events: $error');
      }
      throw ApiException(
        message: 'An error occurred while fetching events: ${error.toString()}',
        error: error,
      );
    }
  }

  /// Update RSVP deadline for an event
  /// Maps friendly names to API values:
  /// "48 Hours" -> "48h"
  /// "7 Days" -> "7d"
  /// "Before Event Day" -> "day_before_event"
  /// "At Event Start" -> "event_start"
  Future<Map<String, dynamic>> updateRsvpDeadline({
    required int eventId,
    required String rsvpOption,
  }) async {
    try {
      final token = await _secureStorage.getToken();

      if (token == null || token.isEmpty) {
        throw ApiException(
          message: 'Authentication required.',
          statusCode: 401,
          error: 'No token found',
        );
      }

      // Map friendly names to API values
      final Map<String, String> rsvpMapping = {
        '48 Hours': '48h',
        '7 Days': '7d',
        'Before Event Day': 'day_before_event',
        'At Event Start': 'event_start',
      };

      final expiryPolicy = rsvpMapping[rsvpOption] ?? '48h';

      if (kDebugMode) {
        print('\n========== RSVP UPDATE DEBUG ==========');
        print('📝 Updating RSVP deadline for event $eventId');
        print('   User Selected: "$rsvpOption"');
        print('   Mapping Keys: ${rsvpMapping.keys.toList()}');
        print('   Mapping Match: ${rsvpMapping.containsKey(rsvpOption)}');
        print('   API Value: "$expiryPolicy"');
        print('   Token: ${token.substring(0, 20)}...');
      }

      final requestBody = {
        'rsvp_expiry_policy': expiryPolicy,
      };

      if (kDebugMode) {
        print('   Request Body: $requestBody');
        print('   Endpoint: /events/$eventId');
      }

      final response = await _apiClient.put(
        '/events/$eventId',
        body: requestBody,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (kDebugMode) {
        print('✅ RSVP update response status: ${response.toString().split('\n')[0]}');
        print('📥 Full response: $response');
        print('========== END DEBUG ==========\n');
      }

      if (response.containsKey('success') && response['success'] == true) {
        return {
          'success': true,
          'message': 'RSVP deadline updated successfully',
          'data': response,
        };
      } else if (response.containsKey('detail')) {
        throw ApiException(
          message: response['detail'] is String 
              ? response['detail'] 
              : 'Failed to update RSVP deadline',
          statusCode: 400,
          error: response,
        );
      } else {
        return {
          'success': true,
          'message': 'RSVP deadline updated successfully',
          'data': response,
        };
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print('❌ RSVP update error: ${e.message}');
      }
      rethrow;
    } catch (error) {
      if (kDebugMode) {
        print('💥 Error updating RSVP: $error');
      }
      throw ApiException(
        message: 'An error occurred while updating RSVP deadline: ${error.toString()}',
        error: error,
      );
    }
  }

  void dispose() {
    _apiClient.close();
  }
}

