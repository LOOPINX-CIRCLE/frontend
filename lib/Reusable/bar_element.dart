// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AnalyticsController extends GetxController {
  RxInt selectedTab =
      2.obs; // 0: Requested, 1: Accepted, 2: Event analytics (default selected)
}

class BarElement extends StatefulWidget {
  const BarElement({super.key});

  @override
  State<BarElement> createState() => _BarElementState();
}

class _BarElementState extends State<BarElement> {
  final AnalyticsController controller = Get.put(AnalyticsController());

  final List<String> tabs = ['Requested', 'Accepted', 'Event analytics'];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset("assets/icons/Icon v1.png", width: 40, height: 40),
              const Icon(Icons.close, color: Colors.white),
            ],
          ),
        ),
        const SizedBox(height: 15),

        /// TAB BAR SECTION
        Obx(
          () => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(tabs.length, (index) {
                bool isSelected = controller.selectedTab.value == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: GestureDetector(
                    onTap: () {
                      controller.selectedTab.value = index;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? Colors.white
                              : const Color.fromRGBO(255, 255, 255, 0.07),
                        ),
                      ),
                      child: Text(
                        tabs[index],
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isSelected ? Colors.white : Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
