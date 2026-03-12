// ignore_for_file: deprecated_member_use, avoid_print, unused_import

import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:text_code/Home_pages/Controller/home_page.dart';
import 'package:text_code/core/models/event.dart';
import 'package:text_code/Reusable/eventcard.dart';
import 'package:text_code/Reusable/smart_image.dart';
import 'package:text_code/Home_pages/Ticket_Pages_navigation/ticket_navigation_going/ticket_screen_zero.dart';
import 'package:text_code/Host_Pages/Controller_files/capicity_cntoller.dart';
import 'package:text_code/Host_Pages/Controller_files/event_cntroller.dart';
import 'package:text_code/Reusable/text_Bricolage%20Grotesque_reusable.dart';
import 'package:text_code/Reusable/navigation_bar.dart';
import 'package:text_code/Reusable/loopin_cta_button.dart';
import 'package:text_code/Home_pages/UI_Design/eventdetail.dart';
import 'package:text_code/HostManagement/mainScreen.dart';
import 'package:text_code/core/services/event_request_service_host.dart';
import 'package:text_code/core/utils/jwt_utils.dart';
import 'package:text_code/core/services/secure_storage_service.dart';
import 'package:text_code/login-signup/sign_up/booked_ticket.dart';
import 'package:text_code/core/utils/image_url_helper.dart';
import 'package:text_code/Home_pages/Controller/ticket_controller.dart';
import 'package:text_code/core/models/event_invitation.dart';
import 'package:text_code/core/services/event_invitation_service.dart';
import 'package:text_code/core/network/api_exception.dart';
import 'package:text_code/core/services/ticket_service.dart';

class HomePages extends StatefulWidget {
  const HomePages({super.key, this.showTabs = true, this.tabIndex, this.onTabChanged});

  final bool showTabs;
  final int? tabIndex;
  final Function(int)? onTabChanged;

  @override
  State<HomePages> createState() => _HomePagesState();
}

class _HomePagesState extends State<HomePages> {
  final CityController cityController = Get.put(CityController());
  final EventCardsController controller1 = Get.put(EventCardsController());
  final EventCardImageController controllerbut = Get.put(
    EventCardImageController(),
  );
  final eventController = Get.put(EventController());
  final HomePageController homePageController = Get.put(HomePageController());
  final UserTicketController userTicketController = Get.put(UserTicketController());

  final CapacityController capacityController = Get.put(CapacityController());
  final SecureStorageService _secureStorage = SecureStorageService();
  final EventRequestService _eventRequestService = EventRequestService();
  final TicketService _ticketService = TicketService();
  int? _currentUserId;
  int selectedIndex = 0;
  
  // Cache for request statuses: eventId -> status
  final Map<int, String?> _requestStatusCache = {};

