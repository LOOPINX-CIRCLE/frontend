// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/Host_Pages/Controller_files/detail_controller_file.dart';
import 'package:text_code/Host_Pages/Controller_files/event_cntroller.dart';
import 'package:text_code/Host_Pages/Map_integration/map_implemtation.dart';
import 'package:text_code/Host_Pages/UI_Files/capictiy_page.dart';
import 'package:text_code/Reusable/text_Bricolage%20Grotesque_reusable.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final EventController eventController = Get.put(EventController());
  late final HostPagesController controller;

  @override
  void initState() {
    super.initState();
    // ✅ Use Get.put to register and get the controller instance
    controller = Get.put<HostPagesController>(HostPagesController());
  }

  @override
  Widget build(BuildContext context) {
    // controller.resetFields(clearEventData: true);
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
            onPressed: () {
              // controller.resetFields(); // ✅ Reset fields on back

              Get.back();
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () {},
              // Get.offAllNamed(''), // Navigate to home or desired page
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        // padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // StepProgressBar(progress: 1),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Image.asset(
                "assets/images/detaillprocess.png",
                height: 12,
                width: double.infinity,
              ),
            ),

            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: TextBricolage(
                FontWeight.normal,
                "Tell us about your event",
                20,
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: Colors.transparent, // Make background transparent
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(
                    color: Colors.white24, // Border color
                    width: 1, // Border width
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    // vertical: 24,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormLabel("Event Title", fontSize: 16),
                      CustominputField(
                        controller: controller.titleController,
                        isEditable: controller.isEditable,
                        onTapIfNotEditable: controller.fillDemoData,
                        defaultText: "Event name",
                        iconPath: "assets/icons/Stars.png",
                      ),

                      FormLabel("Description", fontSize: 16),

                      descriptionInputField(controller),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: Colors.transparent, // Make background transparent
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(
                    color: Colors.white24, // Border color
                    width: 1, // Border width
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    // vertical: 16,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormLabel("Date", fontSize: 16),
                      Obx(
                        () => GestureDetector(
                          onTap: () => controller.selectDate(context),
                          // ✅ keyboard nahi khulega, auto focus ban
                          child: DecoratedInput(
                            iconPath: 'assets/icons/Calendar Mark.png',
                            hint: 'DD/MM/YYYY',
                            value: controller.date.value,
                            iconSize: 24,
                          ),
                        ),
                      ),

                      FormLabel("Time", fontSize: 16),
                      Obx(
                        () => GestureDetector(
                          onTap: () => controller.selectTime(context),
                          child: DecoratedInput(
                            hint: '7:00 PM',
                            value: controller.time.value,
                            iconPath: 'assets/icons/Clock Circle.png',
                          ),
                        ),
                      ),

                      FormLabel("Duration", fontSize: 16),
                      Obx(
                        () => GestureDetector(
                          onTap: controller.toggleDurationControls,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/icons/Hourglass.png',
                                  width: 24,
                                  height: 24,
                                  color: controller.duration.value.isNotEmpty
                                      ? Colors.white
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  controller.duration.value.isNotEmpty
                                      ? controller.duration.value
                                      : '3 Hr',
                                  style: GoogleFonts.poppins(
                                    color: controller.duration.value.isNotEmpty
                                        ? Colors.white
                                        : Colors.white54,
                                    fontSize: 14,
                                  ),
                                ),
                                Spacer(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildButton(
                                      Icons.remove,
                                      controller.decrementDuration,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        "${controller.durationInHours.value}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    _buildButton(
                                      Icons.add,
                                      controller.incrementDuration,
                                    ),
                                    SizedBox(width: 10),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      FormLabel("Location", fontSize: 16),
                      MapController(),
                      
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
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
                child: Obx(
                  () => GestureDetector(
                    onTap: () {
                      if (controller.isActive.value) {
                        Get.to(() => CapactiyPage());
                      }
                    },

                    child: Image.asset(
                      alignment: Alignment.topCenter,
                      controller.isActive.value
                          ? "assets/images/button/Button Active V2 (2).png"
                          : "assets/images/button/Button Active V2 (1).png",
                      height: 52,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 20, color: Colors.black),
      ),
    );
  }

  Widget descriptionInputField(HostPagesController controller) {
    return Obx(() {
      return Stack(
        children: [
          TextFormField(
            controller: controller.descController,
            focusNode: controller.descFocusNode,
            enabled: controller.isEditable1.value,
            style: GoogleFonts.poppins(color: Colors.white),
            maxLines: 5,
            minLines: 1,
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: 'Description',
              hintStyle: GoogleFonts.poppins(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.only(
                left: 48, // text shift right (space for icon)
                top: 12,
                right: 16,
                bottom: 12,
              ),
            ),
            onChanged: (value) {
              controller.update();
              controller.updateDescription(value);
            },
          ),

          // ✅ Fixed icon (will never move)
          Positioned(
            left: 12,
            top: 12,
            child: Image.asset(
              "assets/icons/List.png",
              width: 24,
              height: 24,
              color: Colors.white,
            ),
          ),
        ],
      );
    });
  }

  Widget decoratedInput(
    TextEditingController controller,
    RxBool isEditable, {
    required String defaultText,
    String? iconPath,
    double iconSize = 24,
    required VoidCallback onTapIfNotEditable,
    int? maxLines,
    int? minLines,
  }) {
    int? resolvedMinLines = minLines;
    int? resolvedMaxLines = maxLines;
    if (resolvedMaxLines != null &&
        resolvedMinLines != null &&
        resolvedMaxLines < resolvedMinLines) {
      resolvedMinLines = null;
    }

    return Obx(() {
      final isDefault = controller.text.trim() == defaultText;
      return TextFormField(
        controller: controller,
        minLines: resolvedMinLines ?? 1,
        maxLines: resolvedMaxLines,
        enabled: isEditable.value,
        keyboardType: TextInputType.multiline,
        readOnly: !isEditable.value,

        style: GoogleFonts.poppins(
          color: isDefault ? Colors.grey : Colors.white,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[900],
          prefixIcon: iconPath != null
              ? Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset(
                    iconPath,
                    width: iconSize,
                    height: iconSize,
                    color: isEditable.value ? Colors.white : Colors.grey,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      );
    });
  }

  Widget FormLabel(String title, {double fontSize = 14}) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget CustominputField({
    required TextEditingController controller,
    required RxBool isEditable,
    required VoidCallback onTapIfNotEditable,
    required String defaultText,
    String? iconPath,
    double iconSize = 24,
  }) {
    final HostPagesController hostController =
        Get.find(); // controller instance lo

    return Obx(() {
      final isDefault = controller.text.trim() == defaultText;
      return GestureDetector(
        onTap: () {
          if (!isEditable.value) {
            onTapIfNotEditable();
          }
          // ✅ Yahi pe button activate kar do
          hostController.isActive.value = true;
        },
        child: AbsorbPointer(
          absorbing: !isEditable.value,
          child: TextField(
            controller: controller,
            enabled: isEditable.value,
            style: GoogleFonts.poppins(
              color: isDefault ? Colors.grey : Colors.white,
            ),
            decoration: InputDecoration(
              hintText: "Event name",
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              prefixIcon: iconPath != null
                  ? Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Image.asset(
                        iconPath,
                        width: iconSize,
                        height: iconSize,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            onChanged: (value) {
              hostController.updateEventTitle(
                value,
              ); // ✅ EventController me save
              hostController.validateForm();
            },
          ),
        ),
      );
    });
  }
}

// ignore_for_file: use_super_parameters

class DecoratedInput extends StatelessWidget {
  final String hint;
  final String? value;
  final String? iconPath;
  final double iconSize;
  final bool isEditable;
  final Widget? suffix; // ✅ optional widget

  const DecoratedInput({
    Key? key,
    required this.hint,
    this.value,
    this.iconPath,
    this.iconSize = 24,
    this.isEditable = false,
    this.suffix, // ✅ constructor me add
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          if (iconPath != null)
            Image.asset(
              iconPath!,
              width: iconSize,
              height: iconSize,
              color: (value == null || value!.isEmpty)
                  ? Colors.grey
                  : Colors.white,
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              (value == null || value!.isEmpty) ? hint : value!,
              style: GoogleFonts.poppins(
                color: (value == null || value!.isEmpty)
                    ? Colors.white54
                    : Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          if (suffix != null) suffix!, // ✅ sirf tab show hoga jab diya ho
        ],
      ),
    );
  }
}
