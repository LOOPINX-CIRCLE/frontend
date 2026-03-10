import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/Reusable/loopin_cta_button.dart';
import 'package:text_code/Reusable/text_Bricolage%20Grotesque_reusable.dart';
import 'package:text_code/Reusable/text_reusable.dart';

class TicketInfoCard extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> infoItems;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final String? bottomLabel;
  final bool showImageButton;
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
      body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 351.0,
              ),
            child: Container(
                width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D0D), // background color
                borderRadius: BorderRadius.circular(28), // border radius
                border: Border.all(
                  color: const Color.fromRGBO(
                    43,
                    43,
                    43,
                    0.5,
                  ), // border color with opacity
                  width: 2.0,
                ),
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
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 290,
                    ),
                    child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 23, 23, 23),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ..._buildInfoRows(),
                        if (bottomLabel != null) ...[
                          const Divider(color: Colors.grey),
                          const SizedBox(height: 1),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 22),
                              child: FormLabel(bottomLabel!, fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        ],
                      ],
                    ),
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
                            minimumSize: const Size(298.0, 60.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.asset(
                              imageButtonPath ?? "",
                              height: 60.0,
                              width: 298.0,
                            ),
                          ),
                        )
                      : LoopinCtaButton(
                          label: buttonText,
                          width: 298.0,
                          onPressed: onButtonPressed,
                        ),

                  // Go Back Button
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
      if (i != infoItems.length - 1) {
        rows.add(const Divider(color: Colors.grey));
      }
    }
    return rows;
  }

  Widget _ticketRow(String title, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title - Flexible to prevent overflow
          Flexible(
            flex: 2,
            child: Text(
            title,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          const SizedBox(width: 8.0), // Add spacing between title and value
          // Value - Flexible to prevent overflow
          Flexible(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
