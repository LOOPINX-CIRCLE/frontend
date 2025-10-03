// // ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';

// class EventCardsControllers extends GetxController {
//   var isEnded = false.obs;

//   void endEvent() {
//     isEnded.value = true;
//   }
// }

// // enum EventStatus { hostedByCurrentUser, attending, newEvent, ended }

// class ReuestedEventCard extends StatefulWidget {
//   final String badgeText;
//   final List<String> imageUrls;
//   final String title;
//   final String dateLocation;
//   final String hostName;
//   final bool isEnded;
//   final String imagePath; // for single button
//   final VoidCallback? onTap; // single button tap
//   // final EventStatus? status;
//   final String? starImagePath;
//   final String? downloadImagePath;
//   final bool showButton;
//   final bool showTwoButtons; // toggle for two buttons
//   final VoidCallback? onFirstButtonTap; // first button tap
//   final VoidCallback? onSecondButtonTap; // second button tap

//   const ReuestedEventCard({
//     super.key,
//     required this.badgeText,
//     required this.imageUrls,
//     required this.title,
//     required this.dateLocation,
//     required this.hostName,
//     required this.isEnded,
//     required this.imagePath,
//     this.onTap,
//     // this.status,
//     this.starImagePath,
//     this.downloadImagePath,
//     this.showButton = true,
//     this.showTwoButtons = false,
//     this.onFirstButtonTap,
//     this.onSecondButtonTap,
//   });

//   @override
//   State<ReuestedEventCard> createState() => _ReuestedEventCardState();
// }

// class _ReuestedEventCardState extends State<ReuestedEventCard> {
//   final RxInt currentImageIndex = 0.obs;
//   Timer? timer;
//   bool isVisible = true;

//   @override
//   void initState() {
//     super.initState();

//     // 🔄 Background images timer
//     timer = Timer.periodic(const Duration(seconds: 3), (t) {
//       setState(() {
//         currentImageIndex.value =
//             (currentImageIndex.value + 1) % widget.imageUrls.length;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     timer?.cancel();
//     super.dispose();
//   }

//   void _hideCard() {
//     setState(() {
//       isVisible = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!isVisible) return const SizedBox.shrink(); // <-- hide card

//     // bool showBanner =
//     //     widget.status == EventStatus.hostedByCurrentUser ||
//     //     widget.status == EventStatus.attending;

//     bool shouldShowButton = widget.showButton;

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//       child: Container(
//         width: double.infinity,
//         // height: showBanner ? baseHeight + 25 : baseHeight,
//         margin: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(28),
//           color: Colors.white,
//           border: Border.all(
//             color: const Color.fromRGBO(107, 97, 97, 1),
//             width: 2,
//           ),
//         ),
//         child: Stack(
//           children: [
//             // Background images
//             Obx(
//               () => ClipRRect(
//                 borderRadius: BorderRadius.circular(28),
//                 child: Image.asset(
//                   widget.imageUrls[currentImageIndex.value],
//                   width: double.infinity,
//                   height: double.infinity,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),

//             // Banner
//             // if (widget.status == EventStatus.hostedByCurrentUser)
//             //   _buildBanner(
//             //     colors: [
//             //       const Color.fromRGBO(148, 84, 239, 1),
//             //       const Color.fromRGBO(85, 15, 186, 1),
//             //     ],
//             //     text: "Your Event is Live!",
//             //     icon: Icons.star,
//             //   )
//             // else if (widget.status == EventStatus.attending)
//             //   _buildBanner(
//             //     colors: [
//             //       const Color.fromRGBO(255, 145, 41, 1),
//             //       const Color.fromRGBO(255, 94, 0, 1),
//             //     ],
//             //     text: "You're Going!",
//             //     icon: Icons.check_circle,
//             //   ),

//             // ⭐ Star + Badge Row
//             if (widget.isEnded)
//               Positioned(
//                 top: 15,
//                 left: 60,
//                 child: Row(
//                   children: [
//                     // if (showBanner) const SizedBox(height: 120),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 5,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.5),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.max,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           if (widget.starImagePath != null)
//                             Image.asset(
//                               widget.starImagePath!,
//                               height: 24,
//                               width: 24,
//                             ),
//                           if (widget.starImagePath != null)
//                             const SizedBox(width: 5),
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Text(
//                               widget.badgeText,
//                               style: GoogleFonts.bricolageGrotesque(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(width: 20),

//                     if (widget.downloadImagePath != null)
//                       Container(
//                         padding: const EdgeInsets.all(4),
//                         decoration: BoxDecoration(
//                           color: Colors.black.withOpacity(0.5),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Image.asset(
//                           widget.downloadImagePath!,
//                           height: 24,
//                           width: 24,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                   ],
//                 ),
//               ),

//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       widget.title,
//                       style: GoogleFonts.bricolageGrotesque(
//                         fontSize: 34,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       widget.dateLocation,
//                       style: GoogleFonts.bricolageGrotesque(
//                         color: Colors.white,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       "Hosted by ${widget.hostName}",
//                       style: GoogleFonts.bricolageGrotesque(
//                         color: Colors.white,
//                         fontSize: 11.34,
//                       ),
//                     ),
//                     const SizedBox(height: 10),

//                     // ✅ Button(s)
//                     shouldShowButton
//                         ? (widget.showTwoButtons
//                               ? Row(
//                                   children: [
//                                     Expanded(
//                                       child: GestureDetector(
//                                         onTap: widget.onFirstButtonTap,
//                                         child: Container(
//                                           height: 56,
//                                           decoration: BoxDecoration(
//                                             color: Colors.black,
//                                             borderRadius: BorderRadius.circular(
//                                               12,
//                                             ),
//                                           ),
//                                           child: Center(
//                                             child: Text(
//                                               "Going",
//                                               style:
//                                                   GoogleFonts.bricolageGrotesque(
//                                                     color: Colors.white,
//                                                     fontWeight: FontWeight.w600,
//                                                     fontSize: 16,
//                                                   ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(width: 12),
//                                     Expanded(
//                                       child: GestureDetector(
//                                         onTap: () {
//                                           _hideCard(); // hide card
//                                           if (widget.onSecondButtonTap != null)
//                                             widget.onSecondButtonTap!();
//                                         },
//                                         child: Container(
//                                           height: 56,
//                                           decoration: BoxDecoration(
//                                             color: Colors.black,
//                                             borderRadius: BorderRadius.circular(
//                                               12,
//                                             ),
//                                           ),
//                                           child: Center(
//                                             child: Text(
//                                               "Not Going",
//                                               style:
//                                                   GoogleFonts.bricolageGrotesque(
//                                                     color: Colors.white,
//                                                     fontWeight: FontWeight.w600,
//                                                     fontSize: 16,
//                                                   ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 )
//                               : GestureDetector(
//                                   onTap: widget.onTap,
//                                   child: Image.asset(
//                                     widget.imagePath,
//                                     height: 56,
//                                     width: double.infinity,
//                                   ),
//                                 ))
//                         : const SizedBox.shrink(),

//                     const SizedBox(height: 10),

//                     // 🔘 Dots indicator
//                     Obx(
//                       () => Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: List.generate(widget.imageUrls.length, (
//                           index,
//                         ) {
//                           bool isActive = currentImageIndex.value == index;
//                           return Container(
//                             margin: const EdgeInsets.symmetric(horizontal: 4),
//                             height: 6,
//                             width: isActive ? 16 : 10,
//                             decoration: BoxDecoration(
//                               color: isActive ? Colors.white : Colors.grey,
//                               borderRadius: BorderRadius.circular(3),
//                             ),
//                           );
//                         }),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
