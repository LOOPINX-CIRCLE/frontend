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

import 'package:text_code/core/utils/image_url_helper.dart';

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

  final CapacityController capacityController = Get.put(CapacityController());
  final SecureStorageService _secureStorage = SecureStorageService();
  final EventRequestService _eventRequestService = EventRequestService();
  int? _currentUserId;
  int selectedIndex = 0;
  
  // Cache for request statuses: eventId -> status
  final Map<int, String?> _requestStatusCache = {};
  
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
                    
                    // Sort events: User's hosted events first (by latest ID), then others by latest event ID
                    final sortedEvents = List<Event>.from(homePageController.events);
                    sortedEvents.sort((a, b) {
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
                      children: sortedEvents.map((event) {
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
    final bool isUserHost = _isUserHostingEvent(event, currentUserId, currentUserPhoneNumber);
    
    // Determine badge text based on original event status (DON'T change badge)
    final bool hasEnded = event.hasEnded;
    String badgeText = isUserHost && !hasEnded 
        ? "Your Event is Live!" 
        : hasEnded 
            ? "Event Has Ended" 
            : "New Event";
    
    final bool isEnded = hasEnded;
    
    // Check if request is accepted
    final bool isRequestAccepted = (requestStatus?.toLowerCase() ?? '').contains('accepted') ||
        event.status.toLowerCase().contains('accepted') ||
        event.status.toLowerCase().contains('going') ||
        event.status.toLowerCase().contains('attending');
    
    // Show two buttons only when:
    // - Event hasn't ended AND
    // - Request is accepted
    final bool shouldShowTwoButtons = !isEnded && isRequestAccepted && !isUserHost;
    
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
    } else if (requestStatus?.toLowerCase() == 'pending') {
      // Change button to show "Requested to join" when request is pending
      buttonText = "Requested to join";
    }

    return InviteEventCard(
      badgeText: badgeText,
      imageUrls: imageUrls,
      title: event.title,
      dateLocation: dateLocation,
      hostName: event.host.name,
      starImagePath: "assets/icons/Group 1 (2).png",
      isEnded: isEnded,
      imagePath: isEnded
          ? ''
          : 'assets/images/button/Frame 19976 (4).png',
      buttonLabel: isEnded ? null : buttonText,
      buttonVariant: LoopinButtonVariant.primary,
      showButton: !isEnded,
      showTwoButtons: shouldShowTwoButtons,
      isPaid: event.isPaid,
      price: event.isPaid && event.ticketPrice != null
          ? event.ticketPrice
          : null,
      onUploadTap: () {
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
                attendeesCount: event.goingCount,
                attendeeImages: [],
                isGoing: isRequestAccepted,
                price: event.isPaid && event.ticketPrice != null ? event.ticketPrice : null,
              ),
            ),
          );
        }
      },
      onFirstButtonTap: () {
        // "Going" button - Confirm attendance and generate ticket
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
              attendeesCount: event.goingCount,
              attendeeImages: [],
              isGoing: true,
              price: event.isPaid && event.ticketPrice != null ? event.ticketPrice : null,
            ),
          ),
        );
      },
      onSecondButtonTap: () {
        // "Not Going" button - Decline invitation/request
        print("Not Going button tapped for ${event.title}");
        // TODO: Implement decline invitation API call
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
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w600,
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
