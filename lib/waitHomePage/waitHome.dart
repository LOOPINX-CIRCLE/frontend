// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:text_code/waitVideo.dart';
import 'package:text_code/Reusable/waitNavigation.dart';
import 'package:text_code/profilePage/profile.dart';
import 'package:google_fonts/google_fonts.dart';

class WaitHome extends StatefulWidget {
  const WaitHome({super.key});

  @override
  State<WaitHome> createState() => _WaitHomeState();
}

class _WaitHomeState extends State<WaitHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Video background - full screen
          Positioned.fill(
            child: WaitVideo(
              videoPath: 'assets/video/WaitlistVideo.mp4',
              autoPlay: true,
              looping: true,
              volume: 1.0,
            ),
          ),
          
          // Background container at the bottom with arc shape
         Positioned(
  left: 0,
  right: 0,
  bottom: 0,
  child: Container(
    width: double.infinity,
    height: 530,
    decoration: const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/Ellipse 1.png'),
        fit: BoxFit.cover, // makes it fill the width fully
      ),
    ),
  ),
),

          // Featured icon at the top center of the arc
          Positioned(
            bottom: 500, // Position slightly below the top edge of the arc container
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/Featured icon.png',
                width: 60,
                height: 60,
              ),
            ),
          ),
          
          // "You're In The Vetting Queue" image below featured icon
          Positioned(
  bottom: 420, // Position below the featured icon
  left: 0,
  right: 0,
  child: Center(
    child: Text(
      "You're In The Vetting Queue",
      
          style: GoogleFonts.bricolageGrotesque(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: Colors.white, // or any color you prefer
      ),
      textAlign: TextAlign.center,
    ),
  ),
),

          
          // Text below the image
          Positioned(
            bottom: 360, // Position below the "You're In The Vetting Queue" image
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Text(
                "We're ensuring The Circle is the right fit. We'll send a notification the moment your access is approved.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w300,
                  height: 1.25, // line-height: 20px / 16px = 1.25
                ),
              ),
            ),
          ),
          
          // Logo and text image just above navigation bar
          Positioned(
            bottom: 80, // Position just above the navigation bar (24 + 65 + some spacing)
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/Logo and text (1).png',
                fit: BoxFit.contain,
               
              ),
            ),
          ),
          
          // Navigation bar at the bottom
          WaitNavigationBar(
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
        ],
      ),
    );
  }
}
