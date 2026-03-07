import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:text_code/core/services/invitation_service.dart';
import 'package:text_code/Reusable/tab_content_ui.dart';
import 'package:text_code/HostManagement/eventConfirmed.dart';

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
          return Center(
            child: Text('Error: ${snapshot.error}'),
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
