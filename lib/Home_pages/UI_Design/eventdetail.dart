import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:text_code/core/utils/image_utils.dart';
import 'package:text_code/Home_pages/Ticket_Pages_navigation/ticket_navigation_going/ticket_price_screen.dart';
import 'package:text_code/Home_pages/Ticket_Pages_navigation/ticket_navigation_going/ticket_screen_zero.dart';
import 'package:text_code/Host_Pages/Controller_files/event_cntroller.dart';
import 'package:text_code/Reusable/loopin_cta_button.dart';
import 'package:text_code/core/constants/env.dart';
import 'package:text_code/Reusable/smart_image.dart';
import 'package:text_code/core/utils/image_url_helper.dart';
import 'package:text_code/core/services/event_request_service_host.dart';
import 'package:text_code/core/network/api_exception.dart';
import 'package:text_code/Home_pages/Controller/ticket_controller.dart';

import 'package:text_code/Home_pages/Controller/home_page.dart';
import 'package:text_code/Home_pages/UI_Design/home_with_tabs.dart';
import 'package:text_code/core/models/event_invitation.dart';
import 'package:text_code/core/models/event_request.dart';


class EventDetail extends StatefulWidget {
  final String title;
  final String date;
  final String time;
  final String hostName;
  final String hostImage;
  final String eventImage;
  final String venue;
  final String fullAddress;
  final String aboutEvent;
  final String badgeText;
  final int attendeesCount;
  final List<String> attendeeImages;
  final bool isGoing;
  final String? price;
  final String? starImagePath;
  final int? eventId; // Event ID for API calls

  const EventDetail({
    super.key,
    required this.title,
    required this.date,
    required this.time,
    required this.hostName,
    required this.hostImage,
    required this.eventImage,
    required this.venue,
    required this.fullAddress,
    required this.aboutEvent,
    required this.badgeText,
    required this.attendeesCount,
    required this.attendeeImages,
    this.isGoing = false,
    this.price,
    this.starImagePath,
    this.eventId,
  });

