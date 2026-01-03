import 'package:flutter/material.dart';
import 'package:text_code/HostManagement/invitedEmpty.dart';
import 'package:text_code/HostManagement/requestsEmpty.dart';
import 'package:text_code/HostManagement/confirmedEmpty.dart';
import 'package:text_code/HostManagement/eventConfirmed.dart';
import 'package:text_code/HostManagement/evenAnalytics.dart';
import 'package:text_code/HostManagement/rspv.dart';
import 'package:text_code/Reusable/guest_empty_state_sheet.dart';
import 'package:text_code/Reusable/main_screen_content.dart';
import 'package:text_code/Reusable/tab_content_ui.dart';

class EmptyMainScreen extends StatefulWidget {
  final String eventName;
  final String eventPrice;

  const EmptyMainScreen({
    super.key,
    required this.eventName,
    required this.eventPrice,
  });

  @override
  State<EmptyMainScreen> createState() => _EmptyMainScreenState();
}

class _EmptyMainScreenState extends State<EmptyMainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      body: SafeArea(
        child: MainScreenContent(
          eventName: widget.eventName,
          eventPrice: widget.eventPrice,
          confirmedUsers: 0,
          invitedCount: 0,
          requestsCount: 0,
          checkInCount: 0,
          onInvitedTap: () {
            InvitedEmpty.show(
              context,
              eventName: widget.eventName,
              eventPrice: widget.eventPrice,
              confirmedUsers: 0,
              invitedCount: 0,
              onUsersInvited: null, // No callback needed for empty screen
            );
          },
          onRequestsTap: () {
            RequestsEmpty.show(
              context,
              eventName: widget.eventName,
              eventPrice: widget.eventPrice,
              confirmedUsers: 0,
              requestsCount: 0,
            );
          },
          onConfirmedTap: () {
            ConfirmedEmpty.show(context, confirmedCount: 0);
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
                // Close empty state and open check-in cards
                Navigator.pop(context);
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
            );
          },
          onStartCheckInTap: () {
            // Always open eventConfirmed with Guest List UI (check-in mode)
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => EventConfirmed(
                users: const [], // Empty list for empty screen
                isCheckInMode: true, // Enable check-in mode
              ),
            );
          },
          onEditRsvpTap: () {
            RspvScreen.show(context);
          },
          onEventAnalyticsTap: () {
            EventAnalyticsScreen.show(
              context,
              confirmedGuests: 0,
              eventPrice: widget.eventPrice,
              isCheckInActive: false, // Empty screen, so check-in is never active
            );
          },
          onSentInvitesTap: () {
            InvitedEmpty.show(
              context,
              eventName: widget.eventName,
              eventPrice: widget.eventPrice,
              confirmedUsers: 0,
              invitedCount: 0,
            );
          },
        ),
      ),
    );
  }
}

