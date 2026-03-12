// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:text_code/Home_pages/UI_Design/eventdetail.dart';
import 'package:text_code/Reusable/loopin_cta_button.dart';
import 'package:text_code/Reusable/smart_image.dart';

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
  final bool? isPaid; // whether event is paid
  final String? buttonLabel;
  final LoopinButtonVariant buttonVariant;
  final VoidCallback? onUploadTap; // upload icon tap callback
  // When true, render a special "View ticket" style button with icon
  final bool isViewTicketButton;

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
    this.isPaid,
    this.buttonLabel,
    this.buttonVariant = LoopinButtonVariant.primary,
    this.onUploadTap,
    this.isViewTicketButton = false,
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

  /// Helper function to build image from network URL or asset
  Widget _buildImage(String image) {
    return SmartImage(
      imagePath: image,
      width: double.infinity,
      height: 401,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink(); // hide card when dismissed

    // Whether main CTA buttons are shown at the bottom
    final bool shouldShowButton = widget.showButton;

    // Build the core event card
    Widget card = Container(
      width: double.infinity,
      height: 401, // fixed height
      // No top margin so the card can overlap the banner cleanly
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
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
              child: _buildImage(widget.imageUrls[currentImageIndex.value]),
            ),
          ),

          // Price tag, badge pill and upload icon row
          Positioned(
            top: 15,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Price Tag (Left Side)
                // Hide for: ended, "Deadline Has Passed", attending (ticket generated),
                // and events hosted by current user.
                if (!widget.isEnded &&
                    widget.badgeText != "Deadline Has Passed" &&
                    widget.status != EventStatus.attending &&
                    widget.status != EventStatus.hostedByCurrentUser)
                  ClipRRect(
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
                          color: const Color.fromARGB(77, 7, 7, 7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          (widget.isPaid == true && widget.price != null)
                              ? "₹ ${(double.tryParse(widget.price!) ?? 0).toInt()}"
                              : "Free",
                          style: const TextStyle(
                            fontFamily: 'ClashDisplay',
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Badge (center) – hidden for events hosted by current user
                if (widget.badgeText.isNotEmpty &&
                    widget.status != EventStatus.hostedByCurrentUser)
                  Expanded(
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
                              color: widget.badgeText == "Your Event is Live!"
                                  ? const Color(0xFF8B5CF6).withOpacity(0.8)
                                  : const Color.fromARGB(77, 7, 7, 7),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color:
                                    widget.badgeText == "Your Event is Live!"
                                        ? const Color(0xFF8B5CF6)
                                            .withOpacity(0.5)
                                        : Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (widget.starImagePath != null &&
                                    widget.badgeText != "Your Event is Live!")
                                  Image.asset(
                                    widget.starImagePath!,
                                    height: 24,
                                    width: 24,
                                  ),
                                if (widget.starImagePath != null &&
                                    widget.badgeText != "Your Event is Live!")
                                  const SizedBox(width: 5),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0),
                                  child: Text(
                                    widget.badgeText,
                                    style: const TextStyle(
                                      fontFamily: 'ClashDisplay',
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  const Spacer(),

                // Upload icon (right)
                // Hide for: ended, "Deadline Has Passed", attending (ticket generated),
                // and events hosted by current user.
                if (!widget.isEnded &&
                    widget.badgeText != "Deadline Has Passed" &&
                    widget.status != EventStatus.attending &&
                    widget.status != EventStatus.hostedByCurrentUser)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 10.0,
                        sigmaY: 10.0,
                      ),
                      child: GestureDetector(
                        onTap: widget.onUploadTap,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(77, 7, 7, 7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Image.asset(
                            "assets/icons/Upload Minimalistic.png",
                            height: 24,
                            width: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Bottom gradient, title, details and buttons
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
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.dateLocation,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'ClashDisplay',
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Hosted by ${widget.hostName}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'ClashDisplay',
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  shouldShowButton
                      ? _buildActionButtons()
                      : const SizedBox.shrink(),
                  const SizedBox(height: 6),
                  Obx(() {
                    int dotCount =
                        widget.imageUrls.length >= 3 ? widget.imageUrls.length : 3;
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
    );

    // Optional orange banner above the card
    Widget? banner;
    if (widget.status == EventStatus.hostedByCurrentUser) {
      banner = _buildBanner(
        colors: const [
          Color.fromRGBO(148, 84, 239, 1),
          Color.fromRGBO(85, 15, 186, 1),
        ],
        text: "Your Event is Live!",
        icon: "assets/icons/Rectangle 1.png",
      );
    } else if (widget.status == EventStatus.attending) {
      banner = _buildBanner(
        colors: const [
          Color.fromRGBO(255, 145, 41, 1),
          Color.fromRGBO(255, 94, 0, 1),
        ],
        text: "You're Going!",
        icon: "assets/icons/Fire.png",
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (banner != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: banner,
            ),
          if (banner != null)
            Transform.translate(
              // Pull the card up so it overlaps the orange banner
              // by roughly 10px as per design.
              offset: const Offset(0, -14),
              child: card,
            )
          else
            card,
        ],
      ),
    );
  }

  Widget _buildSingleButton() {
    // For both "View request" and "View ticket" we use the same CTA style
    // (no icon inside the button).
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
              // Let the parent (HomePages) decide what happens on tap.
              onPressed: widget.onFirstButtonTap,
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
                // Delegate second-button behavior to parent if provided.
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28.361),
          topRight: Radius.circular(28.361),
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
        gradient: RadialGradient(
          center: const Alignment(0.499, 0),
          radius: 0.52,
          colors: colors,
          stops: const [0.0, 1.0],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 2,
        ),
      ),
      // Orange banner behind the event card
      // The card overlaps this by ~10px for the "peeking" effect.
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(icon, width: 35, height: 35),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'ClashDisplay',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// _DualActionButton removed after consolidating to LoopinCtaButton
