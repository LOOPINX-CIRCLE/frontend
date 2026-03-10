import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:text_code/Reusable/navigation_bar.dart';
import 'package:text_code/Reusable/text_Bricolage%20Grotesque_reusable.dart';
import 'package:text_code/core/services/event_request_service_host.dart';

class ShareScreen extends StatefulWidget {
  final Widget imageWidget;
  final int eventId;

  const ShareScreen({super.key, required this.imageWidget, this.eventId = 0});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  late EventRequestService _eventRequestService;
  String _shareUrl = ""; // Will be fetched from backend

  @override
  void initState() {
    super.initState();
    _eventRequestService = EventRequestService();
    
    // Fetch the share URL if eventId is provided
    if (widget.eventId > 0) {
      _fetchShareUrl();
    }
  }

  Future<void> _fetchShareUrl() async {
    try {
      final url = await _eventRequestService.getEventShareUrl(widget.eventId);
      
      if (mounted) {
        setState(() {
          _shareUrl = url;
        });
      }
      
      if (kDebugMode) {
        print('✅ Share URL loaded: $_shareUrl');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching share URL: $e');
      }
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load share URL. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
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
                        child: widget.imageWidget,
                      ),
                    ),
                  ),

                  // ✅ Share button positioned on bottom
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
                            // Check if URL is loaded
                            if (_shareUrl.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Loading share URL...'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                              return;
                            }

                            // Use the fetched canonical URL
                            String message =
                                "🎉 You're invited to this awesome event!\nJoin here 👉 $_shareUrl";

                            if (kDebugMode) {
                              print('📤 Sharing with message: $message');
                            }

                            // ✅ General share (all apps)
                            await Share.share(
                              message,
                              subject: "Event Invitation",
                            );
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

  @override
  void dispose() {
    _eventRequestService.dispose();
    super.dispose();
  }
}