import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:text_code/Host_Pages/Controller_files/event_cntroller.dart';
import 'package:text_code/Reusable/ticket_navigation.dart';
import 'package:text_code/login-signup/sign_up/booked_ticket.dart';
import 'package:text_code/Home_pages/Controller/ticket_controller.dart';
import 'package:text_code/core/services/event_request_service_host.dart';
import 'package:text_code/core/network/api_exception.dart';
import 'package:intl/intl.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  final EventController eventController = Get.find<EventController>();
  final UserTicketController ticketController = Get.put(UserTicketController());
  final EventRequestService _eventRequestService = EventRequestService();
  bool isLoading = false;

  /// Format date from API response (ISO 8601 format)
  String _formatDate(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return eventController.date.value;
    }
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('EEEE d, MMMM yyyy').format(dateTime);
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing date: $e');
      }
      return eventController.date.value;
    }
  }

  /// Format time from API response (ISO 8601 format)
  String _formatTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return eventController.time.value;
    }
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('h:mm a').format(dateTime);
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing time: $e');
      }
      return eventController.time.value;
    }
  }

  /// Get ticket from API and create UserTicket
  Future<void> _getTicketFromAPI() async {
    if (eventController.eventId.value == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event ID not available'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
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

      // Get ticket from API
      final ticketData = await _eventRequestService.getTicket(eventController.eventId.value);

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (kDebugMode) {
        print('Ticket fetched successfully: $ticketData');
      }

      // Extract data from API response
      final ticketSecret = ticketData['ticket_secret']?.toString() ?? '';
      final eventTitle = ticketData['event_title']?.toString() ?? eventController.eventTitle.value;
      final venueName = ticketData['venue_name']?.toString() ?? eventController.loaction.value;
      final startTime = ticketData['event_start_time']?.toString();
      final coverImageUrl = ticketData['cover_image_url']?.toString() ?? eventController.eventImage.value;

      if (ticketSecret.isEmpty) {
        throw Exception('Ticket secret code not found in API response');
      }

      // Format date and time from API
      final formattedDate = _formatDate(startTime);
      final formattedTime = _formatTime(startTime);

      // Create ticket with API data
      final ticket = UserTicket(
        title: eventTitle,
        date: formattedDate,
        location: venueName,
        code: ticketSecret, // Use secret code from API
        eventImage: coverImageUrl.isNotEmpty 
            ? coverImageUrl 
            : (eventController.eventImage.value.isNotEmpty
                ? eventController.eventImage.value
                : "assets/images/image (1).png"),
      );

      // Add ticket to controller
      ticketController.addTicket(ticket);

      // Update event controller with API data for consistency
      eventController.eventTitle.value = eventTitle;
      eventController.loaction.value = venueName;
      eventController.date.value = formattedDate;
      eventController.time.value = formattedTime;
      if (coverImageUrl.isNotEmpty) {
        eventController.eventImage.value = coverImageUrl;
      }

      setState(() {
        isLoading = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ticket generated successfully! 🎉'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Navigate to BookedTicket
      if (mounted) {
        Get.to(() => const BookedTicket());
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      setState(() {
        isLoading = false;
      });

      if (kDebugMode) {
        print('Error getting ticket: $e');
        print('Error type: ${e.runtimeType}');
      }

      // Extract meaningful error message
      String errorMessage = e.toString();
      
      // Remove "ApiException: " prefix if present
      if (errorMessage.startsWith('ApiException: ')) {
        errorMessage = errorMessage.substring('ApiException: '.length);
      }

      // Show error message
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
    return Obx(
      () => TicketInfoCard(
        title: "Just one click away from your spot",
        infoItems: [
          {"title": "Event", "value": eventController.eventTitle.value},
          {
            "title": "Venue",
            "value": eventController.loaction.value,
            "isBold": true,
          },
          {"title": "Date & Time", "value": eventController.dateTime},
          {"title": "Ticket Type", "value": eventController.ticketPrice.value == "Free" ? "Free" : eventController.Price},
        ],
        buttonText: isLoading ? "Loading..." : "Generate Ticket",
        onButtonPressed: isLoading 
            ? () {} // Empty function when loading (button will be disabled by loading state)
            : () {
                // Wrap async call in synchronous function
                _getTicketFromAPI();
        },
      ),
    );
  }
}
