import 'package:flutter/foundation.dart';
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


      final response = await _apiClient.post(
        '/api/events/$eventId/requests',
        body: {
          'message': message,
          'seats_requested': seatsRequested,
        },
        headers: {
          'Authorization': 'Bearer $token',
        },
      );


      return response;
    } on ApiException {
      rethrow;
    } catch (e) {
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


      try {
        final response = await _apiClient.get(
          '/api/events/$eventId/my-request',
          headers: {
            'Authorization': 'Bearer $token',
          },
        );


        return EventRequest.fromJson(response);
      } on ApiException catch (e) {
        if (e.statusCode == 404) {
          // No request found - this is normal
          return null;
        }
        rethrow;
      }
    } catch (e) {
      return null; // Return null on error instead of throwing
    }
  }

  /// Check if user has already sent a request for an event
  Future<bool> hasUserRequestedEvent(int eventId) async {
    try {
      final request = await getUserRequestStatus(eventId);
      return request != null;
    } catch (e) {
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


      final response = await _apiClient.get(
        '/api/events/$eventId/requests/$requestId/profile',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );


      return RequesterProfile.fromJson(response);
    } on ApiException {
      rethrow;
    } catch (e) {
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


      final response = await _apiClient.put(
        '/api/events/$eventId/requests/$requestId/accept',
        body: {
          'host_message': hostMessage ?? '',
        },
        headers: {
          'Authorization': 'Bearer $token',
        },
      );


      return response;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }


  /// Get all requests for an event with their status and details
  /// Returns a map of request ID to status
  Future<Map<int, String>> getEventRequestsWithStatus(int eventId) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) {
        throw ApiException(
          message: 'Authentication token not found',
          statusCode: 401,
        );
      }


      final response = await _apiClient.get(
        '/api/events/$eventId/requests',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );


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
            }
          }
        }
      }
      

      return requestsWithStatus;
    } on ApiException {
      rethrow;
    } catch (e) {
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


      try {
        final response = await _apiClient.get(
          '/api/events/$eventId/requests',
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
      // Already a full URL - replace domain if needed
      if (urlOrPath.contains('loopinsocial.in')) {
        return urlOrPath.replaceAll('https://loopinsocial.in', 'https://invite.loopinsocial.in')
                        .replaceAll('http://loopinsocial.in', 'https://invite.loopinsocial.in');
      }
      return urlOrPath;
    }
    
    // It's a path, ensure it starts with /
    String path = urlOrPath;
    if (!path.startsWith('/')) {
      path = '/$path';
    }
    
    // Prepend the invite domain
    return 'https://invite.loopinsocial.in$path';
  }

  Future<String> getEventShareUrl(int eventId) async {
    try {
      // Get auth token (optional for public events, but include if available)
      final token = await _secureStorage.getToken();
      

      final response = await _apiClient.get(
        '/api/events/$eventId/share-url',
        headers: {
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );


      // Extract the canonical_url from response
      var canonicalUrl = response['canonical_url'] as String?;
      
      // Fallback to canonical_path if canonical_url is not available
      if (canonicalUrl == null || canonicalUrl.isEmpty) {
        final canonicalPath = response['canonical_path'] as String?;
        if (canonicalPath != null && canonicalPath.isNotEmpty) {
          canonicalUrl = canonicalPath;
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


      return fullUrl;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  /// Get all requests for an event with full details
  /// Returns list of request objects with user information
  Future<List<Map<String, dynamic>>> getAllEventRequests(int eventId) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) {
        throw ApiException(
          message: 'Authentication token not found',
          statusCode: 401,
        );
      }


      final response = await _apiClient.get(
        '/api/events/$eventId/requests',
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
          }
        }
      }
      

      return allRequests;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  /// Confirm attendance for a FREE event after request acceptance
  /// This generates a ticket immediately for FREE events
  /// CRITICAL: Only works for FREE events. Paid events must complete payment first.
  /// Called by: User confirms attendance after their request is accepted
  Future<Map<String, dynamic>> confirmAttendance({
    required int eventId,
    required int seats,
  }) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) {
        throw ApiException(
          message: 'Authentication token not found',
          statusCode: 401,
        );
      }


      final response = await _apiClient.post(
        '/api/events/$eventId/confirm-attendance',
        body: {
          'seats': seats,
        },
        headers: {
          'Authorization': 'Bearer $token',
        },
      );


      return response;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  /// Get ticket data for a specific event
  /// Used after payment confirmation to fetch ticket details
  /// Returns ticket data including ticket_id, ticket_secret, event details
  Future<Map<String, dynamic>> getTicket(int eventId) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) {
        throw ApiException(
          message: 'Authentication token not found',
          statusCode: 401,
        );
      }


      final response = await _apiClient.get(
        '/api/events/$eventId/my-ticket',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );


      return response;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  /// Get all user's requests across all events (no event ID needed)
  /// Returns all requests made by the current user
  /// Used for home page to build request status map
  /// Get request statuses for multiple events by fetching individual status for each
  /// This is a fallback approach when /api/events/my-requests is not available
  Future<List<Map<String, dynamic>>> getAllUserRequestsIndividual(List<int> eventIds) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) {
        throw ApiException(
          message: 'Authentication token not found',
          statusCode: 401,
        );
      }


      List<Map<String, dynamic>> allRequests = [];

      // Fetch request status for each event
      for (final eventId in eventIds) {
        try {
          final request = await getUserRequestStatus(eventId);
          if (request != null) {
            // Convert EventRequest to Map
            allRequests.add({
              'event_id': eventId,
              'status': request.status,
              'can_confirm': request.canConfirm,
              'request_id': request.requestId,
            });
          }
        } catch (e) {
          // Skip if error fetching this event's request
        }
      }


      return allRequests;
    } catch (e) {
      throw ApiException(
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  Future<List<Map<String, dynamic>>> getAllUserRequests() async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) {
        throw ApiException(
          message: 'Authentication token not found',
          statusCode: 401,
        );
      }


      final response = await _apiClient.get(
        '/api/events/my-requests',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      List<Map<String, dynamic>> allRequests = [];

      // Handle response - API returns object with 'requests' key containing list
      if (response.containsKey('requests')) {
        final requests = response['requests'] as List? ?? [];
        for (var item in requests) {
          if (item is Map) {
            allRequests.add(Map<String, dynamic>.from(item));
          }
        }
      }

      return allRequests;
    } on ApiException {
      rethrow;
    } catch (e) {
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
