import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/Home_pages/UI_Design/home_page.dart';
import 'package:text_code/Host_Pages/Controller_files/controller_chooding.dart';
import 'package:text_code/Host_Pages/Controller_files/detail_controller_file.dart';
import 'package:text_code/Host_Pages/Controller_files/event_cntroller.dart';
import 'package:text_code/Host_Pages/UI_Files/detail_page.dart';
import 'package:text_code/Reusable/text_Bricolage%20Grotesque_reusable.dart';

class ChoosingTheme extends StatelessWidget {
  ChoosingTheme({super.key});

  final ChoosingThemeController controller = Get.put(ChoosingThemeController());
  final EventController eventController = Get.put(
    EventController(),
  ); // ✅ Inject EventController

  @override
  Widget build(BuildContext context) {
    // controller.resetSelection();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: SizedBox(
              height: 24,
              child: Icon(Icons.arrow_back, color: Colors.white, weight: 24),
            ),
            onPressed: () {
              controller.resetSelection();

              Get.back();
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () {
                controller.resetSelection();

                HomePages();
              },
              // Get.offAllNamed(''), // Navigate to home or desired page
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset("assets/images/Rectangle 39.png", height: 11),
            SizedBox(height: 15),

            TextBricolage(
              FontWeight.normal,
              "Set the mood, What are we hosting?",
              20,
            ),

            SizedBox(height: 10),
            Expanded(
              child: Obx(
                () => Wrap(
                  spacing: 8,
                  runSpacing: 12,
                  children: List.generate(controller.tags.length, (index) {
                    final isSelected = controller.isSelecteds(index);
                    return GestureDetector(
                      onTap: () {
                        controller.selectedIndex.value =
                            index; // ✅ select index
                        controller.isActive.value = true; // ✅ button active
                        eventController.experienceType.value =
                            controller.tags[index]; // ✅ save eventController me
                      },

                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.grey[500],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          controller.tags[index],
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            SizedBox(height: 60),
            Obx(
              () => GestureDetector(
                onTap: () {
                  if (controller.isActive.value) {
                    if (Get.isRegistered<HostPagesController>()) {
                      Get.delete<HostPagesController>();
                    }
                    Get.to(
                      () => const DetailPage(),
                      binding: BindingsBuilder(() {
                        Get.put(HostPagesController());
                      }),
                    );
                  }
                },
                child: Image.asset(
                  controller.isActive.value
                      ? "assets/images/button/Button Active V2 (2).png" // Active
                      : "assets/images/button/Button Active V2 (1).png", // Inactive
                  height: 52,
                ),
              ),
            ),

            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
