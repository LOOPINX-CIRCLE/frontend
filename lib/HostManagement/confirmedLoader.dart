import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:text_code/core/services/invitation_service.dart';
import 'package:text_code/Reusable/tab_content_ui.dart';
import 'package:text_code/HostManagement/eventConfirmed.dart';
import 'package:text_code/core/network/api_exception.dart';

class ConfirmedLoader extends StatefulWidget {
  final int eventId;
  final String? eventName;
  final String? eventPrice;
  final bool isCheckInMode;

  const ConfirmedLoader({
    super.key,
    required this.eventId,
    this.eventName,
    this.eventPrice,
    this.isCheckInMode = false,
  });

  @override
  State<ConfirmedLoader> createState() => _ConfirmedLoaderState();
}

class _ConfirmedLoaderState extends State<ConfirmedLoader> {
  final InvitationService _invitationService = InvitationService();
  late Future<List<User>> _confirmedFuture;

  @override
  void initState() {
    super.initState();
    _confirmedFuture = _loadConfirmed();
  }

  Future<List<User>> _loadConfirmed() async {
    try {
      if (kDebugMode) {
        print('Loading confirmed attendees for event: ${widget.eventId}');
      }

      // Fetch confirmed attendees from API
      final attendees = await _invitationService.getEventAttendees(widget.eventId);

      if (kDebugMode) {
        print('❄️ Loaded ${attendees.length} confirmed attendees');
        // Log first attendee's full structure to diagnose data issues
        if (attendees.isNotEmpty) {
          print('📋 First attendee raw data:');
          final first = attendees.first;
          print('   fullName: ${first.fullName}');
          print('   profilePictureUrl: ${first.profilePictureUrl}');
          print('   userId: ${first.userId}');
          print('   isCheckedIn: ${first.isCheckedIn}');
          print('   All fields: ${first.runtimeType}');
        }
      }

      // Convert API attendees to User format for EventConfirmed display
      final users = attendees.map((attendee) {
        // Handle network image URLs from API (both full URLs and relative paths)
        String imagePath = 'assets/images/avatar.png';
        if (attendee.profilePictureUrl != null && attendee.profilePictureUrl!.isNotEmpty) {
          imagePath = attendee.profilePictureUrl!;
        }

        if (kDebugMode) {
          print('\n════════════════════════════════════════');
          print('📸 [CONFIRMED LOADER] ${attendee.fullName}');
          print('════════════════════════════════════════');
          print('✓ API profilePictureUrl: ${attendee.profilePictureUrl}');
          print('✓ Is NULL: ${attendee.profilePictureUrl == null}');
          print('✓ Is EMPTY: ${attendee.profilePictureUrl?.isEmpty ?? "N/A (null)"}');
          print('✓ Using imagePath: $imagePath');
          print('✓ Type: ${attendee.runtimeType}');
          print('════════════════════════════════════════\n');
        }

        return User(
          id: attendee.userId.toString(),
          name: attendee.fullName,
          imagePath: imagePath,
          isSelected: false,
          isProcessed: true, // All confirmed attendees are processed
        );
      }).toList();

      if (kDebugMode) {
        print('✅ Successfully loaded ${users.length} confirmed attendees');
      }

      return users;
    } on ApiException catch (e) {
      if (kDebugMode) {
        print('❌ ApiException loading confirmed attendees: $e');
      }
      // Provide meaningful error message
      String errorMessage = 'Failed to load confirmed guests';
      if (e.statusCode == 400) {
        errorMessage = 'Event is not published';
      } else if (e.statusCode == 401) {
        errorMessage = 'Authentication failed';
      } else if (e.statusCode == 403) {
        errorMessage = 'You do not have permission';
      } else if (e.statusCode == 404) {
        errorMessage = 'Event not found';
      } else {
        errorMessage = e.message;
      }
      throw Exception(errorMessage);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading confirmed attendees: $e');
      }
      rethrow;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<User>>(
      future: _confirmedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          final errorMessage = snapshot.error.toString();
          
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 64,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9355F0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Go Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final users = snapshot.data ?? [];

        if (users.isEmpty) {
          return TabContentUI.buildEmptyState(
            context,
            title: 'Confirmed Guests',
            iconPath: 'assets/icons/No request empty state.png',
            mainText: 'No confirmed guests yet',
            subText: 'Confirmed guests will appear here once they accept your event invitation.',
            buttonText: 'Send Invites',
          );
        }

        return EventConfirmed(
          users: users,
          isCheckInMode: widget.isCheckInMode,
        );
      },
    );
  }
}
