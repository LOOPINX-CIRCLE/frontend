import 'package:flutter/material.dart';

class OBookedTicketPage extends StatelessWidget {
  const OBookedTicketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // background same as your design
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ticket icon image
            Image.asset(
              "assets/images/icon container.png", // 👈 replace with your image
              width: 52,
              height: 52,
            ),
            const SizedBox(height: 20),

            // White line with custom font
            const Text(
              "Oops, your ticket wallet is empty",
              style: TextStyle(
                fontFamily: "BricolageGrotesque", // 👈 your custom font
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),

            // Grey line normal font
            const Text(
              "Events are waiting, make the first move",
              style: TextStyle(
                fontSize: 12,
                color: Colors.white54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Explore Experiences button as image
            GestureDetector(
              onTap: () {
                // 👇 navigate to Discover page
                // Navigator.push(context, MaterialPageRoute(builder: (_) => DiscoverPage()));
              },
              child: Image.asset(
                "assets/images/exploreExperience.png", // 👈 replace with your image
                height: 38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
