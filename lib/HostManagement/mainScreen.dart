import 'package:flutter/material.dart';
import 'package:text_code/HostManagement/invitedEmpty.dart';
import 'package:text_code/HostManagement/requestsEmpty.dart';
import 'package:text_code/HostManagement/confirmedEmpty.dart';
import 'package:text_code/HostManagement/eventConfirmed.dart';
import 'package:text_code/HostManagement/evenAnalytics.dart';
import 'package:text_code/HostManagement/rspv.dart';
import 'package:text_code/Reusable/guest_empty_state_sheet.dart';
import 'package:text_code/Reusable/main_screen_content.dart';
import 'package:text_code/HostManagement/sentInvitesScreen.dart';
import 'package:text_code/Reusable/tab_content_ui.dart';

class MainScreen extends StatefulWidget {
  final String eventName;
  final String eventPrice;
  final int confirmedUsers;
  final int invitedCount;
  final int requestsCount;
  final int checkInCount;

  const MainScreen({
    super.key,
    required this.eventName,
    required this.eventPrice,
    this.confirmedUsers = 0,
    this.invitedCount = 0,
    this.requestsCount = 0,
    this.checkInCount = 0,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? selectedRsvpOption; // Track selected RSVP option

  @override
  void initState() {
    super.initState();
    selectedRsvpOption = null; // Initially no RSVP selected
  }

  void _refreshCount() {
    setState(() {
      // Trigger rebuild to update the count
    });
  }

  @override
  Widget build(BuildContext context) {
    // Always use dynamic count from TabContentUI (starts at 0, updates as users are invited)
    final dynamicInvitedCount = TabContentUI.getInvitedUsersCount();
    
    // Always use dynamic count from TabContentUI for confirmed users
    final dynamicConfirmedCount = TabContentUI.getConfirmedUsersCount();
    // Always use dynamic count from TabContentUI for request users
    final dynamicRequestsCount = TabContentUI.getRequestUsersCount();
    
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      body: SafeArea(
        child: MainScreenContent(
          eventName: widget.eventName,
          eventPrice: widget.eventPrice,
          confirmedUsers: dynamicConfirmedCount, // Always use dynamic count
          invitedCount: dynamicInvitedCount, // Always use dynamic count
          requestsCount: dynamicRequestsCount, // Always use dynamic count
          checkInCount: widget.checkInCount,
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
              onUsersInvited: _refreshCount, // Pass callback to refresh count
            );
            // Rebuild when modal closes to update count
            _refreshCount();
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
            );
            // Rebuild when modal closes to update count
            _refreshCount();
          },
          onConfirmedTap: () async {
            // Always use dynamic count from TabContentUI
            final dynamicCount = TabContentUI.getConfirmedUsersCount();
            await ConfirmedEmpty.show(context, confirmedCount: dynamicCount);
            // Rebuild when modal closes to update count
            _refreshCount();
          },
          onCheckedInTap: () {
            // Always show empty state using GuestEmptyStateSheet
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
                final confirmedCount = TabContentUI.getConfirmedUsersCount();
                if (confirmedCount == 0) {
                  // Show confirmed empty state
                  ConfirmedEmpty.show(context, confirmedCount: confirmedCount);
                } else {
                  // Show event confirmed in normal mode (with verified check icons)
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => EventConfirmed(
                      users: TabContentUI.getConfirmedUsers(),
                      isCheckInMode: false, // Normal mode, not check-in mode
                    ),
                  );
                }
              },
            );
          },
          onStartCheckInTap: () {
            // Always open eventConfirmed with Guest List UI (check-in mode)
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => EventConfirmed(
                users: TabContentUI.getConfirmedUsers(),
                isCheckInMode: true, // Enable check-in mode
              ),
            );
          },
          onEditRsvpTap: () async {
            final result = await RspvScreen.show(context);
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
            );
          },
          onSentInvitesTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => SentInvitesScreen(
                eventName: widget.eventName,
                eventPrice: widget.eventPrice,
                confirmedUsers: widget.confirmedUsers,
                onUsersInvited: _refreshCount, // Pass callback to refresh count
              ),
            ).then((_) {
              // Rebuild when modal closes to update count
              _refreshCount();
            });
          },
        ),
      ),
    );
  }
}

