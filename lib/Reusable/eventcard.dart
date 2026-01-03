// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:text_code/Home_pages/UI_Design/eventdetail.dart';
import 'package:text_code/Reusable/loopin_cta_button.dart';

class EventCardsController extends GetxController {
  var isEnded = false.obs;

  void endEvent() {
    isEnded.value = true;
  }
}

class EventCardImageController extends GetxController {
  var currentImage = "".obs;

  void changeImage(String newImage) {
    currentImage.value = newImage;
  }
}

enum EventStatus { hostedByCurrentUser, attending, newEvent, ended }

class InviteEventCard extends StatefulWidget {
  final String badgeText;
  final List<String> imageUrls;
  final String title;
  final String dateLocation;
  final String hostName;
  final bool isEnded;
  final String imagePath; // for single button
  final VoidCallback? onTap; // single button tap
  final EventStatus? status;
  final String? starImagePath;
  final bool showButton;
  final bool showTwoButtons; // toggle for two buttons
  final VoidCallback? onFirstButtonTap; // first button tap
  final String firstButtonText; // For first button
  final VoidCallback? onSecondButtonTap; // second button tap
  final String? price; // optional price
  final String? buttonLabel;
  final LoopinButtonVariant buttonVariant;

  const InviteEventCard({
    super.key,
    required this.badgeText,
    required this.imageUrls,
    required this.title,
    required this.dateLocation,
    required this.hostName,
    required this.isEnded,
    required this.imagePath,
    this.onTap,
    this.status,
    this.starImagePath,
    this.showButton = true,
    this.showTwoButtons = false,
    this.onFirstButtonTap,
    this.onSecondButtonTap,
    this.firstButtonText = "Going!", // default
    this.price,
    this.buttonLabel,
    this.buttonVariant = LoopinButtonVariant.primary,
  });

  @override
  State<InviteEventCard> createState() => _InviteEventCardState();
}

class _InviteEventCardState extends State<InviteEventCard> {
  final RxInt currentImageIndex = 0.obs;
  Timer? timer;
  bool isVisible = true;

