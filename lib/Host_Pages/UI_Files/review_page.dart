// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:text_code/Host_Pages/Controller_files/event_cntroller.dart';
import 'package:text_code/Host_Pages/Controller_files/review_page_controller.dart';
import 'package:text_code/Host_Pages/Map_integration/map_implemtation.dart';
import 'package:text_code/Host_Pages/UI_Files/data_fetch_page_forreview.dart';
import 'package:text_code/Host_Pages/UI_Files/share_screen.dart';
import 'package:text_code/Reusable/text_Bricolage%20Grotesque_reusable.dart';
import 'package:text_code/Reusable/text_reusable.dart';
import 'package:text_code/core/services/event_create_service.dart';
import 'package:text_code/core/constants/env.dart';

class ReviewEventPage extends StatelessWidget {
  ReviewEventPage({super.key});
  final controller = Get.put(CoverImageController());
  final EventController controllerloc = Get.put(EventController());

  // Default image path
  final String defaultImage = "assets/images/Frame 1410136456.png";

  @override
  Widget build(BuildContext context) {
    final GlobalKey dropdownKey = GlobalKey();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: SizedBox(
              width: 50,
              height: 50,
              child: Icon(Icons.arrow_back, size: 24, color: Colors.white),
            ),
            onPressed: () => Get.back(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Image.asset(
                    "assets/images/button/progressbarrev.png",
                    height: 20,
                    // fit: BoxFit.fill,
                  ),
                ),
                Center(
                  child: TextBricolage(
                    FontWeight.normal,
                    "Review your Event",
                    20,
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  height: 401,
                  width: 347,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      // ✅ Decide which image to display
                      Widget displayImage;
                      if (controller.images.length > index &&
                          controller.images[index].path.isNotEmpty) {
                        // User picked image - Handle both mobile and web
                        if (kIsWeb) {
                          // For web, use Image.network with XFile
                          displayImage = FutureBuilder<Uint8List>(
                            future: controller.images[index].readAsBytes(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Image.memory(
                                  snapshot.data!,
                                  width: 347,
                                  height: 401,
                                  fit: BoxFit.cover,
                                );
                              } else {
                                return Container(
                                  color: Colors.grey.shade800,
                                  width: 347,
                                  height: 401,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                            },
                          );
                        } else {
                          // For mobile, use Image.file
                          displayImage = Image.file(
                            File(controller.images[index].path),
                            width: 347,
                            height: 401,
                            fit: BoxFit.cover,
                          );
                        }
                      } else if (index == 0) {
                        // Default image in 1st slot
                        displayImage = Image.asset(
                          defaultImage,
                          width: 347,
                          height: 401,
                          fit: BoxFit.cover,
                        );
                      } else {
                        // Empty grey box for other slots
                        displayImage = Container(
                          color: Colors.grey.shade800,
                          width: 347,
                          height: 401,
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Container(
                          width: 320,
                          height: 401,
                          decoration: BoxDecoration(
                            // color: Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child:
                                    displayImage, // ✅ Always show displayImage
                              ),

                              // Add/Change button
                              Positioned(
                                bottom: 10,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 10,
                                      sigmaY: 10,
                                    ),
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white
                                            .withOpacity(0.2),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          side: const BorderSide(
                                            color: Colors.white,
                                            width: 1,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16, // top & bottom padding
                                          horizontal:
                                              16, // left & right padding
                                        ),
                                      ),
                                      icon: Image.asset(
                                        "assets/icons/Gallery.png",
                                        width: 24,
                                        height: 24,
                                        color: Colors.white,
                                      ),
                                      label: CustomText(
                                        text:
                                            (controller.images.length > index ||
                                                index == 0)
                                            ? "Change Cover Image"
                                            : "Add Cover Image",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),

                                      onPressed: () =>
                                          controller.pickImage(index),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                // ✅ Counter (Default 1 when empty)
                ImageCounter(
                  currentIndex: (controller.images.isEmpty
                      ? 1
                      : controller.images.length),
                  total: 3,
                ),
                const SizedBox(height: 4),
                CustomText(
                  text: "You can add up to 3 cover images",
                  fontSize: 14,
                  color: Colors.grey,
                ),
                SizedBox(height: 30),
                EventDetailsCard(),
                SizedBox(height: 10),
                Obx(
                  () => Container(
                    width: MediaQuery.of(
                      context,
                    ).size.width, // ✅ full screen width
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/Ellipses 1.png"),
                        alignment: Alignment.topCenter, // image position
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Venu",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          controllerloc.mainLocationName.value.isNotEmpty
                              ? controllerloc.mainLocationName.value
                              : "Venue Name",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),

                        // const SizedBox(height: 4), // thoda gap niche
                        if (controllerloc.loaction.value.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: MapPreview(
                              placeName: controllerloc.loaction.value,
                              apiKey: Env.googleMapsApiKey,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Card(
                    color: Colors.transparent, // Make background transparent
                    elevation: 0.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: Colors.grey, // Border color
                        width: 1, // Border width
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FormLabel("Advance Settings", fontSize: 16),
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/icons/Ticker Star.png',
                                  width: 24,
                                  height: 24,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "Bring a Plus One",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow
                                        .ellipsis, // prevents overflow
                                  ),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: controller.decrement,
                                      child: Container(
                                        width: 23,
                                        height: 23,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.remove,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Obx(
                                      () => Text(
                                        controller.count.value.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    GestureDetector(
                                      onTap: controller.increment,
                                      child: Container(
                                        width: 23,
                                        height: 23,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20),
                          Container(
                            key: dropdownKey,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  "assets/icons/Users Group Two Rounded.png",
                                  width: 24,
                                  height: 24,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Who can Join",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                const Spacer(),

                                // 👇 Trigger
                                Obx(
                                  () => GestureDetector(
                                    onTap: () => controller.toggleDropdown(
                                      context,
                                      dropdownKey,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        top: 6,
                                      ), // 👈 neeche shift
                                      child: Row(
                                        children: [
                                          Text(
                                            controller.selectedGender.value,
                                            style: GoogleFonts.poppins(
                                              color: const Color(0xFF9C27B0),
                                              fontSize: 12,
                                            ),
                                          ),
                                          const Icon(
                                            Icons.keyboard_arrow_down,
                                            color: Color(0xFF9C27B0),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            );
          }),
        ),
      ),
      bottomNavigationBar: Container(
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
            onTap: () async {


              // Validate date and time are both selected
              String dateStr = controllerloc.date.value.trim();
              String timeStr = controllerloc.time.value.trim();
              if (dateStr.isEmpty || timeStr.isEmpty) {
                Get.snackbar('Error', 'Please select both date and time for your event.', backgroundColor: Colors.red, colorText: Colors.white);
                return;
              }

              // Normalize and parse time (support 12/24 hour, trim, add seconds if missing)
              String normTime = timeStr.replaceAll(RegExp(r'\s+'), '').toUpperCase();
              // If AM/PM present, convert to 24-hour
              String time24 = normTime;
              final ampmMatch = RegExp(r'^(\d{1,2}):(\d{2})(?::(\d{2}))?(AM|PM)$').firstMatch(normTime);
              if (ampmMatch != null) {
                int hour = int.parse(ampmMatch.group(1)!);
                int minute = int.parse(ampmMatch.group(2)!);
                int second = ampmMatch.group(3) != null ? int.parse(ampmMatch.group(3)!) : 0;
                String ampm = ampmMatch.group(4)!;
                if (ampm == 'PM' && hour < 12) hour += 12;
                if (ampm == 'AM' && hour == 12) hour = 0;
                time24 = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
              } else {
                // If only HH:mm, add seconds
                if (RegExp(r'^\d{1,2}:\d{2}$').hasMatch(time24)) {
                  time24 += ':00';
                }
              }

              // Parse date and time to ISO 8601
              DateTime? parsedDateTime;
              try {
                List<String> dateParts = dateStr.split('/');
                if (dateParts.length == 3) {
                  String formattedDate = '${dateParts[2]}-${dateParts[1].padLeft(2, '0')}-${dateParts[0].padLeft(2, '0')}';
                  String fullDateTime = formattedDate; 'T' + time24;
                  parsedDateTime = DateTime.parse(fullDateTime);
                }
              } catch (_) {}
              if (parsedDateTime == null) {
                Get.snackbar('Error', 'Invalid date or time format.\nDate: $dateStr\nTime: $timeStr\nNormalized: $time24', backgroundColor: Colors.red, colorText: Colors.white);
                return;
              }

              // Format as ISO 8601 with Z (UTC)
              String isoStartTime = parsedDateTime.toUtc().toIso8601String();
              if (!isoStartTime.endsWith('Z')) isoStartTime += 'Z';
              // Check if selected datetime is in the future
              if (!parsedDateTime.isAfter(DateTime.now())) {
                Get.snackbar('Error', 'Event start time must be in the future.', backgroundColor: Colors.red, colorText: Colors.white);
                return;
              }

              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );
              try {
                // Validate required fields before API call
                if (controllerloc.eventTitle.value.trim().isEmpty) {
                  Navigator.of(context).pop(); // Close loading
                  Get.snackbar('Error', 'Event title is required', backgroundColor: Colors.red, colorText: Colors.white);
                  return;
                }
                if (controllerloc.mainLocationName.value.trim().isEmpty) {
                  Navigator.of(context).pop(); // Close loading
                  Get.snackbar('Error', 'Venue name is required', backgroundColor: Colors.red, colorText: Colors.white);
                  return;
                }
                
                // Validate duration parsing
                String durationStr = controllerloc.duration.value.trim();
                // Remove "hr" suffix if present
                String durationNumStr = durationStr.replaceAll(RegExp(r'hr$|hours?$|h$', caseSensitive: false), '').trim();
                double? durationHours = double.tryParse(durationNumStr);
                
                if (durationStr.isEmpty || durationHours == null || durationHours <= 0) {
                  Navigator.of(context).pop(); // Close loading
                  Get.snackbar('Error', 'Event duration must be greater than 0 hours (currently: "$durationStr")', 
                    backgroundColor: Colors.red, colorText: Colors.white);
                  return;
                }

                // Prepare cover images (no compression, allow any image)
                List<XFile> coverImages = controller.images.where((f) => f.path.isNotEmpty).toList();
                String isoStartTime = parsedDateTime.toUtc().toIso8601String();

                // Convert XFile to proper format for service
                List<dynamic> serviceImages = [];
                for (XFile xfile in coverImages) {
                  if (kIsWeb) {
                    // For web: convert XFile to map format
                    final bytes = await xfile.readAsBytes();
                    serviceImages.add({
                      'bytes': bytes,
                      'filename': xfile.name,
                      'mimeType': xfile.mimeType ?? 'image/jpeg',
                    });
                  } else {
                    // For mobile: convert XFile to File
                    serviceImages.add(File(xfile.path));
                  }
                }

                // Determine if event is paid (currently defaulting to free)
                bool isPaid = false; // Future: Add UI toggle for paid/free events
                double ticketPrice = isPaid ? double.tryParse(controllerloc.ticketPrice.value) ?? 0.0 : 0.0;

                // Call event creation API
                final eventService = EventCreateService();
                final result = await eventService.createEvent(
                  title: controllerloc.eventTitle.value,
                  description: controllerloc.description.value,
                  startTime: isoStartTime,
                  durationHours: durationHours, // Use already parsed and validated value
                  venueName: controllerloc.mainLocationName.value, // ✅ Required venue_name field
                  locationAddress: controllerloc.loaction.value,
                  locationCity: controllerloc.mainLocationName.value,
                  locationLatitude: controllerloc.latitude.value,
                  locationLongitude: controllerloc.longitude.value,
                  locationPlaceId: controllerloc.locationPlaceId.value,
                  locationCountryCode: controllerloc.locationCountryCode.value,
                  maxCapacity: int.tryParse(controllerloc.capacity.value) ?? 0,
                  isPaid: isPaid,
                  ticketPrice: ticketPrice,
                  allowPlusOne: true, // Set as needed
                  gstNumber: "", // Set as needed
                  allowedGenders: "all", // Set as needed
                  status: "draft", // Set as needed
                  isPublic: true, // Set as needed
                  eventInterestIds: "[]", // Empty array for now
                  coverImages: serviceImages, // Use properly formatted images
                );
                Navigator.of(context).pop(); // Close loading
                Get.snackbar('Success', 'Event posted successfully!', backgroundColor: Colors.green, colorText: Colors.white);
                // Navigate to share screen
                Widget imageToSend;
                if (controller.images.isNotEmpty && controller.images[0].path.isNotEmpty) {
                  if (kIsWeb) {
                    // For web, use FutureBuilder to load XFile as bytes
                    imageToSend = FutureBuilder<Uint8List>(
                      future: controller.images[0].readAsBytes(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Image.memory(snapshot.data!);
                        }
                        return Image.asset(controller.defaultAssetImage);
                      },
                    );
                  } else {
                    // For mobile, convert XFile to File
                    imageToSend = Image.file(File(controller.images[0].path));
                  }
                } else {
                  imageToSend = Image.asset(controller.defaultAssetImage);
                }
                controllerloc.resetEventData();
                Get.offAll(ShareScreen(imageWidget: imageToSend));
              } catch (e) {
                Navigator.of(context).pop(); // Close loading
                String errorMessage = e.toString();
                
                // Parse API error messages for better user feedback
                if (errorMessage.contains('TITLE_REQUIRED')) {
                  errorMessage = 'Event title is required';
                } else if (errorMessage.contains('VENUE_NAME_REQUIRED')) {
                  errorMessage = 'Venue name is required';
                } else if (errorMessage.contains('INVALID_DURATION')) {
                  errorMessage = 'Event duration must be greater than zero';
                } else if (errorMessage.contains('START_TIME_IN_PAST')) {
                  errorMessage = 'Event start time cannot be in the past';
                } else if (errorMessage.contains('INVALID_DATETIME_FORMAT')) {
                  errorMessage = 'Invalid date or time format';
                } else if (errorMessage.contains('Authentication required')) {
                  errorMessage = 'Please login to create an event';
                } else if (errorMessage.contains('venue_name')) {
                  errorMessage = 'Venue name is required for the event';
                } else if (errorMessage.contains('title')) {
                  errorMessage = 'Please provide a valid event title';
                } else {
                  errorMessage = 'Failed to create event. Please check your details and try again.';
                }
                
                Get.snackbar('Error', errorMessage, 
                  backgroundColor: Colors.red, 
                  colorText: Colors.white,
                  duration: Duration(seconds: 4));
              }

              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => ShareScreen(imageWidget: imageToSend),
              //   ),
              // ).whenComplete(() {
              //   // ✅ Jab ShareScreen se back aayenge to ye chalega
              //   // controller.();
              //   controllerloc.resetEventData();
              // });
            },

            child: Image.asset(
              "assets/images/button/livebutton.png",
              alignment: Alignment.topCenter,
              height: 52,
            ),
          ),
        ),
      ),
    );
  }
}

// CustomText Widget
class CustomText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;

  const CustomText({
    super.key,
    required this.text,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w500,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }
}

// ImageCounter Widget
class ImageCounter extends StatelessWidget {
  final int currentIndex;
  final int total;

  const ImageCounter({
    super.key,
    required this.currentIndex,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 60,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "$currentIndex",
            style: const TextStyle(
              color: Colors.purple,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            "/",
            style: TextStyle(color: Colors.blueGrey, fontSize: 16),
          ),
          const SizedBox(width: 4),
          Text(
            "$total",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
