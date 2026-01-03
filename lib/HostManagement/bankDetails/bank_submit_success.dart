import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BankSubmitSuccessScreen extends StatelessWidget {
  const BankSubmitSuccessScreen({super.key});

  static void show(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BankSubmitSuccessScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Success icon
                      Image.asset(
                        'assets/icons/Confirm guest empty state icon.png',
                        width: 56,
                        height: 56,
                      ),
                      const SizedBox(height: 5),
                      // Main text
                      Text(
                        'Details submitted successfully',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Sub text
                      Text(
                        'Settlements typically hit your account within 3-5 business days',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFFAEAEAE),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Host a new event button
                      GestureDetector(
                        onTap: () {
                          // Navigate back to home or main screen
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        child: Container(
                          width: 269,
                          height: 56,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF9355F0),
                                Color(0xFF7C3AED),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Center(
                            child: Text(
                              'Host a new event',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Support contact information
            Padding(
              padding: const EdgeInsets.only(bottom: 40, left: 24, right: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'For any support contact',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Business@loopinsocial.in',
                    style: GoogleFonts.poppins(
                       color: const Color(0xFFAEAEAE),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+91 9927270474',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFAEAEAE),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

