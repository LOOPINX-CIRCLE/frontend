// ignore_for_file: deprecated_member_use, unused_element

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:text_code/Reusable/navigation_bar.dart';
import 'package:text_code/Reusable/text_Bricolage%20Grotesque_reusable.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareScreen extends StatelessWidget {
  final Widget imageWidget;

  const ShareScreen({super.key, required this.imageWidget});
  Future<void> _shareOnWhatsApp(String message) async {
    final url = "whatsapp://send?text=${Uri.encodeComponent(message)}";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      // Agar WhatsApp install nahi hai to normal share khol do
      await Share.share(message, subject: "Event Invitation");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      // body: Center(child: imageWidget),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(child: TextBricolage(FontWeight.normal, "Share Invite", 20)),
            SizedBox(height: 10),
            Container(
              width: 320,
              height: 390,
              decoration: BoxDecoration(
                // color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey, width: 1),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // ✅ Image centered and fills the container
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: FittedBox(
                        fit: BoxFit
                            .cover, // ✅ fill container, maintaining aspect ratio
                        child: imageWidget,
                      ),
                    ),
                  ),

                  // ✅ Share button positioned on top
                  Positioned(
                    bottom: 10,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 16, // top & bottom padding
                              horizontal: 16, // left & right padding
                            ),
                          ),
                          icon: Image.asset(
                            "assets/icons/Upload Square.png",
                            height: 24,
                            width: 24,
                            color: Colors.white,
                          ),
                          label: Text(
                            "Share Invite",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          onPressed: () async {
                            String message =
                                "🎉 You're invited to this awesome event!\nJoin here 👉 https://youreventlink.com";

                            // ✅ General share (all apps)
                            await Share.share(
                              message,
                              subject: "Event Invitation",
                            );

                            // ✅ Agar direct WhatsApp share chahiye to niche function call karo:
                            // await _shareOnWhatsApp(message);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align icon and text at the top
                children: [
                  // Info Icon
                  const Icon(
                    Icons.info_outline,
                    color: Colors.grey, // Light gray color for the icon
                    size: 24,
                  ),

                  const SizedBox(width: 12.0), // Spacing between icon and text
                  // Text that wraps
                  Expanded(
                    child: Text(
                      'Share this event on your socials and let people join directly',
                      style: GoogleFonts.poppins(
                        color: Colors.grey, // Light gray color for the text
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFF1E1E1E),
                border: const Border(),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, top: 20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BottomBar()),
                    );
                  },

                  child: Image.asset(
                    "assets/images/button/sharebutton.png",
                    alignment: Alignment.topCenter,
                    height: 52,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
