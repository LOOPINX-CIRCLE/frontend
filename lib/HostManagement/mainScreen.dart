import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:text_code/HostManagement/invitedEmpty.dart';
import 'package:text_code/HostManagement/requestsEmpty.dart';
import 'package:text_code/HostManagement/confirmedEmpty.dart';
import 'package:text_code/HostManagement/confirmedLoader.dart';
import 'package:text_code/HostManagement/eventCheckIn.dart';
import 'package:text_code/HostManagement/evenAnalytics.dart';
import 'package:text_code/HostManagement/rspv.dart';
import 'package:text_code/Reusable/guest_empty_state_sheet.dart';
import 'package:text_code/Reusable/main_screen_content.dart';
import 'package:text_code/HostManagement/sentInvitesScreen.dart';
import 'package:text_code/Reusable/tab_content_ui.dart';
import 'package:text_code/core/services/event_request_service.dart';
import 'package:text_code/core/services/invitation_service.dart';
import 'package:text_code/core/network/api_exception.dart';

class MainScreen extends StatefulWidget {
  final String eventName;
  final String eventPrice;
  final int confirmedUsers;
  final int invitedCount;
  final int requestsCount;
  final int checkInCount;
  final int? eventId; // Add event ID for fetching real-time request data
  final DateTime? eventDateTime; // Add event date/time for check-in validation
  final String eventStatus; // Add event status for bank account button

