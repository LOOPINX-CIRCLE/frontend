import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/Home_pages/UI_Design/home_page.dart';
import 'package:text_code/Reusable/text_Bricolage%20Grotesque_reusable.dart';
import 'package:text_code/Reusable/text_reusable.dart';

class Failed extends StatelessWidget {
  const Failed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button and heading aligned - margin 31 from top
              Padding(
                padding: const EdgeInsets.only(top: 31, left: 16, right: 16),
                child: Row(
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          "assets/icons/Back Icon.png",
                          height: 24,
                          width: 24,
                        ),
                      ),
                    ),
                    // Payment failed heading - centered
                    Expanded(
                      child: Center(
                        child: Text(
                          "Payment failed",
                          style: GoogleFonts.bricolageGrotesque(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    // Spacer to balance the back button
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              // Margin 250, then image
              const SizedBox(height: 80),
              Center(
                child: Image.asset("assets/icons/iconpaym.png"),
              ),
              // Keep Try Again and Go Back buttons same
              const SizedBox(height: 30),
              Center(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromRGBO(40, 40, 40, 1.0), // Lighter gray at top
                          Color.fromRGBO(20, 20, 20, 1.0), // Darker gray in middle
                          Colors.black, // Black at bottom
                        ],
                      
                        stops: [0.0, 0.5, 1.0],
                      ),
                      border: Border.all(color: Colors.grey, width: 1.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      child: Text(
                        "Try Again",
                        style: GoogleFonts.bricolageGrotesque(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    Get.to(() => HomePages());
                  },
                  child: FormLabel("Go Back", fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
