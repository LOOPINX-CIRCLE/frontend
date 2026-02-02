// ignore_for_file: deprecated_member_use, avoid_print, unused_import

import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
import 'package:text_code/core/utils/jwt_utils.dart';
import 'package:text_code/core/services/secure_storage_service.dart';

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
  int? _currentUserId;
  int selectedIndex = 0;
  
  void imageTap() {
    print("Image tapped!");
  }

  /// Get current user ID from token
  Future<int?> _getCurrentUserId() async {
    if (_currentUserId != null) return _currentUserId;
    
    try {
      final token = await _secureStorage.getToken();
      if (token != null) {
        _currentUserId = JwtUtils.getUserId(token);
        return _currentUserId;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current user ID: $e');
      }
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

                return FutureBuilder<int?>(
                  future: _getCurrentUserId(),
                  builder: (context, snapshot) {
                    final currentUserId = snapshot.data;
                    
                    // Sort events: hosted events first
                    final sortedEvents = List<Event>.from(homePageController.events);
                    sortedEvents.sort((a, b) {
                      final aIsHost = currentUserId != null && a.host.id == currentUserId;
                      final bIsHost = currentUserId != null && b.host.id == currentUserId;
                      if (aIsHost && !bIsHost) return -1;
                      if (!aIsHost && bIsHost) return 1;
                      return 0;
                    });
                    
                    return Column(
                      children: sortedEvents.map((event) {
                        // Check if current user is hosting this event
                        final bool isUserHost = currentUserId != null && event.host.id == currentUserId;
                        
                        // Determine badge text based on event status
                        final bool hasEnded = event.hasEnded;
                        String badgeText = isUserHost && !hasEnded 
                            ? "Your Event is Live!" 
                            : hasEnded 
                                ? "Event Has Ended" 
                                : "New Event";
                        final bool isEnded = hasEnded;
                    
                    // Check if request is accepted - this could be determined by:
                    // 1. Badge text is "New Invite" (request accepted by host)
                    // 2. Event status indicates user is attending
                    // 3. User's request status from API (you may need to add this field)
                    // For now, we'll check the badge text and event status
                    final bool isRequestAccepted = badgeText == "New Invite" || 
                        event.status.toLowerCase().contains('accepted') ||
                        event.status.toLowerCase().contains('going') ||
                        event.status.toLowerCase().contains('attending');
                    
                    // Show two buttons only when:
                    // - Event hasn't ended AND
                    // - (Badge is "New Invite" OR request is accepted)
                    final bool shouldShowTwoButtons = !isEnded && 
                        (badgeText.trim() == "New Invite" || isRequestAccepted);
                    
                    // Get cover images or use placeholder
                    final List<String> imageUrls = event.coverImages.isNotEmpty
                        ? event.coverImages
                        : ["assets/images/image (2).png"];
                    
                    // Format date and location - only use venue name
                    final String dateLocation = _formatDateLocation(
                      event.startTime,
                      event.location.name, // Only use venue name, not address
                    );
                    
                    // Format date for EventDetail
                    String formattedDate = '';
                    if (event.startTime.isNotEmpty) {
                      try {
                        final dateTime = DateTime.parse(event.startTime);
                        formattedDate = DateFormat('EEEE d, MMMM yyyy').format(dateTime);
                      } catch (e) {
                        formattedDate = '';
                      }
                    }
                    
                    // Format time for EventDetail
                    String formattedTime = event.formattedTime;
                    if (formattedTime.isEmpty) {
                      formattedTime = "TBD";
                    } else {
                      formattedTime = "$formattedTime onwards";
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
                      buttonLabel: isEnded 
                          ? null 
                          : (isUserHost ? "View Request" : "Send Request"),
                      buttonVariant: LoopinButtonVariant.primary,
                      showButton: !isEnded,
                      showTwoButtons: shouldShowTwoButtons && !isUserHost, // Don't show two buttons for hosted events
                      isPaid: event.isPaid,
                      price: event.isPaid && event.ticketPrice != null
                          ? event.ticketPrice
                          : null,
                      onUploadTap: () {
                        // Handle upload/share icon tap
                        print("Upload icon tapped for ${event.title}");
                      },
                      onTap: () {
                        // Navigate to MainScreen for hosted events, EventDetail for others
                        if (isUserHost && !isEnded) {
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
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventDetail(
                              title: event.title,
                              date: formattedDate,
                              time: formattedTime,
                              hostName: event.host.name,
                              hostImage: event.host.profileImage ??
                                  "assets/images/avatar.png",
                              eventImage: imageUrls.isNotEmpty
                                  ? imageUrls[0]
                                  : "assets/images/image (2).png",
                              venue: event.location.name,
                              fullAddress: event.location.address,
                              aboutEvent: event.description,
                              badgeText: badgeText,
                              attendeesCount: event.goingCount,
                              attendeeImages: const [
                                "assets/images/avatar.png",
                                "assets/images/ananya.png",
                                "assets/images/kabir.png",
                              ],
                              isGoing: false,
                              price: event.isPaid && event.ticketPrice != null
                                  ? event.ticketPrice
                                  : null,
                              starImagePath: "assets/icons/Group 1 (2).png",
                            ),
                          ),
                        );
                        }
                      },
                      onFirstButtonTap: () {
                        // Handle "Going!" button tap
                        print("Going button tapped for ${event.title}");
                      },
                      onSecondButtonTap: () {
                        // Handle "Not Going :(" button tap
                        print("Not Going button tapped for ${event.title}");
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