  @override
  State<EventDetail> createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetail> {
  bool isRequestSent = false; // Track if request has been sent
  bool isSendingRequest = false; // Track if request is being sent
  bool isLoadingRequestStatus = true; // Track if we're loading request status
  bool isConfirmingAttendance = false; // Track if we're confirming attendance
  EventRequest? requestStatus; // Store request status from API
  final EventRequestService _eventRequestService = EventRequestService();
  EventInvitation? _eventInvitation; // Matching invitation, if any
  
  @override
  void initState() {
    super.initState();
    _loadInvitationForEvent();
    // Fetch request status when page loads
    if (widget.eventId != null) {
      _fetchRequestStatus();
    } else {
      setState(() {
        isLoadingRequestStatus = false;
      });
    }
  }

  /// Load invitation for this event from HomePageController, if available
  void _loadInvitationForEvent() {
    if (widget.eventId == null) return;
    try {
      if (Get.isRegistered<HomePageController>()) {
        final homeController = Get.find<HomePageController>();
        for (final inv in homeController.invitations) {
          if (inv.eventId == widget.eventId) {
            _eventInvitation = inv;
            break;
          }
        }
      }
    } catch (_) {
      // Safely ignore if controller is not available
    }
  }
  
  /// Fetch request status from API
  Future<void> _fetchRequestStatus() async {
    if (widget.eventId == null) {
      setState(() {
        isLoadingRequestStatus = false;
      });
      return;
    }
    
    try {
      if (kDebugMode) {
        print('Fetching request status for event ID: ${widget.eventId}');
      }
      
      final status = await _eventRequestService.getUserRequestStatus(widget.eventId!);
      
      if (mounted) {
        setState(() {
          requestStatus = status;
          isLoadingRequestStatus = false;
          // If request exists, mark as sent
          if (status != null) {
            isRequestSent = true;
          } else {
            isRequestSent = false;
          }
        });
        
        if (kDebugMode) {
          print('Request status fetched: ${status?.status ?? 'no request'}');
          print('Full request status: $status');
          print('isRequestSent: $isRequestSent');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching request status: $e');
      }
      if (mounted) {
        setState(() {
          isLoadingRequestStatus = false;
          requestStatus = null;
        });
      }
    }
  }

  String _resolveEventImage() {
    if (widget.eventImage.isNotEmpty) {
      return imageUrl(widget.eventImage);
    }
    try {
      final eventController = Get.find<EventController>();
      if (eventController.eventImage.value.isNotEmpty) {
        return imageUrl(eventController.eventImage.value);
      }
    } catch (_) {}
    if (widget.title.toLowerCase().contains("f1")) {
      return "assets/images/gameNight.png";
    }
    return "assets/images/gameNight.png";
  }
  
  // Google Maps API Key
  static String get _googleMapsApiKey => Env.googleMapsApiKey;
  
  // Generate Google Static Map URL with dark maroon and mustard theme
  String _generateStaticMapUrl(String address) {
    // URL encode the address for proper formatting
    String encodedAddress = Uri.encodeComponent(address);
    
    // Try a simpler approach first with basic styling
    return "https://maps.googleapis.com/maps/api/staticmap"
        "?center=$encodedAddress"
        "&zoom=16"
        "&size=240x240"
        "&maptype=roadmap"
        "&style=feature:all%7Celement:geometry%7Chue:0x8B0000%7Csaturation:100%7Clightness:30"
        "&style=feature:road%7Celement:geometry%7Chue:0xFFDB58%7Csaturation:100%7Clightness:50"
        "&style=feature:water%7Celement:geometry%7Chue:0x8B0000%7Csaturation:100%7Clightness:25"
        "&style=feature:landscape%7Celement:geometry%7Chue:0x654321%7Csaturation:100%7Clightness:20"
        "&markers=color:0xFFDB58%7Clabel:P%7C$encodedAddress"
        "&key=$_googleMapsApiKey";
  }
  
  // Alternative method with different styling approach
  String _generateStaticMapUrlAlternative(String address) {
    String encodedAddress = Uri.encodeComponent(address);
    
    return "https://maps.googleapis.com/maps/api/staticmap"
        "?center=$encodedAddress"
        "&zoom=16"
        "&size=240x240"
        "&maptype=roadmap"
        "&style=feature:all%7Cvisibility:on%7Chue:0x8B0000%7Csaturation:100%7Clightness:30"
        "&style=feature:road%7Chue:0xFFDB58%7Csaturation:100%7Clightness:50"
        "&style=feature:water%7Chue:0x8B0000%7Csaturation:100%7Clightness:25"
        "&style=feature:landscape%7Chue:0x654321%7Csaturation:100%7Clightness:20"
        "&markers=color:0xFFDB58%7Clabel:P%7C$encodedAddress"
        "&key=$_googleMapsApiKey";
  }
  
  // Third approach using RGB values
  String _generateStaticMapUrlRGB(String address) {
    String encodedAddress = Uri.encodeComponent(address);
    
    return "https://maps.googleapis.com/maps/api/staticmap"
        "?center=$encodedAddress"
        "&zoom=16"
        "&size=240x240"
        "&maptype=roadmap"
        "&style=feature:all%7Celement:geometry%7Chue:0x8B0000%7Csaturation:100%7Clightness:30"
        "&style=feature:road%7Celement:geometry%7Chue:0xFFDB58%7Csaturation:100%7Clightness:50"
        "&style=feature:water%7Celement:geometry%7Chue:0x8B0000%7Csaturation:100%7Clightness:25"
        "&style=feature:landscape%7Celement:geometry%7Chue:0x654321%7Csaturation:100%7Clightness:20"
        "&markers=color:0xFFDB58%7Clabel:P%7C$encodedAddress"
        "&key=$_googleMapsApiKey";
  }
  
  // Simple approach that should work - basic dark theme
  String _generateStaticMapUrlSimple(String address) {
    String encodedAddress = Uri.encodeComponent(address);
    
    return "https://maps.googleapis.com/maps/api/staticmap"
        "?center=$encodedAddress"
        "&zoom=16"
        "&size=240x240"
        "&maptype=roadmap"
        "&style=feature:all%7Celement:geometry%7Chue:0x8B0000%7Csaturation:100%7Clightness:30"
        "&style=feature:road%7Celement:geometry%7Chue:0xFFDB58%7Csaturation:100%7Clightness:50"
        "&style=feature:water%7Celement:geometry%7Chue:0x8B0000%7Csaturation:100%7Clightness:25"
        "&style=feature:landscape%7Celement:geometry%7Chue:0x654321%7Csaturation:100%7Clightness:20"
        "&markers=color:0xFFDB58%7Clabel:P%7C$encodedAddress"
        "&key=$_googleMapsApiKey";
  }
  
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            child: Column(
              children: [
                // Header with event image
                _buildHeader(screenHeight, screenWidth),

                // View Ticket button
                _buildViewTicketButton(),

                // Event details section
                _buildEventDetails(screenWidth),

                // Venue section
                _buildVenueSection(screenWidth),

                // About the event section
                _buildAboutEventSection(screenWidth),

                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),

          // Top navigation buttons - removed from here
        ],
      ),
    );
  }

  Widget _buildHeader(double screenHeight, double screenWidth) {
    return SizedBox(
      height: screenHeight * 0.5,
      width: double.infinity,
      child: Stack(
        children: [
         
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40), // ✅ curve bottom-left
                bottomRight: Radius.circular(40), // ✅ curve bottom-right
              ),
              child: SmartImage(
                imagePath: _resolveEventImage(),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
          ),

          // Top navigation buttons positioned over the image
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button with glassmorphism effect
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 10.0,
                        sigmaY: 10.0,
                      ),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(77, 7, 7, 7), // semi-transparent dark
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Image.asset(
                            "assets/images/arrowleft.png",
                            width: 20,
                            height: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Badge with glassmorphism effect (top right)
                if (widget.badgeText.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 10.0,
                        sigmaY: 10.0,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(77, 7, 7, 7), // more transparent
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (widget.starImagePath != null)
                              Image.asset(
                                widget.starImagePath!,
                                height: 24,
                                width: 24,
                              ),
                            if (widget.starImagePath != null)
                              const SizedBox(width: 5),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                widget.badgeText,
                                style: GoogleFonts.bricolageGrotesque(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Event title and details
          Positioned(
            bottom: 50,
            left: 40,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event title
                Text(
                  widget.title,
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),

                // Date and time
                Row(
                  children: [
                    
                    const SizedBox(width: 5),

                    // Date and time text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.date,
                            style: GoogleFonts.bricolageGrotesque(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            widget.time,
                            style: GoogleFonts.bricolageGrotesque(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Decorative line
              
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Confirm attendance for a FREE event after request acceptance
  /// This endpoint confirms attendance and generates ticket immediately
  /// CRITICAL: Only works for FREE events. Paid events must complete payment first.
  Future<void> _confirmAttendanceForFreeEvent() async {
    if (widget.eventId == null) {
      if (kDebugMode) {
        print('Event ID is null, cannot confirm attendance');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event ID not available'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Check if request is accepted
    if (requestStatus == null || requestStatus?.status != 'accepted') {
      if (kDebugMode) {
        print('Request not accepted yet. Status: ${requestStatus?.status}');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your request must be accepted before confirming attendance.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      isConfirmingAttendance = true;
    });

    try {
      if (kDebugMode) {
        print('Confirming attendance for FREE event ID: ${widget.eventId}');
      }

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );

      // Confirm attendance via API (seats = 1 by default)
      final ticketData = await _eventRequestService.confirmAttendance(
        eventId: widget.eventId!,
        seats: 1,
      );

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (kDebugMode) {
        print('Attendance confirmed successfully');
        print('Ticket ID: ${ticketData['ticket_id']}');
        print('Ticket Secret: ${ticketData['ticket_secret']}');
        print('Full ticket data: $ticketData');
      }

      // Update state
      setState(() {
        isConfirmingAttendance = false;
      });

      // Get ticket controller
      final ticketController = Get.put(UserTicketController());
      final eventController = Get.find<EventController>();

      // Extract ticket secret code from API response
      final ticketSecret = ticketData['ticket_secret']?.toString() ?? '';
      
      if (ticketSecret.isEmpty) {
        throw Exception('Ticket secret code not found in API response');
      }

      // Create ticket with data from API
      final ticket = UserTicket(
        title: widget.title,
        date: widget.date,
        location: widget.venue,
        code: ticketSecret, // Use secret code from API
        eventImage: widget.eventImage.isNotEmpty
            ? widget.eventImage
            : "assets/images/image (1).png",
      );

      // Add ticket to controller
      ticketController.addTicket(ticket);

      // If this ticket came from an invitation, mark the invite as accepted
      try {
        if (Get.isRegistered<HomePageController>()) {
          Get.find<HomePageController>()
              .updateInvitationStatusForEvent(widget.eventId!, 'accepted');
        }
      } catch (_) {}

      // Update event controller for consistency
      eventController.eventTitle.value = widget.title;
      eventController.loaction.value = widget.venue;
      eventController.date.value = widget.date;
      eventController.time.value = widget.time;
      eventController.eventImage.value = widget.eventImage;
      eventController.ticketPrice.value = "Free";
      if (widget.eventId != null) {
        eventController.eventId.value = widget.eventId!;
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance confirmed! Ticket generated. 🎉'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Navigate to TicketScreen (ticket_screen_zero.dart)
      if (mounted) {
        Get.to(() => TicketScreen());
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      setState(() {
        isConfirmingAttendance = false;
      });

      if (kDebugMode) {
        print('Error confirming attendance: $e');
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

  /// Send request to join the event via API
  Future<void> _sendEventRequest() async {
    // If there's already an invitation for this event, do not allow sending a request
    if (_eventInvitation != null) {
      if (kDebugMode) {
        print('User has an invitation for this event; blocking send request.');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You already have an invitation for this event. Use Going / Not Going instead.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    if (widget.eventId == null) {
      if (kDebugMode) {
        print('Event ID is null, cannot send request');
      }
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
      isSendingRequest = true;
    });

    try {
      if (kDebugMode) {
        print('Sending request for event ID: ${widget.eventId}');
      }

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );

      // Send the request
      final response = await _eventRequestService.sendEventRequest(
        eventId: widget.eventId!,
        message: "I would love to attend this event!",
        seatsRequested: 1,
      );

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (kDebugMode) {
        print('Event request sent successfully: ${response['id']}');
      }

      // Update state to show request was sent
      setState(() {
        isRequestSent = true;
        isSendingRequest = false;
      });

      // Refresh request status to get the latest status from API
      await _fetchRequestStatus();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request sent successfully! 🎉'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      setState(() {
        isSendingRequest = false;
      });

      if (kDebugMode) {
        print('Error sending event request: $e');
        print('Error type: ${e.runtimeType}');
      }

      // Extract meaningful error message
      String errorMessage = 'Failed to send request. Please try again.';
      
      // Handle ApiException properly
      if (e is ApiException) {
        errorMessage = e.message;
        if (e.statusCode == 408) {
          errorMessage = 'Request timed out. Please check your internet connection and try again.';
        }
      } else {
        // For other exceptions, try to extract message
        final errorString = e.toString();
        if (errorString.startsWith('ApiException: ')) {
          errorMessage = errorString.substring('ApiException: '.length);
        } else if (errorString.contains('timeout') || errorString.contains('Timeout')) {
          errorMessage = 'Request timed out. Please check your internet connection and try again.';
        }
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Widget _buildViewTicketButton() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Invitation awareness: if user has an invitation for this event,
    // we should not show "Send Request" and should mirror the invite states.
    final bool hasInvitation = _eventInvitation != null;
    final String invitationStatus =
        (_eventInvitation?.status ?? '').toLowerCase().trim();

    // Get request status from API response - handle different possible formats
    String requestStatusString = '';
    if (requestStatus != null) {
      final statusValue = requestStatus?.status;
      if (statusValue != null) {
        requestStatusString = statusValue.toString().trim().toLowerCase();
      }
    }
    
    final isRequestPending = requestStatusString == 'pending';
    final isRequestAccepted = requestStatusString == 'accepted';
    
    // Check can_confirm field from API response
    final canConfirm = requestStatus?.canConfirm ?? true;
    
    // Show "View Ticket" button when: status == "accepted" AND can_confirm == false
    final shouldShowViewTicket = isRequestAccepted && !canConfirm;
    
    if (kDebugMode) {
      print('=== EventDetail Button Status ===');
      print('  isLoadingRequestStatus: $isLoadingRequestStatus');
      print('  requestStatus object: $requestStatus');
      print('  requestStatusString: "$requestStatusString"');
      print('  isRequestPending: $isRequestPending');
      print('  isRequestAccepted: $isRequestAccepted');
      print('  canConfirm: $canConfirm');
      print('  shouldShowViewTicket: $shouldShowViewTicket');
      print('  isRequestSent: $isRequestSent');
      print('  isSendingRequest: $isSendingRequest');
    }
    
    // Handle invitation-based UI first
    if (hasInvitation) {
      // Pending invitation -> show Going / Not Going buttons (same layout as accepted request)
      if (invitationStatus == 'pending') {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            width: screenWidth - 16,
            child: Row(
              children: [
                Expanded(
                  child: LoopinCtaButton(
                    width: double.infinity,
                    label: widget.price != null
                        ? "Going! ₹${widget.price}"
                        : "Going!",
                    onPressed: () {
                      // For paid events: go to payment; for free: confirm attendance.
                      if (widget.price != null) {
                        final eventController = Get.find<EventController>();
                        eventController.eventTitle.value = widget.title;
                        eventController.loaction.value = widget.venue;
                        eventController.date.value = widget.date;
                        eventController.time.value = widget.time;
                        eventController.eventImage.value = widget.eventImage;
                        eventController.ticketPrice.value =
                            widget.price!.replaceAll('₹', '').trim();
                        if (widget.eventId != null) {
                          eventController.eventId.value = widget.eventId!;
                        }
                        Get.to(() => TicketPriceScreen());
                      } else {
                        _confirmAttendanceForFreeEvent();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LoopinCtaButton(
                    width: double.infinity,
                    label: "Not Going",
                    backgroundColor: Colors.transparent,
                    borderColor: Colors.white.withOpacity(0.35),
                    borderWidth: 1.0,
                    textColor: Colors.white,
                    onPressed: () {
                      final eventController = Get.find<EventController>();
                      eventController.eventTitle.value = widget.title;
                      eventController.loaction.value = widget.venue;
                      eventController.date.value = widget.date;
                      eventController.time.value = widget.time;
                      eventController.eventImage.value = widget.eventImage;
                      eventController.ticketPrice.value = "Free";
                      Get.to(() => TicketScreen());
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Accepted/going invitation -> show View Ticket
      if (invitationStatus == 'accepted' || invitationStatus == 'going') {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            width: screenWidth - 16,
            child: LoopinCtaButton(
              width: double.infinity,
              label: "View Ticket",
              onPressed: () {
                if (kDebugMode) {
                  print('View Ticket - navigating to home with ticket tab');
                }
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeWithTabs(initialTab: 1),
                  ),
                );
              },
            ),
          ),
        );
      }

      // Declined / expired invitation -> show a disabled status pill, no actions
      String message = "Invite status: $invitationStatus";
      if (invitationStatus == 'declined') {
        message = "You declined this invite";
      } else if (invitationStatus == 'expired') {
        message = "Deadline Has Passed";
      }

      return Padding(
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          width: screenWidth - 16,
          child: LoopinCtaButton(
            width: double.infinity,
            label: message,
            onPressed: null,
            backgroundColor: Colors.grey.shade800,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        width: screenWidth - 16, // Full width minus padding (8*2)
        child: isLoadingRequestStatus
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : shouldShowViewTicket
          ? LoopinCtaButton(
              width: double.infinity,
              label: "View Ticket",
              onPressed: () {
                if (kDebugMode) {
                  print('View Ticket - navigating to home with ticket tab');
                }
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeWithTabs(initialTab: 1),
                  ),
                );
              },
            )
          : isRequestAccepted && canConfirm
          ? Row(
              children: [
                Expanded(
                  child: LoopinCtaButton(
                    width: double.infinity,
                    label: isConfirmingAttendance 
                        ? "Confirming..." 
                        : (widget.price != null ? "Going! ₹${widget.price}" : "Going!"),
                    onPressed: isConfirmingAttendance ? null : () {
                      // For paid events, navigate to payment flow
                      if (widget.price != null) {
                      final eventController = Get.find<EventController>();
                      eventController.eventTitle.value = widget.title;
                      eventController.loaction.value = widget.venue;
                      eventController.date.value = widget.date;
                      eventController.time.value = widget.time;
                      eventController.eventImage.value = widget.eventImage;
                        eventController.ticketPrice.value =
                            widget.price!.replaceAll('₹', '').trim();
                        if (widget.eventId != null) {
                          eventController.eventId.value = widget.eventId!;
                        }
                        Get.to(() => TicketPriceScreen());
                      } else {
                        // For FREE events: Confirm attendance via API
                        _confirmAttendanceForFreeEvent();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LoopinCtaButton(
                    width: double.infinity,
                    label: "Not Going",
                    backgroundColor: Colors.transparent,
                    borderColor: Colors.white.withOpacity(0.35),
                    borderWidth: 1.0,
                    textColor: Colors.white,
                    onPressed: () {
                      final eventController = Get.find<EventController>();
                      eventController.eventTitle.value = widget.title;
                      eventController.loaction.value = widget.venue;
                      eventController.date.value = widget.date;
                      eventController.time.value = widget.time;
                      eventController.eventImage.value = widget.eventImage;
                      eventController.ticketPrice.value = "Free";
                      Get.to(() => TicketScreen());
                    },
                  ),
                ),
              ],
            )
          : LoopinCtaButton(
              width: double.infinity,
              label: isRequestPending
                  ? "Requested to join"
                  : (isSendingRequest ? "Sending..." : "Send Request"),
              backgroundColor: isRequestPending ? const Color(0xFFB78EF5) : null,
              onPressed: () {
                // If pending, button is just for display (shows status)
                // If sending, don't allow multiple clicks
                if (isSendingRequest) return;
                
                // If pending, do nothing (button shows status but doesn't need action)
                if (isRequestPending) {
                  if (kDebugMode) {
                    print('Request is pending - button is for display only');
                  }
                  return;
                }
                
                // Otherwise, send the request
                _sendEventRequest();
              },
            ),
      ),
    );
  }

  Widget _buildEventDetails(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[900]?.withOpacity(0.3),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Hosted By section (unchanged) ---
            Container(
              padding: const EdgeInsets.all(5),
              child: _buildInfoRow(
                "Hosted By",
                Container(
                  width: 148,
                  height: 40,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromRGBO(205, 191, 182, 0.10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundImage: const AssetImage('assets/images/host.png'),
                        onBackgroundImageError: (exception, stackTrace) {},
                        child: Image.asset('assets/images/host.png', fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          widget.hostName,
                          style: GoogleFonts.bricolageGrotesque(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- Separator Line ---
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 2),
              child: Divider(color: Colors.white24, thickness: 1, height: 1),
            ),

            Container(
              padding: const EdgeInsets.all(3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "People Going (24 People)",
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  // Avatar image - enlarged and shifted left to fit in container
                  Transform.translate(
                    offset: const Offset(-20, 0), // Shift left to fit in container
                    child: Transform.scale(
                      scale: 2, // make it larger
                      
                    ),
                  ),
                ],
              ),
            ),

          ]
        ),
      ),
    );
  }


Widget _buildVenueSection(double screenWidth) {
  return Padding(
    padding: const EdgeInsets.all(8),
    child: Container(
   width: 358,
  height: 166,   
  decoration: BoxDecoration(
    color: const Color(0xFF0D0D0D),  // background color
    borderRadius: BorderRadius.circular(28), // border radius
    border: Border.all(
      color: const Color.fromRGBO(43, 43, 43, 0.5), // border color with opacity
      width: 2,
    ),
  ),


      // inner padding to give the purple border feel
      padding: const EdgeInsets.all(5),
      child: Container(
        height: 170,
        // inner card (semi transparent white overlay)
       
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map image box - made larger and rounded
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.09),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
         
              child: ClipRRect(
  borderRadius: BorderRadius.circular(16),
  child: Image.network(
    resolveImageUrl(_generateStaticMapUrlSimple(widget.fullAddress)),
    width: 120,
    height: 120,
    fit: BoxFit.cover,
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) return child;
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Color(0xFF5B2333),  // dark maroon with opacity
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
            color: Color(0xFFD4A017),  // mustard color
          ),
        ),
      );
    },
    errorBuilder: (context, error, stackTrace) {
      print('Map loading error: $error');
      print('Stack trace: $stackTrace');
      print('Map URL: ${_generateStaticMapUrlSimple(widget.fullAddress)}');
      // fallback
      return Container(
        decoration: BoxDecoration(
          color: Color(0xFF5B2333),  // dark maroon with opacity
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.location_on,
          color: Color(0xFFD4A017),  // mustard color
          size: 36,
        ),
      );
    },
  ),
),

            ),

            const SizedBox(width: 20),

            // Venue info (title, address, button)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    "Venue",
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Address text
                  Text(
                    widget.fullAddress,
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 12,
                      color: Colors.white70,
                      
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Get direction button aligned under the address
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () async {
                        final Uri url = Uri.parse(
                          'https://maps.google.com/?q=${Uri.encodeComponent(widget.fullAddress)}',
                        );
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                      child: Container(
  width: 120,
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
  decoration: BoxDecoration(
    color: const Color(0xFFB78EF5), // background color
    borderRadius: BorderRadius.circular(10), // updated radius
    border: Border.all(
      color: const Color.fromRGBO(255, 255, 255, 0.30), // updated border
      width: 0.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.45),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
      BoxShadow(
        color: Colors.white.withOpacity(0.03),
        blurRadius: 0,
        spreadRadius: 0,
      ),
    ],
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.send, size: 14, color: Colors.white),
      const SizedBox(width: 5),
      Text(
        'Get direction',
        style: GoogleFonts.bricolageGrotesque(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    ],
  ),
),

                    ),
                  ),
                ],
              ),
            ),

            // optional right spacing (keeps layout balanced)
        
          ],
        ),
      ),
    ),
  );
}

  Widget _buildAboutEventSection(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        width: 358,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900]?.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "About the event",
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              widget.aboutEvent,
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 14,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildInfoRow(String label, Widget content) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.bricolageGrotesque(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        content,
      ],
    );
  }
}
