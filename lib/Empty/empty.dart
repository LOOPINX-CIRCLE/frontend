import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/Reusable/bar_element.dart';

class EventAnalyticsScreen extends StatelessWidget {
  const EventAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              "assets/images/empty state new image.png",
            ), // Replace with your image path
            fit: BoxFit.cover,
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [
              // Top Bar with Back and Close
              BarElement(),
              const SizedBox(height: 250),
              // Empty State Message
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "No analytics available yet",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "You'll be able to see detailed revenue\nand ticket analytics after your event ends.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
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
}