  /// Extract event ID from my-tickets item (flat or nested under event).
  int? _eventIdFromTicketData(Map<String, dynamic> ticketData) {
    final id = ticketData['event_id'];
    if (id != null) {
      if (id is int) return id;
      final parsed = int.tryParse(id.toString());
      if (parsed != null) return parsed;
    }
    final event = ticketData['event'];
    if (event is Map<String, dynamic>) {
      final eid = event['id'];
      if (eid != null) {
        if (eid is int) return eid;
        final parsed = int.tryParse(eid.toString());
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  /// Prefetch user's tickets from "my-tickets" API so Home page can
  /// mark events as "You're going" when a ticket exists.
  Future<void> _prefetchUserTickets() async {
    try {
      if (kDebugMode) {
        print('Prefetching user tickets for Home page...');
      }

      final ticketsData = await _ticketService.getAllUserTickets();

      if (kDebugMode) {
        print('Prefetched ${ticketsData.length} tickets');
      }

      // Clear existing tickets before inserting fresh ones
      userTicketController.tickets.clear();

      for (final ticketData in ticketsData) {
        if (ticketData is! Map<String, dynamic>) continue;
        final eventId = _eventIdFromTicketData(ticketData);
        if (eventId == null) continue;

        // We only need eventId here to drive "You're going" state on Home.
        // Other fields are left empty; BookedTicket screen will refetch
        // and populate full ticket details when user opens My tickets.
        final ticket = UserTicket(
          title: '',
          date: '',
          location: '',
          code: '',
          eventImage: '',
          eventId: eventId,
        );
        userTicketController.addTicket(ticket);
      }

      if (kDebugMode) {
        print('Home page ticket prefetch completed. Tickets in controller: ${userTicketController.tickets.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error prefetching tickets for Home page: $e');
      }
      // Silent fail is fine here; Home page will just not show "You\'re going"
      // until tickets are fetched elsewhere.
    }
  }
  
  void imageTap() {
    print("Image tapped!");
  }
  
  /// Fetch request status for an event and cache it
  Future<String?> _getRequestStatus(int eventId) async {
    // Check cache first
    if (_requestStatusCache.containsKey(eventId)) {
      return _requestStatusCache[eventId];
    }
    
    try {
      final request = await _eventRequestService.getUserRequestStatus(eventId);
      final status = request?.status;
      _requestStatusCache[eventId] = status;
      return status;
    } catch (e) {
      _requestStatusCache[eventId] = null;
      return null;
    }
  }

  /// Check if there is a ticket for this event in the user's tickets
  bool _hasTicketForEvent(int eventId) {
    try {
      return userTicketController.tickets
          .any((ticket) => ticket.eventId != null && ticket.eventId == eventId);
    } catch (_) {
      return false;
    }
  }

  /// Share event using share_plus
  Future<void> _shareEvent(Event event) async {
    try {
      // Show loading indicator
      if (kDebugMode) {
        print('Fetching share URL for event: ${event.title}');
      }

      // Get the share URL from API
      final shareUrl = await _eventRequestService.getEventShareUrl(event.id);
      
      if (kDebugMode) {
        print('Share URL: $shareUrl');
      }

      // Share using native share dialog
      await Share.share(
        'Check out this event on Loop In: ${event.title}\n\n$shareUrl',
        subject: event.title,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error sharing event: $e');
      }
      
      // If getting URL fails, just share the basic event info
      await Share.share(
        'Check out this event on Loop In: ${event.title}',
        subject: event.title,
      );
    }
  }

  /// Get current user ID from token
  Future<int?> _getCurrentUserId() async {
    if (_currentUserId != null) {
      if (kDebugMode) {
        print('_getCurrentUserId: returning cached value: $_currentUserId');
      }
      return _currentUserId;
    }
    
    try {
      final token = await _secureStorage.getToken();
      if (kDebugMode) {
        print('_getCurrentUserId: token exists: ${token != null}');
      }
      if (token != null) {
        _currentUserId = JwtUtils.getUserId(token);
        if (kDebugMode) {
          print('_getCurrentUserId: extracted user ID: $_currentUserId');
        }
        return _currentUserId;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current user ID: $e');
      }
    }
    if (kDebugMode) {
      print('_getCurrentUserId: returning null');
    }
    return null;
  }

  /// Check if current user is hosting the event (using both ID and phone number)
  bool _isUserHostingEvent(Event event, int? currentUserId, String? currentUserPhoneNumber) {
    if (kDebugMode) {
      print('_isUserHostingEvent check for ${event.title}:');
      print('  Event Host Profile ID: ${event.host.id}');
      print('  Event Host User ID: ${event.host.userId}, Current User ID: $currentUserId');
      print('  Event Host Phone: "${event.host.phoneNumber}", Current User Phone: "$currentUserPhoneNumber"');
    }
    
    // Primary check: Match by user ID (most reliable)
    // Compare with host.user_id, not host.id
    if (currentUserId != null && event.host.userId == currentUserId) {
      if (kDebugMode) {
        print('  -> Match by User ID: TRUE (User is hosting this event)');
      }
      return true;
    }
    
    // Fallback: If ID doesn't match, try matching by phone number
    if (currentUserPhoneNumber != null && 
        currentUserPhoneNumber.isNotEmpty && 
        event.host.phoneNumber.isNotEmpty) {
      
      // Normalize phone numbers for comparison (remove spaces, dashes, etc.)
      final normalizedCurrentPhone = currentUserPhoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
      final normalizedHostPhone = event.host.phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
      
      if (kDebugMode) {
        print('  -> Normalized Current: "$normalizedCurrentPhone", Host: "$normalizedHostPhone"');
      }
      
      if (normalizedCurrentPhone == normalizedHostPhone) {
        if (kDebugMode) {
          print('  -> Match by Phone: TRUE (User is hosting this event)');
        }
        return true;
      }
    }
    
    if (kDebugMode) {
      print('  -> No Match: FALSE (User is NOT hosting this event)');
    }
    return false;
  }

  /// Get current user phone number from token
  Future<String?> _getCurrentUserPhoneNumber() async {
    try {
      final token = await _secureStorage.getToken();
      if (kDebugMode) {
        print('_getCurrentUserPhoneNumber: token exists: ${token != null}');
      }
      if (token != null) {
        final phoneNumber = JwtUtils.getPhoneNumber(token);
        if (kDebugMode) {
          print('_getCurrentUserPhoneNumber: extracted phone: "$phoneNumber"');
        }
        return phoneNumber;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current user phone number: $e');
      }
    }
    if (kDebugMode) {
      print('_getCurrentUserPhoneNumber: returning null');
    }
    return null;
  }

  /// Check if current user is hosting the event
  Future<bool> _isUserHosting(Event event) async {
    final userId = await _getCurrentUserId();
    if (userId == null) return false;
    return event.host.id == userId;
  }

  // Helper method to get date 48 hours before today
  String _getDate48HoursBefore() {
    final now = DateTime.now();
    final date48HoursBefore = now.subtract(const Duration(hours: 48));
    return DateFormat('d MMM yy').format(date48HoursBefore);
  }

  /// Send request to join an event
  Future<void> _sendEventRequest(Event event, BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );

      if (kDebugMode) {
        print('Sending request for event ID: ${event.id}');
      }

      // Send the request
      final response = await _eventRequestService.sendEventRequest(
        eventId: event.id,
        message: "I would love to attend this event!",
        seatsRequested: 1,
      );

      // Close loading dialog
      if (context.mounted) Navigator.of(context).pop();

      if (kDebugMode) {
        print('Event request sent successfully: ${response['id']}');
      }

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request sent successfully! 🎉'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }

      // Refresh events to update UI
      homePageController.refreshEvents();

    } catch (e) {
      // Close loading dialog
      if (context.mounted) Navigator.of(context).pop();

      if (kDebugMode) {
        print('Error sending event request: $e');
        print('Error type: ${e.runtimeType}');
      }

      // Extract meaningful error message
      String errorMessage = e.toString();
      
      // Remove "ApiException: " prefix if present
      if (errorMessage.startsWith('ApiException: ')) {
        errorMessage = errorMessage.substring('ApiException: '.length);
      }

      // Show error message
      if (context.mounted) {
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
  void initState() {
    super.initState();
    // Listen to ticketPriceController changes to update guestPays
    capacityController.ticketPriceController.addListener(() {
      capacityController.guestPays.value =
          double.tryParse(capacityController.ticketPriceController.text) ?? 0.0;
    });

    // On app/home open, prefetch "my-tickets" so events with tickets
    // can immediately show the "You're Going!" state on the Home page.
    _prefetchUserTickets();
  }

  /// Helper function to build image from network URL or asset
  Widget buildImage(String image) {
    return SmartImage(
      imagePath: image,
      fit: BoxFit.cover,
    );
  }

  /// Format date location string from event
  /// Format: "7 Jun 25, Bastian garden city"
  String _formatDateLocation(String startTime, String locationName) {
    if (startTime.isEmpty) return locationName;
    try {
      final dateTime = DateTime.parse(startTime);
      // Format: "7 Jun 25" (day without leading zero, abbreviated month, 2-digit year)
      final day = dateTime.day; // No leading zero
      final month = DateFormat('MMM').format(dateTime); // Abbreviated month
      final year = dateTime.year.toString().substring(2); // Last 2 digits
      final formattedDate = '$day $month $year';
      return '$formattedDate, $locationName';
    } catch (e) {
      return locationName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
            children: [
              Obx(
                () => InkWell(
                  onTap: () => _showCityTopSheet(context),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Location Icon in Circle
                        Container(
                          decoration: BoxDecoration(shape: BoxShape.circle),
                          padding: const EdgeInsets.all(6),
                          child: Image.asset(
                            "assets/icons/Frame 81.png",
                            height: 40,
                            width: 40,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Text
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pick your scene",
                              style: const TextStyle(
                                fontFamily: 'ClashDisplay',
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w400, // Regular
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              cityController.selectedCity.value,
                              style: const TextStyle(
                                fontFamily: 'ClashDisplay',
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500, // Medium
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (widget.showTabs) ...[
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Row(
                    children: [
                      buildTabButton(0, "Discover"),
                      const SizedBox(width: 10),
                      buildTabButton(1, "My tickets"),
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ] else if (widget.tabIndex != null && widget.onTabChanged != null) ...[
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Row(
                    children: [
                      _buildTabButton(0, "Discover"),
                      const SizedBox(width: 10),
                      _buildTabButton(1, "Ticket"),
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ] else
                SizedBox(height: 20),
              // Display events from API
              Obx(() {
                if (homePageController.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  );
                }

                if (homePageController.errorMessage.value != null) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            homePageController.errorMessage.value!,
                            style: GoogleFonts.bricolageGrotesque(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => homePageController.refreshEvents(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (homePageController.events.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Center(
                      child: Text(
                        'No events available',
                        style: GoogleFonts.bricolageGrotesque(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }

                return FutureBuilder<Map<String, dynamic>>(
                  future: Future.wait([
                    _getCurrentUserId(),
                    _getCurrentUserPhoneNumber(),
                  ]).then((results) => {
                    'userId': results[0],
                    'phoneNumber': results[1],
                  }),
                  builder: (context, snapshot) {
                    if (kDebugMode) {
                      print('FutureBuilder snapshot: ${snapshot.connectionState}');
                      print('Snapshot data: ${snapshot.data}');
                      print('Snapshot error: ${snapshot.error}');
                    }
                    
                    // Show loading while waiting for user data
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }
                    
                    final currentUserId = snapshot.data?['userId'] as int?;
                    final currentUserPhoneNumber = snapshot.data?['phoneNumber'] as String?;
                    
                    if (kDebugMode) {
                      print('Current User - ID: $currentUserId, Phone: "$currentUserPhoneNumber"');
                    }
                    
                    // Filter events based on invitation status:
                    // - Show events with invitation status "accepted" or "pending"
                    // - Hide events with invitation status "declined"
                    // - Show all events that don't have an invitation
                    final allEvents = List<Event>.from(homePageController.events);
                    final filteredEvents = allEvents.where((event) {
                      // Check if this event has an invitation
                      for (final invitation in homePageController.invitations) {
                        if (invitation.eventId == event.id) {
                          final invStatus = invitation.status.toLowerCase();
                          // Only show if status is "accepted" or "pending" or "expired", hide "declined"
                          return invStatus == 'accepted' || invStatus == 'pending' || invStatus == 'expired';
                        }
                      }
                      // Show events without invitations (normal events)
                      return true;
                    }).toList();
                    
                    // Sort filtered events: User's hosted events first (by latest ID), then others by latest event ID
                    filteredEvents.sort((a, b) {
                      final aIsHost = _isUserHostingEvent(a, currentUserId, currentUserPhoneNumber);
                      final bIsHost = _isUserHostingEvent(b, currentUserId, currentUserPhoneNumber);
                      
                      // If one is hosted by user and other is not, prioritize hosted
                      if (aIsHost && !bIsHost) return -1;
                      if (!aIsHost && bIsHost) return 1;
                      
                      // Both are hosted by user - sort by latest event ID first (highest ID = latest)
                      if (aIsHost && bIsHost) {
                        return b.id.compareTo(a.id); // Latest ID first
                      }
                      
                      // Both are NOT hosted by user - sort by latest event ID
                      return b.id.compareTo(a.id); // Latest event ID first
                    });
                    
                    return Column(
                      children: filteredEvents.map((event) {
                        return FutureBuilder<String?>(
                          future: _getRequestStatus(event.id),
                          builder: (context, requestStatusSnapshot) {
                            return _buildEventCard(
                              event,
                              currentUserId,
                              currentUserPhoneNumber,
                              requestStatusSnapshot.data,
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                );
              }),
              SizedBox(height: 60),
            ],
          ),
    );

    if (widget.showTabs) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: content,
        ),
      );
    } else {
      return content;
    }
  }

  /// Build event card with request status button
  Widget _buildEventCard(
    Event event,
    int? currentUserId,
    String? currentUserPhoneNumber,
    String? requestStatus,
  ) {
    // Check if current user is hosting this event
    final bool isUserHost =
        _isUserHostingEvent(event, currentUserId, currentUserPhoneNumber);

    // Normalized status string from API (e.g. 'pending', 'expired', 'accepted').
    // Prefer status from /api/events/my-invitations when available so home
    // page cards mirror invitation states (pending, expired, etc.).
    String statusLower = event.status.toLowerCase();
    for (final invitation in homePageController.invitations) {
      if (invitation.eventId == event.id) {
        statusLower = invitation.status.toLowerCase();
        break;
      }
    }

    // Determine base state flags for this event and user
    final bool hasEnded = event.hasEnded;
    final bool isExpired = statusLower == 'expired';
    // Treat expired invitations as ended for UI/interaction purposes
    final bool isEnded = hasEnded || isExpired;

    // Check if user is already marked as going/attending.
    // IMPORTANT: do NOT treat plain "accepted" as going – user still needs
    // to confirm attendance from the event detail page.
    // However, if a ticket exists for this event in the user's ticket list,
    // always treat it as a "going" state.
    final bool hasTicket = _hasTicketForEvent(event.id);
    final bool isGoingState =
        hasTicket ||
        statusLower.contains('going') ||
        statusLower.contains('attending');

    // Only treat explicit going/attending as "ticket generated" state.
    final bool isAttendingEvent =
        !isEnded && isGoingState && !isUserHost;

    // Check if this event has an invitation (from my-invitations API)
    EventInvitation? matchingInvitation;
    for (final invitation in homePageController.invitations) {
      if (invitation.eventId == event.id) {
        matchingInvitation = invitation;
        break;
      }
    }
    
    final bool hasInvitation = matchingInvitation != null;
    final String invitationStatus = matchingInvitation?.status.toLowerCase() ?? '';
    
    // Normalized request status from event-requests API (for non-invited events)
    final String requestStatusLower = (requestStatus ?? '').toLowerCase();
    final bool isRequestPending = requestStatusLower == 'pending';
    final bool isRequestAccepted = requestStatusLower == 'accepted';
    
    // Pending or accepted invitation from "my invitations" API
    final bool isInvitationEvent = hasInvitation && 
        (invitationStatus == 'pending' || invitationStatus == 'accepted') &&
        !isEnded && 
        !isUserHost && 
        !isAttendingEvent;

    // Accepted normal request (no invitation) – user still needs to confirm
    // attendance from the event detail page. On the Home page we should show
    // "New Event" badge with Going / Not Going buttons until a ticket exists.
    final bool isAcceptedRequestEvent = !hasInvitation &&
        !isEnded &&
        !isUserHost &&
        !isAttendingEvent &&
        isRequestAccepted;

    // Determine badge text based on original event status
    String badgeText;
    if (isExpired) {
      // Invitation deadline has passed
      badgeText = "Deadline Has Passed";
    } else if (isUserHost && !hasEnded) {
      // Host's own upcoming / live event
      badgeText = "Your Event is Live!";
    } else if (isInvitationEvent) {
      // New invite from /my-invitations API (both pending and accepted show "New Invite")
      badgeText = "New Invite";
    } else if (!hasEnded && isAttendingEvent) {
      // Events where the user's ticket has been generated / they are going
      badgeText = "You're Going!";
    } else if (hasEnded) {
      badgeText = "Event Has Ended";
    } else {
      badgeText = "New Event";
    }

    // Two-button layout (Going / Not Going) is shown for:
    // - Invitation events (pending or accepted)
    // - Normal events where the join request is accepted but ticket is not yet generated
    final bool shouldShowTwoButtons = isInvitationEvent || isAcceptedRequestEvent;
    
    // Compute star/badge icon once so Home page and EventDetail use the same icon
    final String starImagePath = isExpired
        ? "assets/icons/Group 1 (4).png" // Deadline Has Passed
        : hasEnded
            ? "assets/icons/Group 1 (3).png" // Event ended
            : isInvitationEvent
                ? "assets/icons/Group 1 (6).png" // New invite
                : isAttendingEvent
                    ? "assets/icons/Group 1 (5).png" // You're Going
                    : "assets/icons/Group 1 (2).png"; // Default "New event"

    // Get cover images or use placeholder
    final List<String> imageUrls = event.coverImages.isNotEmpty
        ? event.coverImages.map((url) => imageUrl(url)).toList()
        : ["assets/images/image (2).png"];
    
    // Format date and location
    final String dateLocation = _formatDateLocation(
      event.startTime,
      event.location.name,
    );
    
    // Format time for EventDetail
    String formattedTime = event.formattedTime;
    if (formattedTime.isEmpty) {
      formattedTime = "TBD";
    } else {
      formattedTime = "$formattedTime onwards";
    }

    // Determine button text based on request status
    String buttonText = "Send Request";
    if (isUserHost) {
      buttonText = "View Request";
    } else if (isRequestPending) {
      // Change button to show "Requested to join" when request is pending
      buttonText = "Requested to join";
    } else if (isAttendingEvent) {
      // For going events, show "View ticket"
      buttonText = "View ticket";
    }

    return InviteEventCard(
      badgeText: badgeText,
      imageUrls: imageUrls,
      title: event.title,
      dateLocation: dateLocation,
      hostName: event.host.name,
      status: isUserHost
          ? EventStatus.hostedByCurrentUser
          : isAttendingEvent
              ? EventStatus.attending
              : isEnded
                  ? EventStatus.ended
                  : EventStatus.newEvent,
      // Badge icons:
      // - Deadline Has Passed: Group 1 (4)
      // - Event ended (non-expired): Group 1 (3)
      // - New invite: Group 1 (6)
      // - Going (ticket generated): Group 1 (5)
      // - Default / New event: Group 1 (2)
      starImagePath: starImagePath,
      isEnded: isEnded,
      imagePath: isEnded ? '' : 'assets/images/button/Frame 19976 (4).png',
      // For expired invites (treated as ended), hide CTA button.
      buttonLabel: isEnded ? null : buttonText,
      buttonVariant: LoopinButtonVariant.primary,
      showButton: !isEnded,
      showTwoButtons: shouldShowTwoButtons,
      // Use same CTA style for "View request" and "View ticket" (no icon inside).
      isViewTicketButton: false,
      // For expired invitations, hide price tag
      isPaid: isExpired ? false : event.isPaid,
      price: isExpired 
          ? null 
          : (event.isPaid && event.ticketPrice != null ? event.ticketPrice : null),
      // Hide share icon for expired invitations
      onUploadTap: isExpired ? null : () {
        _shareEvent(event);
      },
      onTap: () {
        if (isEnded) {
          return;
        }
        
        if (isUserHost) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MainScreen(
                eventName: event.title,
                eventPrice: event.isPaid && event.ticketPrice != null
                    ? "₹ ${event.ticketPrice}"
                    : "Free",
                confirmedUsers: event.goingCount,
                invitedCount: 0,
                requestsCount: event.requestsCount,
                checkInCount: 0,
                eventId: event.id,
                eventStatus: event.status,
                payoutStatus: event.payoutStatus,
              ),
            ),
          );
        } else if (isAttendingEvent) {
          // For going events, open the tickets screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BookedTicket(
                showTabs: true,
              ),
            ),
          );
        } else {
          // Navigate to event detail to view the pending request or event details
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetail(
                eventId: event.id,
                title: event.title,
                date: event.startTime,
                time: event.formattedTime,
                hostName: event.host.name,
                hostImage: event.host.profileImage ?? 'assets/images/avatar.png',
                eventImage: event.coverImages.isNotEmpty ? event.coverImages[0] : 'assets/images/image (2).png',
                venue: event.location.name,
                fullAddress: event.location.address,
                aboutEvent: event.description.isNotEmpty ? event.description : 'Event details coming soon',
                badgeText: badgeText,
                starImagePath: starImagePath,
                attendeesCount: event.goingCount,
                attendeeImages: [],
                // Mark as "going" on detail page only when the user is
                // actually in a going/attending state, not just accepted.
                isGoing: isAttendingEvent,
                price: event.isPaid && event.ticketPrice != null ? event.ticketPrice : null,
              ),
            ),
          );
        }
      },
      onFirstButtonTap: () {
        // "Going" button - Navigate to EventDetail page
        // EventDetail will call confirm-attendance API which accepts invitation if pending
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetail(
              eventId: event.id,
              title: event.title,
              date: event.startTime,
              time: event.formattedTime,
              hostName: event.host.name,
              hostImage: event.host.profileImage ?? 'assets/images/avatar.png',
              eventImage: event.coverImages.isNotEmpty ? event.coverImages[0] : 'assets/images/image (2).png',
              venue: event.location.name,
              fullAddress: event.location.address,
              aboutEvent: event.description.isNotEmpty ? event.description : 'Event details coming soon',
              badgeText: badgeText,
              starImagePath: starImagePath,
              attendeesCount: event.goingCount,
              attendeeImages: [],
              isGoing: false,
              price: event.isPaid && event.ticketPrice != null ? event.ticketPrice : null,
            ),
          ),
        );
      },
      onSecondButtonTap: () async {
        // "Not Going" button - Decline invitation
        if (matchingInvitation == null) {
          if (kDebugMode) {
            print('No invitation found for event ${event.id}');
          }
          return;
        }

        try {
          if (kDebugMode) {
            print('Declining invitation ${matchingInvitation!.inviteId} for event ${event.id}');
          }

          // Show loading dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );

          // Decline invitation via API
          final EventInvitationService invitationService = EventInvitationService();
          await invitationService.respondToInvitation(
            inviteId: matchingInvitation!.inviteId,
            response: 'declined',
            message: 'I cannot attend this event.',
          );

          // Close loading dialog
          if (context.mounted) Navigator.of(context).pop();

          // Remove invitation from local list (this will hide the event from Home Page)
          homePageController.invitations.removeWhere(
            (inv) => inv.inviteId == matchingInvitation!.inviteId,
          );

          // Refresh events to update UI
          homePageController.refreshEvents();

          if (kDebugMode) {
            print('Invitation declined successfully');
          }

          // Show success message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invitation declined'),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          // Close loading dialog
          if (context.mounted) Navigator.of(context).pop();

          if (kDebugMode) {
            print('Error declining invitation: $e');
          }

          // Extract meaningful error message
          String errorMessage = 'Failed to decline invitation. Please try again.';
          
          if (e is ApiException) {
            errorMessage = e.message;
          } else {
            final errorString = e.toString();
            if (errorString.startsWith('ApiException: ')) {
              errorMessage = errorString.substring('ApiException: '.length);
            }
          }

          // Show error message
          if (context.mounted) {
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
      },
    );
  }

  Widget buildTabButton(int index, String label) {
    final bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
        if (label == "My tickets" && widget.showTabs) {
          // Switch to bottom bar's My tickets tab
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const BottomBar(initialIndex: 1)),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(
            color: Colors.grey, // border color
            width: 1, // border thickness
          ),
        ),

        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'ClashDisplay',
            fontSize: 14,
            fontWeight: FontWeight.w400, // Regular
            fontStyle: FontStyle.normal,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String label) {
    final bool isSelected = widget.tabIndex == index;
    return GestureDetector(
      onTap: () {
        widget.onTabChanged?.call(index);
      },
      child: Container(
        width: 136,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(
            color: const Color.fromRGBO(255, 255, 255, 0.07),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'ClashDisplay',
              fontSize: 14,
              fontWeight: FontWeight.w400, // Regular
              fontStyle: FontStyle.normal,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  void _showCityTopSheet(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            color: Color.fromARGB(0, 58, 58, 58),
            child: Container(
              height:
                  MediaQuery.of(context).size.height *
                  0.30, //  of screen height
              width: 300,
              margin: EdgeInsets.only(top: 120),

              padding: EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 10,
                    sigmaY: 10,
                  ), // Blur intensity
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3), // Transparent color
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    child: Obx(() {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: cityController.cities.map((city) {
                            bool isSelected =
                                city["name"] ==
                                cityController.selectedCity.value;
                            return Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.grey[800] // selected bg color
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: AssetImage(
                                    city["image"]!,
                                  ), // ✅ Use AssetImage
                                ),
                                title: Text(
                                  city["name"]!,
                                  style: const TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontFamily: "Clash Display",
                                    fontSize: 14,
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.w400,
                                    height: 8.204 / 14, // line-height 8.204px
                                    letterSpacing: -0.28,
                                  ),
                                ),
                                trailing: isSelected
                                    ? Image.asset(
                                        "assets/icons/Round Alt Arrow Right.png",
                                        height: 30,
                                        width: 30,
                                      )
                                    : null,
                                onTap: () {
                                  cityController.selectCity(city["name"]!);
                                  Get.back(); // close sheet
                                },
                              ),
                            );
                          }).toList(),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(anim1),
          child: child,
        );
      },
    );
  }
}
