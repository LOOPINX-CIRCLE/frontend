import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:text_code/core/services/event_request_service.dart';
import 'package:text_code/Reusable/tab_content_ui.dart';
import 'package:text_code/HostManagement/eventRequests.dart';

class RequestsLoader extends StatefulWidget {
  final int eventId;
  final String? eventName;
  final String? eventPrice;
  final int? confirmedUsers;

  const RequestsLoader({
    super.key,
    required this.eventId,
    this.eventName,
    this.eventPrice,
    this.confirmedUsers,
  });

  @override
  State<RequestsLoader> createState() => _RequestsLoaderState();
}

class _RequestsLoaderState extends State<RequestsLoader> {
  final EventRequestService _eventRequestService = EventRequestService();
  late Future<List<User>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _requestsFuture = _loadRequests();
  }

  Future<List<User>> _loadRequests() async {
    try {
      if (kDebugMode) {
        print('Loading requests for event: ${widget.eventId}');
      }

      // Get ALL requests with full details from backend (new API format)
      final allRequests = await _eventRequestService.getAllEventRequests(widget.eventId);
      
      if (kDebugMode) {
        print('[RequestsLoader] Found ${allRequests.length} total requests');
      }

      // Convert API response to User objects
      List<User> users = [];
      for (var request in allRequests) {
        try {
          final requestId = request['id'] as int?;
          final fullName = request['full_name'] as String? ?? 'Unknown';
          final profilePictureUrl = request['profile_picture_url'] as String?;
          final status = request['status'] as String? ?? 'pending';
          final statusTrimmed = status.trim().toLowerCase();
          final isAccepted = statusTrimmed == 'accepted';

          if (kDebugMode) {
            print('[RequestsLoader] Processing: $fullName (ID: $requestId), Status: $status, isAccepted: $isAccepted');
          }

          // Use profile picture URL from API (both full URLs and relative paths) or default avatar
          final imagePath = (profilePictureUrl != null && profilePictureUrl.isNotEmpty)
              ? profilePictureUrl
              : 'assets/images/avatar.png';

          if (kDebugMode) {
            print('\n════════════════════════════════════════');
            print('📊 [REQUESTS LOADER] $fullName');
            print('════════════════════════════════════════');
            print('✓ API profilePictureUrl: $profilePictureUrl');
            print('✓ Is NULL: ${profilePictureUrl == null}');
            print('✓ Is EMPTY: ${profilePictureUrl?.isEmpty ?? "N/A (null)"}');
            print('✓ Using imagePath: $imagePath');
            print('✓ Status: $status');
            print('════════════════════════════════════════\n');
          }

          // Create User from request data
          final user = User(
            id: request['requester_id'].toString(),
            name: fullName,
            imagePath: imagePath,
            requestId: requestId, // Store the requestId for API calls
            requestStatus: status, // Store the status
            isProcessed: isAccepted, // Mark as processed if already accepted
          );

          if (kDebugMode) {
            print('  ✅ User created: ${user.name}, Status: ${user.requestStatus}, isProcessed: ${user.isProcessed}');
          }

          users.add(user);
        } catch (e) {
          if (kDebugMode) {
            print('❌ Error processing request: $e');
          }
          // Continue with next request even if one fails
        }
      }

      if (kDebugMode) {
        print('[RequestsLoader] ✅ Successfully loaded ${users.length} requests');
      }
      
      return users;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading requests: $e');
      }
      rethrow;
    }
  }

  @override
  void dispose() {
    _eventRequestService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<User>>(
      future: _requestsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final users = snapshot.data ?? [];

        if (users.isEmpty) {
          return TabContentUI.buildEmptyState(
            context,
            title: 'Join Requests',
            iconPath: 'assets/icons/No request empty state.png',
            mainText: 'No requests yet',
            subText: 'Requests from guests will appear here once they start requesting to join your event.',
            buttonText: 'Send Invites',
          );
        }

        return EventRequests(
          users: users,
          eventId: widget.eventId,
          onUsersAccepted: () {
            if (mounted) {
              setState(() {
                _requestsFuture = _loadRequests();
              });
            }
          },
        );
      },
    );
  }
}
