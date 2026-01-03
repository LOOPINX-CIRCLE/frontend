import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/Reusable/text_Bricolage%20Grotesque_reusable.dart';
import 'package:text_code/Reusable/text_reusable.dart';
import 'package:text_code/Reusable/animated_page_wrapper.dart';

class PaymentStatusScreen extends StatelessWidget {
  final String appBarTitle;
  final String imagePath;

  final String primaryButtonText;
  final VoidCallback onPrimaryPressed;
  final String secondaryButtonText;
  final VoidCallback? onSecondaryPressed;
  final String? eventTitle;
  final String? venue;
  final String? dateTime;

  const PaymentStatusScreen({
    super.key,
    required this.appBarTitle,
    required this.imagePath,

    required this.primaryButtonText,
    required this.onPrimaryPressed,
    required this.secondaryButtonText,
    this.onSecondaryPressed,
    this.eventTitle,
    this.venue,
    this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedPageWrapper(
        child: SafeArea(
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
                      // Payment successful heading - centered
                      Expanded(
                        child: Center(
                          child: Text(
                            appBarTitle,
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
                // Margin 32, then image
                const SizedBox(height: 32),
                Center(child: Image.asset(imagePath, height: 200, width: 200)),
                // Gap reduced, then "Your ticket is" and "Confirmed" in next line
                // const SizedBox(height: 6),
                // Center(
                //   child: Column(
                //     children: [
                //       Text(
                //         "Your Ticket Is",
                //         style: GoogleFonts.bricolageGrotesque(
                //           color: Colors.white,
                //           fontSize: 26,
                //           fontWeight: FontWeight.w500,
                //         ),
                //       ),
                //       Text(
                //         "Confirmed",
                //         style: GoogleFonts.bricolageGrotesque(
                //           color: Colors.white,
                //           fontSize: 26,
                //           fontWeight: FontWeight.w500,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // Gap 31, then container with event details
                const SizedBox(height: 31),
                if (eventTitle != null || venue != null || dateTime != null)
                  Center(
                    child: Container(
                      width: 298,
                      height: 184,
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161616),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color.fromRGBO(43, 43, 43, 0.50),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (eventTitle != null) ...[
                            _buildDetailRow("Event", eventTitle!),
                            _buildDivider(),
                            const SizedBox(height: 10),
                          ],
                          if (venue != null) ...[
                            _buildDetailRow("Venue", venue!),
                            _buildDivider(),
                            const SizedBox(height: 10),
                          ],
                          if (dateTime != null) ...[
                            _buildDetailRow("Date & Time", dateTime!),
                          ],
                        ],
                      ),
                    ),
                  ),
                // Gap 27, then viewTicket.png as button
                const SizedBox(height: 27),
                Center(
                  child: GestureDetector(
                    onTap: onPrimaryPressed,
                    child: Image.asset(
                      "assets/images/viewTicket.png",
                      width: 298,
                      height: 44,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // Gap 13, then "Add to calendar"
                const SizedBox(height: 13),
                Center(
                  child: TextButton(
                    onPressed: onSecondaryPressed,
                    child: Text(
                      secondaryButtonText,
                      style: GoogleFonts.bricolageGrotesque(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      height: 1,
      color: Colors.grey.withOpacity(0.3),
    );
  }
}
