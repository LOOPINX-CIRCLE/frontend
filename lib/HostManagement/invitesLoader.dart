import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:text_code/Reusable/tab_content_ui.dart';
import 'package:text_code/HostManagement/eventInvited.dart';
import 'package:text_code/HostManagement/sentInvitesScreen.dart';
import 'package:text_code/core/services/invitation_service.dart';

class InvitesLoader extends StatefulWidget {
  final int eventId;
  final String? eventName;
  final String? eventPrice;
  final int? confirmedUsers;
  final VoidCallback? onUsersInvited;

  const InvitesLoader({
    super.key,
    required this.eventId,
    this.eventName,
    this.eventPrice,
    this.confirmedUsers,
    this.onUsersInvited,
  });

  @override
  State<InvitesLoader> createState() => _InvitesLoaderState();
}

class _InvitesLoaderState extends State<InvitesLoader> {
  late Future<List<User>> _invitesFuture;
  final InvitationService _invitationService = InvitationService();

  @override
  void initState() {
    super.initState();
    _invitesFuture = _loadInvites();
  }

  Future<List<User>> _loadInvites() async {
    try {
      if (kDebugMode) {
        print('Loading invites for event: ${widget.eventId}');
      }

      // Fetch invitations from API
      final invitations = await _invitationService.getEventInvitations(
        eventId: widget.eventId,
        statusFilter: 'pending', // Only show pending invitations
      );

      // Convert API invitations to User format for EventInvited display
      final users = invitations.map((invite) {
        // Handle network image URLs from API
        String imagePath = 'assets/images/avatar.png';
        if (invite.profilePictureUrl != null && invite.profilePictureUrl!.isNotEmpty) {
          imagePath = invite.profilePictureUrl!;
        }

        if (kDebugMode) {
          print('\n════════════════════════════════════════');
          print('📸 [INVITES LOADER] ${invite.fullName}');
          print('════════════════════════════════════════');
          print('✓ API profilePictureUrl: ${invite.profilePictureUrl}');
          print('✓ Is NULL: ${invite.profilePictureUrl == null}');
          print('✓ Is EMPTY: ${invite.profilePictureUrl?.isEmpty ?? "N/A (null)"}');
          print('✓ Using imagePath: $imagePath');
          print('✓ Type: ${invite.runtimeType}');
          print('════════════════════════════════════════\n');
        }
        
        return User(
          id: invite.userId.toString(),
          name: invite.fullName,
          imagePath: imagePath,
          isSelected: false,
          isProcessed: invite.status == 'accepted',
        );
      }).toList();
      
      if (kDebugMode) {
        print('Successfully loaded ${users.length} invites');
      }
      
      return users;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading invites: $e');
      }
      rethrow;
    }
  }

  void _openSendInvitesDialog() {
    if (kDebugMode) {
      print('🔘 Send Invites button tapped - showing SentInvitesScreen modal');
    }
    
    // Show SentInvitesScreen as modal bottom sheet (same as mainScreen)
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SentInvitesScreen(
        eventId: widget.eventId,
        eventName: widget.eventName ?? 'Event',
        eventPrice: widget.eventPrice ?? '₹0',
        confirmedUsers: widget.confirmedUsers ?? 0,
        onUsersInvited: widget.onUsersInvited,
      ),
    ).then((_) {
      // Refresh the invites list when returning from SentInvitesScreen
      if (mounted) {
        setState(() {
          _invitesFuture = _loadInvites();
        });
      }
      // Trigger the callback if provided
      widget.onUsersInvited?.call();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<User>>(
      future: _invitesFuture,
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
          if (kDebugMode) {
            print('📭 No invitations found - showing empty state with "Send Invites" button');
          }
          return TabContentUI.buildEmptyState(
            context,
            title: 'Invited Guest',
            iconPath: 'assets/icons/Invite empty state.png',
            mainText: 'Start building your guest list',
            subText: 'Use Send invites to handpick your crew.',
            buttonText: 'Sent Invites',
            onButtonTap: _openSendInvitesDialog,
          );
        }

        return EventInvited(users: users);
      },
    );
  }
}