  const MainScreen({
    super.key,
    required this.eventName,
    required this.eventPrice,
    this.confirmedUsers = 0,
    this.invitedCount = 0,
    this.requestsCount = 0,
    this.checkInCount = 0,
    this.eventId,
    this.eventDateTime,
    this.eventStatus = 'planned',
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? selectedRsvpOption; // Track selected RSVP option
  final EventRequestService _eventRequestService = EventRequestService();
  final InvitationService _invitationService = InvitationService();
  int _actualRequestsCount = 0;
  int _actualInvitedCount = 0;
  int _actualCheckInCount = 0;

  @override
  void initState() {
    super.initState();
    // Clear previous event's check-in state when opening a new event
    TabContentUI.clearCheckedInUsers();
    
    selectedRsvpOption = null; // Initially no RSVP selected
    _actualRequestsCount = widget.requestsCount;
    _actualInvitedCount = widget.invitedCount;
    _actualCheckInCount = 0; // Start with 0, will be populated from actual check-ins
    
    // Fetch actual check-in count from API
    _fetchActualCheckInCount();
    
    // DO NOT fetch counts in initState - use widget counts directly
    // Real-time counts will be fetched only when user interacts with the UI
  }

  /// Fetch the actual pending request count from the API
  Future<void> _fetchActualRequestCount({bool showError = false}) async {
    try {
      if (widget.eventId == null) return;
      
      // Get list of pending request IDs to get accurate count
      final requestIds = await _eventRequestService.getEventPendingRequests(widget.eventId!);
      
      // Update the count to reflect only pending requests
      if (mounted) {
        setState(() {
          _actualRequestsCount = requestIds.length;
        });
      }
    } on ApiException catch (e) {
      if (showError && e.statusCode != 400) {
        // Only show error if not a "not published" error (400)
        _showErrorSnackBar(e.message);
      }
      // Silently fallback to widget's requestsCount if API fails
      if (mounted) {
        setState(() {
          _actualRequestsCount = widget.requestsCount;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching pending request count: $e');
      }
      // Silently fallback to widget's requestsCount if API fails
      if (mounted) {
        setState(() {
          _actualRequestsCount = widget.requestsCount;
        });
      }
    }
  }

  /// Fetch the actual pending invitation count from the API
  Future<void> _fetchActualInvitedCount({bool showError = false}) async {
    try {
      if (widget.eventId == null) return;
      
      // Get list of pending invitations to get accurate count
      final invitations = await _invitationService.getEventInvitations(
        eventId: widget.eventId!,
        statusFilter: 'pending', // Only count pending invitations
      );
      
      // Update the count to reflect only pending invitations
      if (mounted) {
        setState(() {
          _actualInvitedCount = invitations.length;
        });
      }
    } on ApiException catch (e) {
      if (showError && e.statusCode != 400) {
        // Only show error if not a "not published" error (400)
        _showErrorSnackBar(e.message);
      }
      // Silently fallback to widget's invitedCount if API fails
      if (mounted) {
        setState(() {
          _actualInvitedCount = widget.invitedCount;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching pending invited count: $e');
      }
      // Silently fallback to widget's invitedCount if API fails
      if (mounted) {
        setState(() {
          _actualInvitedCount = widget.invitedCount;
        });
      }
    }
  }

  /// Show error snackbar
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _refreshAllCounts() {
    // Refresh all counts from API with error display
    _fetchActualRequestCount(showError: true);
    _fetchActualInvitedCount(showError: true);
    _fetchActualCheckInCount();
  }

  /// Refresh the actual check-in count when returning from EventCheckIn
  Future<void> _fetchActualCheckInCount() async {
    try {
      // Fetch attendees and count how many have actually checked in
      final attendees = await _invitationService.getEventAttendees(widget.eventId!);
      
      // Count only attendees who have isCheckedIn: true
      final checkedInCount = attendees.where((attendee) => attendee.isCheckedIn).length;
      
      if (mounted) {
        setState(() {
          _actualCheckInCount = checkedInCount;
        });
      }
      
      if (kDebugMode) {
        print('✅ Check-in count updated: $checkedInCount out of ${attendees.length} attendees checked in');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching check-in count: $e');
      }
      // Fallback to 0 if error
      setState(() {
        _actualCheckInCount = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use actual invited count from API (from widget or fetched)
    final dynamicInvitedCount = _actualInvitedCount;
    
    // Use actual confirmed count from API (passed through widget.confirmedUsers)
    // This comes from event.goingCount in the GET /api/events response
    final dynamicConfirmedCount = widget.confirmedUsers;
    
    // Use actual requests count from API (from widget or fetched)
    final dynamicRequestsCount = _actualRequestsCount;
    
    // Use actual check-in count from TabContentUI
    final dynamicCheckInCount = _actualCheckInCount;

    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      body: SafeArea(
        child: MainScreenContent(
          eventName: widget.eventName,
          eventPrice: widget.eventPrice,
          eventDateTime: widget.eventDateTime, // Pass event date/time for check-in validation
          confirmedUsers: dynamicConfirmedCount, // Always use dynamic count
          invitedCount: dynamicInvitedCount, // Always use dynamic count
          requestsCount: dynamicRequestsCount, // Use actual request count
          checkInCount: dynamicCheckInCount,
          selectedRsvpOption: selectedRsvpOption, // Pass RSVP option
          onInvitedTap: () async {
            // Always use dynamic count from TabContentUI
            final dynamicCount = TabContentUI.getInvitedUsersCount();
            await InvitedEmpty.show(
                                  context,
                                  eventName: widget.eventName,
                                  eventPrice: widget.eventPrice,
              confirmedUsers: widget.confirmedUsers,
              invitedCount: dynamicCount,
              onUsersInvited: _refreshAllCounts, // Pass callback to refresh counts
              eventId: widget.eventId,
            );
            // Rebuild when modal closes to update counts
            _refreshAllCounts();
          },
          onRequestsTap: () async {
            // Always use dynamic count from TabContentUI
            final dynamicCount = TabContentUI.getRequestUsersCount();
            await RequestsEmpty.show(
                                  context,
                                  eventName: widget.eventName,
                                  eventPrice: widget.eventPrice,
              confirmedUsers: widget.confirmedUsers,
              requestsCount: dynamicCount,
              eventId: widget.eventId,
            );
            // Rebuild when modal closes to update counts
            _refreshAllCounts();
          },
          onConfirmedTap: () async {
            // Use confirmed count from API (event.goingCount)
            final dynamicCount = widget.confirmedUsers;
            await ConfirmedEmpty.show(context, confirmedCount: dynamicCount, eventId: widget.eventId, eventName: widget.eventName, defaultRsvpOption: selectedRsvpOption);
            // Rebuild when modal closes to update counts
            _refreshAllCounts();
          },
          onCheckedInTap: () {
            // If start check-in is active (selectedRsvpOption is set), go to check-in list
            if (selectedRsvpOption != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventCheckIn(
                    users: TabContentUI.getConfirmedUsers(),
                    eventId: widget.eventId,
                  ),
                ),
              );
            } else {
              // Otherwise show the normal confirmed guests view
              GuestEmptyStateSheet.show(
                context,
                title: 'Checked-In Guests',
                iconPath: 'assets/icons/Check in empty state.png',
                mainText: ' Check-in starts 3hr \nbefore the event',
                subText: 'Guests who check in at your event will appear here.',
                buttonText: 'View Guest List ',
                onButtonTap: () {
                  // Close empty state and open confirmed guests list (normal mode)
                  Navigator.pop(context);
                  final confirmedCount = widget.confirmedUsers;
                  if (confirmedCount == 0) {
                    // Show confirmed empty state
                    ConfirmedEmpty.show(context, confirmedCount: confirmedCount, eventId: widget.eventId, eventName: widget.eventName, defaultRsvpOption: selectedRsvpOption);
                  } else {
                    // Show confirmed guests from API in normal mode
                    if (widget.eventId != null && widget.eventId! > 0) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => ConfirmedLoader(
                          eventId: widget.eventId!,
                          eventName: widget.eventName,
                          eventPrice: widget.eventPrice,
                          isCheckInMode: false, // Normal mode, not check-in mode
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Event ID not available')),
                      );
                    }
                  }
                },
              );
            }
          },
          onStartCheckInTap: () {
            // Navigate to check-in list page with eventId to fetch confirmed users from API
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventCheckIn(
                  users: TabContentUI.getConfirmedUsers(),
                  eventId: widget.eventId,
                ),
              ),
            ).then((_) {
              // Refresh check-in count when returning from EventCheckIn page
              _fetchActualCheckInCount();
            });
          },
          onEditRsvpTap: () async {
            final result = await RspvScreen.show(context, eventId: widget.eventId);
            if (result != null) {
              setState(() {
                selectedRsvpOption = result;
              });
            }
          },
          onEventAnalyticsTap: () {
            EventAnalyticsScreen.show(
              context,
              confirmedGuests: dynamicConfirmedCount,
              eventPrice: widget.eventPrice,
              isCheckInActive: selectedRsvpOption == '48 Hours',
              eventStatus: widget.eventStatus,
              onRefreshCounts: _refreshAllCounts,
            );
          },
          onSentInvitesTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => SentInvitesScreen(
                eventId: widget.eventId,
                eventName: widget.eventName,
                eventPrice: widget.eventPrice,
                confirmedUsers: widget.confirmedUsers,
                onUsersInvited: _refreshAllCounts, // Pass callback to refresh counts
                defaultRsvpOption: selectedRsvpOption, // Pass selected RSVP from mainScreen
              ),
            ).then((_) {
              // Rebuild when modal closes to update counts
              _refreshAllCounts();
            });
          },
        ),
      ),
    );
  }
}