  @override
  void initState() {
    super.initState();

    // 🔄 Background images timer
    timer = Timer.periodic(const Duration(seconds: 3), (t) {
      setState(() {
        currentImageIndex.value =
            (currentImageIndex.value + 1) % widget.imageUrls.length;
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _hideCard() {
    setState(() {
      isVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double baseHeight = 448;
    if (!isVisible) return const SizedBox.shrink(); // <-- hide card

    bool showBanner =
        widget.status == EventStatus.hostedByCurrentUser ||
        widget.status == EventStatus.attending;

    bool shouldShowButton = widget.showButton;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
     child: Container(
  width: double.infinity,
  height: 401, // fixed height
  margin: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(28),
    color: Colors.white,
    border: Border.all(
      color: const Color.fromRGBO(107, 97, 97, 1),
      width: 2,
    ),
  ),
  child: Stack(
    children: [
      // Background image
      Obx(
        () => ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Image.asset(
            widget.imageUrls[currentImageIndex.value],
            width: double.infinity,
            height: 401,
            fit: BoxFit.cover,
          ),
        ),
      ),
      // Add other overlay widgets here if needed
            // Banner
            if (widget.status == EventStatus.hostedByCurrentUser)
              _buildBanner(
                colors: [
                  const Color.fromRGBO(148, 84, 239, 1),
                  const Color.fromRGBO(85, 15, 186, 1),
                ],
                text: "Your Event is Live!",
                icon: "assets/icons/Rectangle 1.png",
              )
            else if (widget.status == EventStatus.attending)
              _buildBanner(
                colors: [
                  const Color.fromRGBO(255, 145, 41, 1),
                  const Color.fromRGBO(255, 94, 0, 1),
                ],
                text: "You're Going!",
                icon: "assets/icons/Fire.png",
              ),

            // ⭐ Star + Badge Row with Glassmorphism (for all events with badges)
            if (widget.badgeText.isNotEmpty)
              Positioned(
                top: 15,
                left: 0,
                right: 0,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 10.0,
                        sigmaY: 10.0,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                       decoration: BoxDecoration(
  color: const Color.fromARGB(77, 7, 7, 7), // more transparent
  borderRadius: BorderRadius.circular(10),
  border: Border.all(
    color: Colors.white.withOpacity(0.1),
    width: 1,
  ),
),

                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (widget.starImagePath != null)
                              Image.asset(
                                widget.starImagePath!,
                                height: 24,
                                width: 24,
                              ),
                            if (widget.starImagePath != null)
                              const SizedBox(width: 5),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                widget.badgeText,
                                style: GoogleFonts.bricolageGrotesque(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.85),
                    ],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.dateLocation,
                      style: GoogleFonts.bricolageGrotesque(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Hosted by ${widget.hostName}",
                      style: GoogleFonts.bricolageGrotesque(
                        color: Colors.white,
                        fontSize: 11.34,
                      ),
                    ),
                    const SizedBox(height: 6),
                    shouldShowButton ? _buildActionButtons() : const SizedBox.shrink(),
                    const SizedBox(height: 6),
                    Obx(() {
                      int dotCount = widget.imageUrls.length >= 3
                          ? widget.imageUrls.length
                          : 3;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(dotCount, (index) {
                          bool isActive =
                              currentImageIndex.value % dotCount == index;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 6,
                            width: isActive ? 16 : 10,
                            decoration: BoxDecoration(
                              color: isActive ? Colors.white : Colors.grey,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleButton() {
    if (widget.buttonLabel != null && widget.buttonLabel!.isNotEmpty) {
      return SizedBox(
        width: double.infinity,
        child: LoopinCtaButton(
          label: widget.buttonLabel!,
          variant: widget.buttonVariant,
          onPressed: widget.onTap,
          width: double.infinity,
        ),
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        padding: const EdgeInsets.all(2),
        child: Image.asset(
          widget.imagePath,
          height: 52,
          width: double.infinity,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (widget.showTwoButtons) {
      return Row(
        children: [
          Expanded(
            child: LoopinCtaButton(
              width: double.infinity,
              label: widget.price != null
                  ? "${widget.firstButtonText} ₹ ${widget.price}"
                  : widget.firstButtonText,
              onPressed: () {
                Get.to(() => EventDetail(
                      title: widget.title,
                      date: DateFormat('EEEE d, MMMM yyyy').format(DateTime.now().subtract(const Duration(hours: 48))),
                      time: "5:PM",
                      hostName: widget.hostName,
                      hostImage: "assets/images/avatar.png",
                      eventImage: widget.imageUrls.isNotEmpty
                          ? widget.imageUrls[0]
                          : "assets/images/placeholder.png",
                      venue: "Bastian Garden City",
                      fullAddress: "Bastian Garden City, Dehradun, Uttarakhand",
                      aboutEvent: "Event details will be shown here",
                      badgeText: widget.badgeText,
                      attendeesCount: 24,
                      attendeeImages: const ["assets/images/avatar.png"],
                      isGoing: false,
                      price: widget.price,
                      starImagePath: widget.starImagePath,
                    ));
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: LoopinCtaButton(
              width: double.infinity,
              label: "Not Going :(",
              backgroundColor: Colors.transparent,
              borderColor: Colors.white.withOpacity(0.35),
              borderWidth: 1.0,
              textColor: Colors.white,
              onPressed: () {
                _hideCard();
                widget.onSecondButtonTap?.call();
              },
            ),
          ),
        ],
      );
    }
    return _buildSingleButton();
  }

  /// Common banner builder
  Widget _buildBanner({
    required List<Color> colors,
    required String text,
    required String icon,
  }) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          gradient: LinearGradient(colors: colors),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(icon, width: 50, height: 50),
            const SizedBox(width: 6),
            Text(
              text,
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// _DualActionButton removed after consolidating to LoopinCtaButton
