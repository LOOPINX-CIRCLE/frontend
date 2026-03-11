
import 'package:flutter/foundation.dart';
import 'package:text_code/core/network/api_client.dart';
import 'package:text_code/core/network/api_exception.dart';
import 'package:text_code/core/services/auth_service.dart';

class SearchUserResponse {
  final int total;
  final int offset;
  final int limit;
  final List<SearchUser> data;

  SearchUserResponse({
    required this.total,
    required this.offset,
    required this.limit,
    required this.data,
  });

  factory SearchUserResponse.fromJson(Map<String, dynamic> json) {
    return SearchUserResponse(
      total: json['total'] ?? 0,
      offset: json['offset'] ?? 0,
      limit: json['limit'] ?? 50,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => SearchUser.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}

class SearchUser {
  final int id;
  final String fullName;
  final String username;
  final String? profilePictureUrl;
  final bool alreadyInvited;
  bool isSelected;

  SearchUser({
    required this.id,
    required this.fullName,
    required this.username,
    this.profilePictureUrl,
    this.alreadyInvited = false,
    this.isSelected = false,
  });

  factory SearchUser.fromJson(Map<String, dynamic> json) {
    return SearchUser(
      id: json['id'] as int,
      fullName: json['full_name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      profilePictureUrl: json['profile_picture_url'] as String?,
      alreadyInvited: json['already_invited'] as bool? ?? false,
    );
  }
}

class InvitationResponse {
  final bool success;
  final int createdCount;
  final int skippedCount;
  final List<dynamic> errors;
  final List<InviteDetail> invites;

  InvitationResponse({
    required this.success,
    required this.createdCount,
    required this.skippedCount,
    required this.errors,
    required this.invites,
  });

  factory InvitationResponse.fromJson(Map<String, dynamic> json) {
    return InvitationResponse(
      success: json['success'] ?? false,
      createdCount: json['created_count'] ?? 0,
      skippedCount: json['skipped_count'] ?? 0,
      errors: json['errors'] ?? [],
      invites: (json['invites'] as List<dynamic>?)
          ?.map((e) => InviteDetail.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}

class InviteDetail {
  final int inviteId;
  final int userId;
  final String userName;
  final String status;
  final String message;
  final String expiresAt;
  final String expiryPolicy;

  InviteDetail({
    required this.inviteId,
    required this.userId,
    required this.userName,
    required this.status,
    required this.message,
    required this.expiresAt,
    required this.expiryPolicy,
  });

  factory InviteDetail.fromJson(Map<String, dynamic> json) {
    return InviteDetail(
      inviteId: json['invite_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? '',
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      expiresAt: json['expires_at'] ?? '',
      expiryPolicy: json['expiry_policy'] ?? '48h',
    );
  }
}

class InvitationService {
  final ApiClient _apiClient;

  InvitationService({ApiClient? apiClient}) 
    : _apiClient = apiClient ?? ApiClient();

  /// Search for users to invite
  /// Returns a list of users matching the search query
  /// Note: event_id is required by the backend even though it's a global search
  Future<SearchUserResponse> searchUsers({
    required int eventId,
    String? search,
    int offset = 0,
    int limit = 50,
  }) async {
    try {
      final authService = AuthService();
      final token = await authService.getStoredToken();
      
      if (token == null || token.isEmpty) {
        throw ApiException(
          message: 'Authentication required',
          statusCode: 401,
        );
      }

      // Build query parameters - event_id is REQUIRED by backend
      final queryParams = StringBuffer('event_id=$eventId&offset=$offset&limit=$limit');
      
      if (search != null && search.isNotEmpty) {
        queryParams.write('&search=${Uri.encodeComponent(search)}');
      }

      final endpoint = '/api/events/users/search?$queryParams';

      if (kDebugMode) {
      }

      final response = await _apiClient.get(
        endpoint,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
      }

      return SearchUserResponse.fromJson(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
      }
      throw ApiException(
        message: 'Failed to search users: ${e.toString()}',
        error: e,
      );
    }
  }


  /// Send invitations to multiple users
  /// Returns the invitation response with created count and details
  Future<InvitationResponse> sendInvitations({
    required int eventId,
    required List<int> userIds,
    String? message,
    String expiryPolicy = '48h',
  }) async {
    try {
      final authService = AuthService();
      final token = await authService.getStoredToken();
      
      if (token == null || token.isEmpty) {
        throw ApiException(
          message: 'Authentication required',
          statusCode: 401,
        );
      }

      final requestBody = {
        'user_ids': userIds,
        'expiry_policy': expiryPolicy,
        if (message != null && message.isNotEmpty) 'message': message,
      };

      if (kDebugMode) {
      }

      final response = await _apiClient.post(
        '/api/events/$eventId/invitations',
        body: requestBody,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final result = InvitationResponse.fromJson(response);
      
      if (kDebugMode) {
        if (result.errors.isNotEmpty) {
        }
      }
      
      return result;
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
      }
      throw ApiException(
        message: 'Failed to send invitations: ${e.toString()}',
        error: e,
      );
    }
  }

  /// Get confirmed attendees (going) for an event
  /// Returns a list of confirmed attendees with user details
  Future<List<EventAttendee>> getEventAttendees(int eventId) async {
    try {
      final authService = AuthService();
      final token = await authService.getStoredToken();
      
      if (token == null || token.isEmpty) {
        throw ApiException(
          message: 'Authentication required',
          statusCode: 401,
        );
      }

      if (kDebugMode) {
      }

      final response = await _apiClient.get(
        '/api/events/$eventId/attendees',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
      }
      // Handle API response format: { "going_count": N, "attendees": [...] }
      List<dynamic> attendeesList = [];
      
      if (response.containsKey('attendees')) {
        attendeesList = response['attendees'] as List<dynamic>? ?? [];
      }

      if (kDebugMode) {
      }

      return attendeesList
          .map((e) => EventAttendee.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
      }
      throw ApiException(
        message: 'Failed to get attendees: ${e.toString()}',
        error: e,
      );
    }
  }

  /// Check in a user to an event (host only)
  /// Can only be used 3 hours before event start
  Future<bool> checkInUser({
    required int eventId,
    required int userId,
  }) async {
    try {
      final authService = AuthService();
      final token = await authService.getStoredToken();
      
      if (token == null || token.isEmpty) {
        throw ApiException(
          message: 'Authentication required',
          statusCode: 401,
        );
      }

      if (kDebugMode) {
      }

      final response = await _apiClient.post(
        '/api/events/$eventId/attendees/$userId/check-in',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final result = response['success'] ?? false;
      
      if (kDebugMode) {
      }
      return result;
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
      }
      throw ApiException(
        message: 'Failed to check in: ${e.toString()}',
        error: e,
      );
    }
  }

  /// Get check-in status for all attendees
  Future<Map<int, bool>> getCheckInStatus(int eventId) async {
    try {
      final authService = AuthService();
      final token = await authService.getStoredToken();
      
      if (token == null || token.isEmpty) {
        throw ApiException(
          message: 'Authentication required',
          statusCode: 401,
        );
      }

      if (kDebugMode) {
      }

      final response = await _apiClient.get(
        '/api/events/$eventId/check-ins',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
      }

      Map<int, bool> checkInMap = {};
      
      // Handle response format: { "checked_in": [ { "user_id": N, ... }, ... ] }
      if (response.containsKey('checked_in')) {
        final checkedInList = response['checked_in'] as List<dynamic>? ?? [];
        for (var item in checkedInList) {
          if (item is Map && item.containsKey('user_id')) {
            checkInMap[item['user_id'] as int] = true;
          }
        }
      }
      
      if (kDebugMode) {
      }
      
      return checkInMap;
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
      }
      throw ApiException(
        message: 'Failed to get check-in status: ${e.toString()}',
        error: e,
      );
    }
  }

  /// Get all invitations for an event
  /// Returns a list of invitations with user details
  Future<List<EventInvitation>> getEventInvitations({
    required int eventId,
    String? statusFilter,
  }) async {
    try {
      final authService = AuthService();
      final token = await authService.getStoredToken();
      
      if (token == null || token.isEmpty) {
        throw ApiException(
          message: 'Authentication required',
          statusCode: 401,
        );
      }

      if (kDebugMode) {
      }

      final response = await _apiClient.get(
        '/api/events/$eventId/invitations',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
      }

      // Handle new API response format: { "total_invitations_count": N, "invitations": [...] }
      List<dynamic> invitationsList = [];
      
      if (response.containsKey('invitations')) {
        // New format with object wrapper
        invitationsList = response['invitations'] as List<dynamic>? ?? [];
      }

      if (kDebugMode) {
      }

      return invitationsList
          .map((e) => EventInvitation.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
      }
      throw ApiException(
        message: 'Failed to get invitations: ${e.toString()}',
        error: e,
      );
    }
  }

  /// Check in an attendee using ticket secret (host only)
  /// Flow: Backend finds AttendanceRecord by (event_id, ticket_secret) and calls check_in()
  /// Idempotent: If already checked_in, returns 200 with already_checked_in: true
  Future<Map<String, dynamic>> checkInWithTicketSecret({
    required int eventId,
    required String ticketSecret,
  }) async {
    try {
      final authService = AuthService();
      final token = await authService.getStoredToken();
      
      if (token == null || token.isEmpty) {
        throw ApiException(
          message: 'Authentication required',
          statusCode: 401,
        );
      }

      if (kDebugMode) {
      }

      final response = await _apiClient.post(
        '/api/events/$eventId/check-in',
        body: {
          'ticket_secret': ticketSecret,
        },
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
      }

      return {
        'success': true,
        'already_checked_in': response['already_checked_in'] ?? false,
        'attendance': response['attendance'] ?? {},
      };
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
      }
      throw ApiException(
        message: 'Failed to check in: ${e.toString()}',
        error: e,
      );
    }
  }
}

class EventAttendee {
  final int userId;
  final String fullName;
  final String username;
  final String? profilePictureUrl;
  final String? ticketSecret;
  final bool isCheckedIn;
  final String status;
  final int seats;

  EventAttendee({
    required this.userId,
    required this.fullName,
    required this.username,
    this.profilePictureUrl,
    this.ticketSecret,
    this.isCheckedIn = false,
    this.status = 'going',
    this.seats = 1,
  });

  factory EventAttendee.fromJson(Map<String, dynamic> json) {
    return EventAttendee(
      userId: json['user_id'] as int,
      fullName: json['full_name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      profilePictureUrl: json['profile_picture_url'] as String?,
      ticketSecret: json['ticket_secret'] as String?,
      isCheckedIn: json['checked_in'] as bool? ?? json['is_checked_in'] as bool? ?? false,
      status: json['status'] as String? ?? 'going',
      seats: json['seats'] as int? ?? 1,
    );
  }
}

class EventInvitation {
  final int inviteId;
  final int userId;
  final String fullName;
  final String? profilePictureUrl;
  final String status;
  final String message;
  final String expiresAt;
  final String expiryPolicy;

  EventInvitation({
    required this.inviteId,
    required this.userId,
    required this.fullName,
    this.profilePictureUrl,
    required this.status,
    required this.message,
    required this.expiresAt,
    required this.expiryPolicy,
  });

  factory EventInvitation.fromJson(Map<String, dynamic> json) {
    return EventInvitation(
      inviteId: json['invite_id'] as int,
      userId: json['user_id'] as int,
      fullName: json['full_name'] as String? ?? '',
      profilePictureUrl: json['profile_picture_url'] as String?,
      status: json['status'] as String? ?? 'pending',
      message: json['message'] as String? ?? '',
      expiresAt: json['expires_at'] as String? ?? '',
      expiryPolicy: json['expiry_policy'] as String? ?? '48h',
    );
  }
}
