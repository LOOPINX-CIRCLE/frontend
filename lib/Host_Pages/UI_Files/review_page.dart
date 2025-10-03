// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/Host_Pages/Controller_files/event_cntroller.dart';
import 'package:text_code/Host_Pages/Controller_files/review_page_controller.dart';
import 'package:text_code/Host_Pages/Map_integration/map_implemtation.dart';
import 'package:text_code/Host_Pages/UI_Files/data_fetch_page_forreview.dart';
import 'package:text_code/Host_Pages/UI_Files/share_screen.dart';
import 'package:text_code/Reusable/text_Bricolage%20Grotesque_reusable.dart';
import 'package:text_code/Reusable/text_reusable.dart';

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
                        // User picked image
                        displayImage = Image.file(
                          controller.images[index],
                          width: 347,
                          height: 401,
                          fit: BoxFit.cover,
                        );
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
                              apiKey: "AIzaSyBAAPv0Z6CZUdjnphbj9XH7YR1Z2jOS684",
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
            onTap: () {
              // Decide which image to pass
              Widget imageToSend;

              if (controller.images.isNotEmpty &&
                  controller.images[0].path.isNotEmpty) {
                // ✅ user picked image
                imageToSend = Image.file(controller.images[0]);
              } else {
                // ✅ default image
                imageToSend = Image.asset(controller.defaultAssetImage);
              }
              controllerloc.resetEventData();
              Get.offAll(ShareScreen(imageWidget: imageToSend));

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
