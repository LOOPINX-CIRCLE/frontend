import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:text_code/Reusable/ticker_payment_screen.dart';
import 'package:text_code/Host_Pages/Controller_files/event_cntroller.dart';
import 'package:text_code/login-signup/sign_up/booked_ticket.dart';
import 'package:text_code/Home_pages/Controller/ticket_controller.dart';
import 'package:text_code/Home_pages/Controller/home_page.dart';
import 'package:text_code/Home_pages/UI_Design/home_with_tabs.dart';
import 'package:text_code/core/services/event_request_service_host.dart';
import 'package:text_code/core/network/api_exception.dart';

class SucessFullPayment extends StatefulWidget {
  const SucessFullPayment({super.key});

  @override
  State<SucessFullPayment> createState() => _SucessFullPaymentState();
}

class _SucessFullPaymentState extends State<SucessFullPayment> {
  final EventController eventController = Get.find<EventController>();
  final UserTicketController ticketController = Get.put(UserTicketController());
  final EventRequestService _eventRequestService = EventRequestService();
  bool _isLoadingTicket = false;

  Future<void> _fetchTicketFromAPI() async {
    if (eventController.eventId.value == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event ID not available'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoadingTicket = true;
    });

    try {
      if (kDebugMode) {
        print('Fetching ticket for event ID: ${eventController.eventId.value}');
      }

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );

      final ticketData = await _eventRequestService.getTicket(eventController.eventId.value);

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (kDebugMode) {
        print('Ticket fetched successfully: $ticketData');
      }

      // Extract ticket data from API response
      final ticketSecret = ticketData['ticket_secret']?.toString() ?? '';
      final eventTitle = ticketData['event_title']?.toString() ?? '';
      final venueName = ticketData['venue_name']?.toString() ?? '';
      final eventStartTime = ticketData['event_start_time']?.toString() ?? '';
      final coverImageUrl = ticketData['cover_image_url']?.toString() ?? '';

      if (ticketSecret.isEmpty) {
        throw Exception('Ticket secret code not found in API response');
      }

      // Format date from event_start_time
      String formattedDate = '';
      if (eventStartTime.isNotEmpty) {
        try {
          final dateTime = DateTime.parse(eventStartTime);
          formattedDate = DateFormat('EEEE d, MMMM yyyy').format(dateTime);
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing date: $e');
          }
          formattedDate = eventController.date.value.isNotEmpty
              ? eventController.date.value
              : "Date TBD";
        }
      } else {
        formattedDate = eventController.date.value.isNotEmpty
            ? eventController.date.value
            : "Date TBD";
      }

      // Create ticket with API data
      final ticket = UserTicket(
        title: eventTitle.isNotEmpty ? eventTitle : eventController.eventTitle.value,
        date: formattedDate,
        location: venueName.isNotEmpty ? venueName : eventController.loaction.value,
        code: ticketSecret,
        eventImage: coverImageUrl.isNotEmpty
            ? coverImageUrl
            : (eventController.eventImage.value.isNotEmpty
                ? eventController.eventImage.value
                : "assets/images/image (1).png"),
      );

      ticketController.addTicket(ticket);

      // Mark any matching invitation as accepted so home cards show \"View Ticket\" + \"You're Going!\"
      try {
        if (Get.isRegistered<HomePageController>()) {
          Get.find<HomePageController>()
              .updateInvitationStatusForEvent(eventController.eventId.value, 'accepted');
        }
      } catch (_) {}

      // Update event controller with API data for consistency
      if (eventTitle.isNotEmpty) {
        eventController.eventTitle.value = eventTitle;
      }
      if (venueName.isNotEmpty) {
        eventController.loaction.value = venueName;
      }
      if (formattedDate.isNotEmpty && formattedDate != "Date TBD") {
        eventController.date.value = formattedDate;
      }
      if (coverImageUrl.isNotEmpty) {
        eventController.eventImage.value = coverImageUrl;
      }

      setState(() {
        _isLoadingTicket = false;
      });

      if (mounted) {
        // Navigate to home with ticket tab so user sees their ticket and Discover shows View Ticket
        Get.off(() => const HomeWithTabs(initialTab: 1));
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      setState(() {
        _isLoadingTicket = false;
      });

      if (kDebugMode) {
        print('Error fetching ticket: $e');
      }

      String errorMessage = 'Failed to fetch ticket. Please try again.';
      if (e is ApiException) {
        errorMessage = e.message;
      } else if (e.toString().contains('403')) {
        errorMessage = 'Payment required. Please complete payment first.';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Ticket not found. Please contact support.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only date (no time)
    String formattedDate =
        eventController.date.value.isNotEmpty
            ? eventController.date.value
            : "07/05/25";

    return PaymentStatusScreen(
      appBarTitle: "Payment successful",
      imagePath: "assets/icons/payment.png",

      primaryButtonText: _isLoadingTicket ? "Loading..." : "View Ticket",
      onPrimaryPressed: _isLoadingTicket ? () {} : _fetchTicketFromAPI,

      secondaryButtonText: "Add to calendar",
      onSecondaryPressed: () {},

      eventTitle: eventController.eventTitle.value.isNotEmpty
          ? eventController.eventTitle.value
          : "Sizzle",

      venue: eventController.loaction.value.isNotEmpty
          ? eventController.loaction.value
          : "Bastian garden city",

      // Only date displayed here
      dateTime: formattedDate,
    );
  }
}
