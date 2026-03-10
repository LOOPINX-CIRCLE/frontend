// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:text_code/Reusable/waitNavigation.dart';
import 'package:text_code/profilePage/profile.dart';

class WaitHome extends StatefulWidget {
  const WaitHome({super.key});

  @override
  State<WaitHome> createState() => _WaitHomeState();
}

class _WaitHomeState extends State<WaitHome> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/waitlist.png',
              fit: BoxFit.cover,
            ),
          ),
          // Main waitlist content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Headline line 1
                    const Text(
                      'Highly Selective',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'ClashDisplay',
                        fontWeight: FontWeight.w500, // 500
                        fontSize: 49,
                        color: Colors.white,
                        height: 1.1,
                        letterSpacing: -2.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Headline line 2: "and curated"
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        children: [
                          // "and"
                          TextSpan(
                            text: 'and',
                            style: TextStyle(
                              fontFamily: 'ClashDisplay',
                              fontWeight: FontWeight.w500,
                              fontSize: 49,
                              color: Colors.white,
                              height: 1.0,
                              letterSpacing: -1.0,
                            ),
                          ),
                          // explicit gap of two spaces between "and" and "Curated"
                          TextSpan(
                            text: '   ',
                            style: TextStyle(
                              fontFamily: 'ClashDisplay',
                              fontWeight: FontWeight.w500,
                              fontSize: 49,
                              color: Colors.white,
                              height: 1.0,
                              letterSpacing: 0,
                            ),
                          ),
                          // "Curated" in Ballet
                          TextSpan(
                            text: 'Curated',
                            style: TextStyle(
                              fontFamily: 'Ballet',
                              fontWeight: FontWeight.w400,
                              fontSize: 60,
                              color: Colors.white,
                              height: 1.0,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Body copy
                    const Text(
                      "Our team is reviewing your\nprofile for exclusive access.\nYou'll be notified shortly.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'ClashDisplay',
                        fontWeight: FontWeight.w300, // 300
                        fontSize: 26,
                        color: Colors.white,
                        height: 1.2,
                        letterSpacing: -1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Navigation bar 70px above the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 70,
            child: WaitNavigationBar(
              onTap: (index) {
                // Handle navigation - index 2 is the Profile icon
                if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(
                        hasHomePagesAccess: false, // User is on waitlist, not verified
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
