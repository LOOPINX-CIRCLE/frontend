import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/Reusable/text_Bricolage%20Grotesque_reusable.dart';
import 'package:text_code/Reusable/text_reusable.dart';

class TicketInfoCard extends StatelessWidget {
  final String title; // top heading text
  final List<Map<String, dynamic>> infoItems; // label + value + style
  final String buttonText;
  final VoidCallback onButtonPressed;
  final String? bottomLabel; // optional like "View Breakdown"
  final bool showImageButton; // for ticket image button or text button
  final String? imageButtonPath;

  const TicketInfoCard({
    super.key,
    required this.title,
    required this.infoItems,
    required this.buttonText,
    required this.onButtonPressed,
    this.bottomLabel,
    this.showImageButton = false,
    this.imageButtonPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: 351,
            height: 500,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage("assets/images/85 1.png"),
                alignment: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Colors.black, Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border.all(color: Colors.grey),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextBricolage(
                  FontWeight.w500,
                  title,
                  26,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Ticket Info Card
                Container(
                  width: 298,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 23, 23, 23),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._buildInfoRows(),
                      if (bottomLabel != null) ...[
                        Divider(color: Colors.grey),
                        FormLabel(
                          bottomLabel!,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ✅ Button (Image button OR text button)
                showImageButton
                    ? ElevatedButton(
                        onPressed: onButtonPressed,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          minimumSize: const Size(298, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Image.asset(
                          imageButtonPath ?? "",
                          height: 60,
                          width: 298,
                        ),
                      )
                    : ElevatedButton(
                        onPressed: onButtonPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.grey, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          // minimumSize: const Size(298, 60),
                        ),
                        child: TextBricolage(FontWeight.w500, buttonText, 18),
                      ),

                // Go Back
                TextButton(
                  onPressed: () => Get.back(),
                  child: FormLabel(
                    "Go Back",
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildInfoRows() {
    List<Widget> rows = [];
    for (int i = 0; i < infoItems.length; i++) {
      var item = infoItems[i];
      rows.add(
        _ticketRow(
          item["title"],
          item["value"],
          isBold: item["isBold"] ?? false,
        ),
      );
      if (i != infoItems.length - 1) rows.add(Divider(color: Colors.grey));
    }
    return rows;
  }

  Widget _ticketRow(String title, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
