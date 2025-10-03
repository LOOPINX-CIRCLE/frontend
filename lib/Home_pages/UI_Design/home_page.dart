// ignore_for_file: deprecated_member_use, avoid_print

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/Home_pages/Controller/home_page.dart';
import 'package:text_code/Home_pages/Reusable_card/eventcard.dart';
import 'package:text_code/Home_pages/UI_Design/ticket_screen.dart';
import 'package:text_code/Host_Pages/Controller_files/capicity_cntoller.dart';
import 'package:text_code/Host_Pages/Controller_files/event_cntroller.dart';
import 'package:text_code/Reusable/text_Bricolage%20Grotesque_reusable.dart';

class HomePages extends StatefulWidget {
  const HomePages({super.key});

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
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
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
              InviteEventCard(
                badgeText: "",
                imageUrls: ["assets/images/image (2).png"],
                title: "Astro night",
                dateLocation: "7 Jun 25, Bastian garden city",
                hostName: "Anya",
                starImagePath: "assets/icons/Group 1 (2).png",
                isEnded: false,
                status: EventStatus.hostedByCurrentUser,
                imagePath: 'assets/images/button/Frame 19976 (3).png',
                onTap: () {},
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
                // onTap: () {
                //   controllerbut.changeImage("assets/images/button/button.png");
                //   // Get.to(() => const DetailsPage(title: "F1 Night"));
                // },
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
                dateLocation: "7 Jun 25, Bastian garden city",
                hostName: "Senan",
                starImagePath: "assets/icons/Group 1 (6).png",
                isEnded: true,
                imagePath: '',
                onTap: () {
                  Get.to(() => TicketScreen());
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
                dateLocation: "7 Jun 25, Bastian garden city",
                hostName: "Anya",
                starImagePath: "assets/icons/Group 1 (2).png",
                isEnded: true,
                imagePath: 'assets/images/button/Frame 19976 (4).png',
                onTap: () {
                  controllerbut.changeImage("assets/images/button/button.png");
                  // Get.to(() => const DetailsPage(title: "F1 Night"));
                },
              ),
              InviteEventCard(
                badgeText: "You're Going",
                imageUrls: ["assets/images/image (1).png"],
                title: "F1 night",
                dateLocation: "7 Jun 25, Bastian garden city",
                hostName: "Anya",
                isEnded: false,
                imagePath: 'assets/images/button/Frame 19976 (2).png',
                status: EventStatus.attending, // 👈 Pass the status here
                onTap: () {},
                starImagePath: "assets/icons/Group 1 (5).png",
              ),

              InviteEventCard(
                badgeText: "Event Has Ended",
                imageUrls: ["assets/images/image (3).png"],
                title: "SunSet Sip",
                dateLocation: "7 Jun 25, Bastian garden city",
                hostName: "Senan",
                starImagePath: "assets/icons/Group 1 (3).png",
                isEnded: true,
                imagePath: '',
                onTap: () {},
                showButton: false,
              ),
              InviteEventCard(
                badgeText: "Deadline Has Passed",
                imageUrls: ["assets/images/image (4).png"],
                title: "Nirvaan",
                dateLocation: "7 Jun 25, Bastian garden city",
                hostName: "Senan",
                starImagePath: "assets/icons/Group 1 (4).png",
                isEnded: true,
                imagePath: '',
                onTap: () {},
                showButton: false,
              ),
              SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTabButton(int index, String label) {
    final bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
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
