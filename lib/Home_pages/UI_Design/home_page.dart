// ignore_for_file: deprecated_member_use, avoid_print, unused_import

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:text_code/Home_pages/Controller/home_page.dart';
import 'package:text_code/Reusable/eventcard.dart';
import 'package:text_code/Home_pages/Ticket_Pages_navigation/ticket_navigation_going/ticket_screen_zero.dart';
import 'package:text_code/Host_Pages/Controller_files/capicity_cntoller.dart';
import 'package:text_code/Host_Pages/Controller_files/event_cntroller.dart';
import 'package:text_code/Reusable/text_Bricolage%20Grotesque_reusable.dart';
import 'package:text_code/Reusable/navigation_bar.dart';
import 'package:text_code/Reusable/loopin_cta_button.dart';
import 'package:text_code/Home_pages/UI_Design/eventdetail.dart';
import 'package:text_code/HostManagement/mainScreen.dart';

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

  final CapacityController capacityController = Get.put(CapacityController());
  int selectedIndex = 0;
  void imageTap() {
    print("Image tapped!");
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
                            TextBricolage(
                              FontWeight.normal,
                              "Pick your scene",
                              12,
                            ),
                            SizedBox(height: 2),
                            Text(
                              cityController.selectedCity.value,
                              style: GoogleFonts.bricolageGrotesque(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
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
              InviteEventCard(
                badgeText: "",
                imageUrls: ["assets/images/image (2).png"],
                title: "DiwaNight",
                dateLocation: "${_getDate48HoursBefore()}, Bastian garden city",
                hostName: "Anya",
                starImagePath: "assets/icons/Group 1 (2).png",
                isEnded: false,
                status: EventStatus.hostedByCurrentUser,
                imagePath: 'assets/images/button/Frame 19976 (3).png',
                buttonLabel: "View Request",
                buttonVariant: LoopinButtonVariant.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainScreen(
                        eventName: "DiwaNight",
                        eventPrice: "₹499",
                        confirmedUsers: 34,
                        invitedCount: 10, // Set to > 0 to see invited list
                        requestsCount: 10, // Set to > 0 to see requests list
                        checkInCount: 3, // Set to > 0 to see check-in list
                      ),
                    ),
                  );
                },
              ),
              InviteEventCard(
                badgeText: "New Event",
                imageUrls: ["assets/images/image (2).png"],
                title: "Astro night",
                dateLocation: "7 Jun 25, Bastian garden city",
                hostName: "Anya",
                starImagePath: "assets/icons/Group 1 (2).png",
                isEnded: true,
                imagePath: 'assets/images/button/Frame 19976 (4).png',
                buttonLabel: "Send Request",
                buttonVariant: LoopinButtonVariant.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetail(
                        title: "Astro night",
                        date: "Sunday 25, September 2009",
                        time: "7:30 PM onwards",
                        hostName: "Anya Dangwal",
                        hostImage: "assets/images/ananya.png",
                        eventImage: "assets/images/image (2).png",
                        venue: "Bastian Garden City",
                        fullAddress: "Basque Garden project, Mussoorie Rd, near Dehradun Zoo, Salan Gaon, Mahi, Dehradun, Guniyal Gaon, Uttarakhand 248001",
                        aboutEvent: "SIP CLUB POP-UP: DISCO DREAM\n\nWednesday, 18th June | Bastian Garden City\nHosted by Pragya Mishra & Vrithi Manjeshwar\nTheme: Silver-Coded & Blinged to Perfection\n\nBrace yourself.\n\nStep into a mirrorball fantasy where every surface catches light and every moment sparkles with possibility. This isn't just an event—it's a portal to the most exclusive night of your life.\n\nTHE NIGHT:\n• Sequins in motion.\n• Crystals catching strobe flashes.\n• High-gloss glamour with no dimmer switch.\n• This is where the who's-who shows up and shows off.\n\nTHE SOUND:\nOn the decks - DJ GANESH, India's most iconic wedding DJ, teaming up with Yudi for an unforgettable musical journey.",
                        badgeText: "New Event",
                        attendeesCount: 24,
                        attendeeImages: [
                          "assets/images/avatar.png",
                          "assets/images/ananya.png",
                          "assets/images/kabir.png",
                          "assets/images/avatar.png",
                          "assets/images/ananya.png",
                        ],
                        isGoing: false,
                        price: "₹499",
                        starImagePath: "assets/icons/Group 1 (2).png",
                      ),
                    ),
                  );
                },
                showButton: true,
                showTwoButtons: true, // 👈 ab Row me 2 button aayenge
                price:
                    eventController.ticketPrice.value, // ✅ yahan se pass hoga
                onFirstButtonTap: () => print("First button tapped ✅"),
                onSecondButtonTap: () => print("Second button tapped 🎉"),
              ),
              InviteEventCard(
                badgeText: "  New Invite   ",
                imageUrls: ["assets/images/image (4).png"],
                title: "Nirvaan",
                dateLocation: "${_getDate48HoursBefore()}, Bastian garden city",
                hostName: "Senan",
                starImagePath: "assets/icons/Group 1 (6).png",
                isEnded: true,
                imagePath: '',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetail(
                        title: "Nirvaan",
                        date: "Saturday 7, June 2025",
                        time: "8:00 PM onwards",
                        hostName: "Senan",
                        hostImage: "assets/images/avatar.png",
                        eventImage: "assets/images/image (4).png",
                        venue: "Bastian Garden City",
                        fullAddress: "Bastian Garden City, Dehradun, Uttarakhand",
                        aboutEvent: "Join us for an amazing evening at Nirvaan event. Experience the best of entertainment and networking in a beautiful setting.",
                        badgeText: "  New Invite   ",
                        attendeesCount: 15,
                        attendeeImages: [
                          "assets/images/avatar.png",
                          "assets/images/ananya.png",
                          "assets/images/kabir.png",
                        ],
                        isGoing: false,
                        price: "₹300",
                        starImagePath: "assets/icons/Group 1 (6).png",
                      ),
                    ),
                  );
                },
                showButton: true,
                showTwoButtons: true, // 👈 ab Row me 2 button aayenge
                onFirstButtonTap: () => print("First button tapped ✅"),
                onSecondButtonTap: () => print("Second button tapped 🎉"),
              ),
              InviteEventCard(
                badgeText: "New Event",
                imageUrls: ["assets/images/image (2).png"],
                title: "Astro night",
                dateLocation: "${_getDate48HoursBefore()}, Bastian garden city",
                hostName: "Anya",
                starImagePath: "assets/icons/Group 1 (2).png",
                isEnded: true,
                imagePath: 'assets/images/button/Frame 19976 (4).png',
                buttonLabel: "Send Request",
                buttonVariant: LoopinButtonVariant.primary,

                onTap: () {
                  // "New Event" single button - opens EventDetail with "Send Request" button
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetail(
                        title: "Astro night",
                        date: "Sunday 25, September 2009",
                        time: "7:30 PM onwards",
                        hostName: "Anya Dangwal",
                        hostImage: "assets/images/ananya.png",
                        eventImage: "assets/images/image (2).png",
                        venue: "Bastian Garden City",
                        fullAddress: "Basque Garden project,Dehradun,",
                        aboutEvent: "SIP CLUB POP-UP: DISCO DREAM\n\nWednesday, 18th June | Bastian Garden City\nHosted by Pragya Mishra & Vrithi Manjeshwar\nTheme: Silver-Coded & Blinged to Perfection\n\nBrace yourself.\n\nStep into a mirrorball fantasy where every surface catches light and every moment sparkles with possibility. This isn't just an event—it's a portal to the most exclusive night of your life.\n\nTHE NIGHT:\n• Sequins in motion.\n• Crystals catching strobe flashes.\n• High-gloss glamour with no dimmer switch.\n• This is where the who's-who shows up and shows off.\n\nTHE SOUND:\nOn the decks - DJ GANESH, India's most iconic wedding DJ, teaming up with Yudi for an unforgettable musical journey.",
                        badgeText: "New Event",
                        attendeesCount: 24,
                        attendeeImages: [
                          "assets/images/avatar.png",
                          "assets/images/ananya.png",
                          "assets/images/kabir.png",
                          "assets/images/avatar.png",
                          "assets/images/ananya.png",
                        ],
                        isGoing: false,
                        price: null, // No price for single button "New Event" - will show "Send Request" button
                        starImagePath: "assets/icons/Group 1 (2).png",
                      ),
                    ),
                  );
                },
              ),
              InviteEventCard(
                badgeText: "You're Going",
                imageUrls: ["assets/images/gameNight.png"],
                title: "F1 night",
                dateLocation: "${_getDate48HoursBefore()}, Bastian garden city",
                hostName: "Anya",
                isEnded: false,
                imagePath: 'assets/images/button/Frame 19976 (2).png',
                buttonLabel: "View Ticket",
                buttonVariant: LoopinButtonVariant.primary,
                status: EventStatus.attending, // 👈 Pass the status here
                onTap: () {
                  // Navigate to EventDetail - will show single button that opens BookedTicket
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetail(
                        title: "F1 night",
                        date: "Saturday 7, June 2025",
                        time: "8:00 PM onwards",
                        hostName: "Anya",
                        hostImage: "assets/images/ananya.png",
                        eventImage: "assets/images/gameNight.png",
                        venue: "Bastian Garden City",
                        fullAddress: "Bastian Garden City, Dehradun, Uttarakhand",
                        aboutEvent: "Join us for an exciting F1 night event. Experience the thrill of Formula 1 racing in a unique setting with fellow racing enthusiasts.",
                        badgeText: "You're Going",
                        attendeesCount: 20,
                        attendeeImages: [
                          "assets/images/avatar.png",
                          "assets/images/ananya.png",
                          "assets/images/kabir.png",
                        ],
                        isGoing: true,
                        price: null, // No price for "You're Going" badge
                        starImagePath: "assets/icons/Group 1 (5).png",
                      ),
                    ),
                  );
                },
                starImagePath: "assets/icons/Group 1 (5).png",
              ),

              InviteEventCard(
                badgeText: "Event Has Ended",
                imageUrls: ["assets/images/image (3).png"],
                title: "SunSet Sip",
                dateLocation: "${_getDate48HoursBefore()}, Bastian garden city",
                hostName: "Senan",
                starImagePath: "assets/icons/Group 1 (3).png",
                isEnded: true,
                imagePath: '',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetail(
                        title: "SunSet Sip",
                        date: "Friday 6, June 2025",
                        time: "6:00 PM onwards",
                        hostName: "Senan",
                        hostImage: "assets/images/avatar.png",
                        eventImage: "assets/images/image (3).png",
                        venue: "Bastian Garden City",
                        fullAddress: "Bastian Garden City, Dehradun, Uttarakhand",
                        aboutEvent: "A beautiful sunset event that has now ended. Thank you to all who attended this memorable evening.",
                        badgeText: "Event Has Ended",
                        attendeesCount: 45,
                        attendeeImages: [
                          "assets/images/avatar.png",
                          "assets/images/ananya.png",
                          "assets/images/kabir.png",
                        ],
                        isGoing: false,
                        price: "₹200",
                        starImagePath: "assets/icons/Group 1 (3).png",
                      ),
                    ),
                  );
                },
                showButton: false,
              ),
              InviteEventCard(
                badgeText: "Deadline Has Passed",
                imageUrls: ["assets/images/image (4).png"],
                title: "Nirvaan",
                dateLocation: "${_getDate48HoursBefore()}, Bastian garden city",
                hostName: "Senan",
                starImagePath: "assets/icons/Group 1 (4).png",
                isEnded: true,
                imagePath: '',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetail(
                        title: "Nirvaan",
                        date: "Saturday 7, June 2025",
                        time: "8:00 PM onwards",
                        hostName: "Senan",
                        hostImage: "assets/images/avatar.png",
                        eventImage: "assets/images/image (4).png",
                        venue: "Bastian Garden City",
                        fullAddress: "Bastian Garden City, Dehradun, Uttarakhand",
                        aboutEvent: "This event's registration deadline has passed. Unfortunately, you can no longer register for this event.",
                        badgeText: "Deadline Has Passed",
                        attendeesCount: 30,
                        attendeeImages: [
                          "assets/images/avatar.png",
                          "assets/images/ananya.png",
                          "assets/images/kabir.png",
                        ],
                        isGoing: false,
                        price: "₹400",
                        starImagePath: "assets/icons/Group 1 (4).png",
                      ),
                    ),
                  );
                },
                showButton: false,
              ),
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
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: isSelected ? Colors.white : Colors.grey,
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
            style: GoogleFonts.poppins(
              fontSize: 14,
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
