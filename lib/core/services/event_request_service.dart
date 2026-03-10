import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:text_code/core/constants/api_constants.dart';
import 'package:text_code/core/models/event_request.dart';
import 'package:text_code/core/models/requester_profile.dart';
import 'package:text_code/core/network/api_client.dart';
import 'package:text_code/core/network/api_exception.dart';
import 'package:text_code/core/services/secure_storage_service.dart';

class EventRequestService {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

  EventRequestService({ApiClient? apiClient, SecureStorageService? secureStorage})
      : _apiClient = apiClient ?? ApiClient(),
        _secureStorage = secureStorage ?? SecureStorageService();

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
        print('📤 Sending event request for event $eventId');
        print('   Message: $message');
        print('   Seats requested: $seatsRequested');
      }

      final response = await _apiClient.post(
        '/events/$eventId/requests',
        body: {
          'message': message,
          'seats_requested': seatsRequested,
        },
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('✅ Event request sent successfully');
      }

      return response;
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Error sending event request: $e');
      }
      throw ApiException(
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  /// Get user's request status for a specific event
  /// Returns the request details if user has made a request
  /// Returns null if user hasn't made a request (404)
  Future<EventRequest?> getUserRequestStatus(int eventId) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) {
        return null;
      }

      if (kDebugMode) {
        print('📋 Getting request status for event: $eventId');
      }

      try {
        final response = await _apiClient.get(
          '/events/$eventId/my-request',
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (kDebugMode) {
          print('✅ Get Request Status - response received');
        }

        return EventRequest.fromJson(response);
      } on ApiException catch (e) {
        if (e.statusCode == 404) {
          // No request found - this is normal
          if (kDebugMode) {
            print('No request found for event: $eventId');
          }
          return null;
        }
        rethrow;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting request status: $e');
      }
      return null; // Return null on error instead of throwing
    }
  }

  /// Check if user has already sent a request for an event
  Future<bool> hasUserRequestedEvent(int eventId) async {
    try {
      final request = await getUserRequestStatus(eventId);
      return request != null;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking user request status: $e');
      }
      return false;
    }
  }

  /// Get detailed profile of a requester (host only)
  Future<RequesterProfile> getRequesterProfile({
    required int eventId,
    required int requestId,
  }) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) {
        throw ApiException(
          message: 'Authentication token not found',
          statusCode: 401,
        );
      }

      if (kDebugMode) {
        print('👤 Fetching requester profile for event: $eventId, request: $requestId');
      }

      final response = await _apiClient.get(
        '/events/$eventId/requests/$requestId/profile',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('✅ Profile response received');
      }

      return RequesterProfile.fromJson(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching requester profile: $e');
      }
      throw ApiException(
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  /// Accept a single event request (host only)
  Future<Map<String, dynamic>> acceptEventRequest({
    required int eventId,
    required int requestId,
    String? hostMessage,
  }) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) {
        throw ApiException(
          message: 'Authentication token not found',
          statusCode: 401,
        );
      }

      if (kDebugMode) {
        print('✅ Accepting request for event $eventId');
        print('   Request ID: $requestId');
        print('   Host Message: $hostMessage');
      }

      final response = await _apiClient.put(
        '/events/$eventId/requests/$requestId/accept',
        body: {
          'host_message': hostMessage ?? '',
        },
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('✅ Request accepted successfully');
      }

      return response;
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Error accepting request: $e');
      }
      throw ApiException(
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }


  /// Get all requests for an event with their status and details
  /// Returns a map of request ID to status
  Future<Map<int, String>> getEventRequestsWithStatus(int eventId) async {
    if (kDebugMode) {
      print('\n[EventRequestService] getEventRequestsWithStatus called for event: $eventId');
    }
    try {
      final token = await _secureStorage.getToken();
      if (token == null) {
        throw ApiException(
          message: 'Authentication token not found',
          statusCode: 401,
        );
      }

      if (kDebugMode) {
        print('\n========== GET REQUESTS WITH STATUS ==========');
        print('Event ID: $eventId');
      }

      final response = await _apiClient.get(
        '/events/$eventId/requests',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('Response received\n');
      }

      Map<int, String> requestsWithStatus = {};

      // Handle new API response format: { "total_requests_count": N, "requests": [...] }
      if (response.containsKey('requests')) {
        final requests = response['requests'] as List? ?? [];
        
        for (var item in requests) {
          if (item is Map) {
            final id = item['id'] as int?;
            final status = item['status'] as String? ?? 'pending';
            
            if (id != null) {
              requestsWithStatus[id] = status;
              if (kDebugMode) {
                print('[Request] ID: $id, Status: $status, Name: ${item['full_name']}');
              }
            }
          }
        }
      }
      
      if (kDebugMode) {
        print('Total requests with status: ${requestsWithStatus.length}');
        print('==========================================\n');
      }

      return requestsWithStatus;
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching requests with status: $e');
      }
      throw ApiException(
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  /// Get all pending requests for an event (host only)
  /// Returns a list of request IDs that are pending
  Future<List<int>> getEventPendingRequests(int eventId) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) {
        throw ApiException(
          message: 'Authentication token not found',
          statusCode: 401,
        );
      }

      if (kDebugMode) {
        print('📋 Getting pending requests for event: $eventId');
      }

      try {
        final response = await _apiClient.get(
          '/events/$eventId/requests',
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        // Handle response as object with 'requests' key
        List<int> requestIds = [];
        
        if (response.containsKey('requests')) {
          // If response is an object with 'requests' key
          final requests = response['requests'];
          if (requests is List) {
            for (var item in requests) {
              if (item is int) {
                requestIds.add(item);
              } else if (item is Map && item.containsKey('id')) {
                final id = item['id'];
                if (id is int) {
                  requestIds.add(id);
                }
              }
            }
          }
        }
        
        return requestIds;
      } on ApiException catch (e) {
        if (e.statusCode == 404) {
          // No requests found
          return [];
        }
        rethrow;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting pending requests: $e');
      }
      throw ApiException(
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  /// Get the canonical share URL for an event
  /// Returns the canonical_url field from the API
  /// Constructs a full shareable URL from a path
  String _buildFullShareUrl(String urlOrPath) {
    if (urlOrPath.startsWith('http://') || urlOrPath.startsWith('https://')) {
      // Already a full URL
      return urlOrPath;
    }
    
    // It's a path, ensure it starts with /
    String path = urlOrPath;
    if (!path.startsWith('/')) {
      path = '/$path';
    }
    
    // Prepend the full domain
    return 'https://loopinsocial.in$path';
  }

  Future<String> getEventShareUrl(int eventId) async {
    try {
      // Get auth token (optional for public events, but include if available)
      final token = await _secureStorage.getToken();
      
      if (kDebugMode) {
        print('🔗 Fetching share URL for event: $eventId');
      }

      final response = await _apiClient.get(
        '/events/$eventId/share-url',
        headers: {
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('✅ Share URL response received');
        print('   Response: $response');
      }

      // Extract the canonical_url from response
      var canonicalUrl = response['canonical_url'] as String?;
      
      // Fallback to canonical_path if canonical_url is not available
      if (canonicalUrl == null || canonicalUrl.isEmpty) {
        final canonicalPath = response['canonical_path'] as String?;
        if (canonicalPath != null && canonicalPath.isNotEmpty) {
          canonicalUrl = canonicalPath;
          if (kDebugMode) {
            print('   Using canonical_path (fallback): $canonicalUrl');
          }
        }
      }
      
      if (canonicalUrl == null || canonicalUrl.isEmpty) {
        throw ApiException(
          message: 'Invalid share URL response: missing canonical_url',
          statusCode: 500,
        );
      }

      // Ensure we have the full URL with domain
      final fullUrl = _buildFullShareUrl(canonicalUrl);

      if (kDebugMode) {
        print('✅ Share URL retrieved: $fullUrl');
        print('   Raw from API: $canonicalUrl');
        print('   Full URL: $fullUrl');
      }

      return fullUrl;
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting share URL: $e');
      }
      throw ApiException(
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  /// Get all requests for an event with full details
  /// Returns list of request objects with user information
  Future<List<Map<String, dynamic>>> getAllEventRequests(int eventId) async {
    if (kDebugMode) {
      print('\n[EventRequestService] getAllEventRequests called for event: $eventId');
    }
    try {
      final token = await _secureStorage.getToken();
      if (token == null) {
        throw ApiException(
          message: 'Authentication token not found',
          statusCode: 401,
        );
      }

      if (kDebugMode) {
        print('Fetching all requests for event: $eventId');
      }

      final response = await _apiClient.get(
        '/events/$eventId/requests',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      List<Map<String, dynamic>> allRequests = [];

      // Handle new API response format: { "total_requests_count": N, "requests": [...] }
      if (response.containsKey('requests')) {
        final requests = response['requests'] as List? ?? [];
        
        for (var item in requests) {
          if (item is Map) {
            allRequests.add(Map<String, dynamic>.from(item));
            if (kDebugMode) {
              print('[Request] ID: ${item['id']}, Name: ${item['full_name']}, Status: ${item['status']}');
            }
          }
        }
      }
      
      if (kDebugMode) {
        print('Total requests fetched: ${allRequests.length}');
        print('==========================================\n');
      }

      return allRequests;
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting all requests: $e');
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