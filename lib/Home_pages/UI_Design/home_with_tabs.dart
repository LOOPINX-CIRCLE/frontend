import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/Home_pages/Controller/home_page.dart';
import 'package:text_code/Home_pages/UI_Design/home_page.dart';
import 'package:text_code/login-signup/sign_up/booked_ticket.dart';
import 'package:text_code/Reusable/text_Bricolage%20Grotesque_reusable.dart';

class HomeWithTabs extends StatefulWidget {
  const HomeWithTabs({super.key, this.initialTab = 0});

  final int initialTab; // 0 for Discover, 1 for Ticket

  @override
  State<HomeWithTabs> createState() => _HomeWithTabsState();
}

class _HomeWithTabsState extends State<HomeWithTabs> {
  late int _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _selectedTab == 0
            ? HomePages(
                showTabs: false,
                tabIndex: _selectedTab,
                onTabChanged: (index) {
                  setState(() {
                    _selectedTab = index;
                  });
                },
              )
            : Column(
                children: [
                  // Location picker from HomePages
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: _buildLocationPicker(),
                  ),
                  // Tabs
                  Padding(
                    padding: const EdgeInsets.only(left: 24, top: 10),
                    child: Row(
                      children: [
                        _buildTabButton(0, "Discover"),
                        const SizedBox(width: 10),
                        _buildTabButton(1, "Ticket"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // BookedTicket content
                  Expanded(
                    child: const BookedTicket(showTabs: false),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLocationPicker() {
    final CityController cityController = Get.put(CityController());
    return Obx(
      () => InkWell(
        onTap: () => _showCityTopSheet(context),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                decoration: const BoxDecoration(shape: BoxShape.circle),
                padding: const EdgeInsets.all(6),
                child: Image.asset(
                  "assets/icons/Frame 81.png",
                  height: 40,
                  width: 40,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextBricolage(
                    FontWeight.normal,
                    "Pick your scene",
                    12,
                  ),
                  const SizedBox(height: 2),
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
    );
  }

  void _showCityTopSheet(BuildContext context) {
    final CityController cityController = Get.put(CityController());
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            color: const Color.fromARGB(0, 58, 58, 58),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.30,
              width: 300,
              margin: const EdgeInsets.only(top: 120),
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
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
                                city["name"] == cityController.selectedCity.value;
                            return Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.grey[800]
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: AssetImage(city["image"]!),
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
                                  Get.back();
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

  Widget _buildTabButton(int index, String label) {
    final bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
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
}

