// ignore_for_file: must_be_immutable, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/Active/last_paeg.dart';
import 'package:text_code/Reusable/bar_element.dart';
import 'package:text_code/Reusable/ticketcard.dart';
import 'package:text_code/Active/controller/active_contoller.dart';

class AnalyticsPage extends StatelessWidget {
  final controller = Get.put(BankController());

  AnalyticsPage({super.key});
  bool isActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          // color: Colors.black,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                "assets/images/empty state new image.png",
              ), // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                BarElement(),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  child: Card(
                    color: Colors.transparent, // Make background transparent
                    elevation: 0.5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 24,
                      ),
                      child: Column(
                        children: [
                          Cardresuable(
                            "Ticket Sold",
                            "150",
                            "assets/icons/Featured icon.png",
                          ),
                          SizedBox(height: 4),
                          Cardresuable(
                            "Total Revenue",
                            "150,00",
                            "assets/icons/Featured icon (1).png",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  child: Card(
                    color: Colors.transparent, // Make background transparent
                    elevation: 0.5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 24,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              "Ticket Category Breakdown",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          TicketCard(
                            title: "Stag",
                            subtitle: "50 tickets",
                            price: "50,000",
                          ),
                          SizedBox(height: 4),
                          TicketCard(
                            title: "Women",
                            subtitle: "50 tickets",
                            price: "50,000",
                          ),
                          SizedBox(height: 4),
                          TicketCard(
                            title: "couple",
                            subtitle: "50 tickets",
                            price: "50,000",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  child: Card(
                    color: Color.fromRGBO(54, 53, 53, 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pay out information",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          rowReusable("Total revenue", "150,000"),
                          rowReusable("Platform fee 10%", "-35,000"),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF180047), // Dark purple
                                  Color.fromARGB(255, 89, 1, 182), // End color
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey, // Border color
                                width: 1, // Border thickness
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Net payout",
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "115,000",
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Image.asset(
                                "assets/icons/Shield Star.png",
                                height: 30,
                                width: 30,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Your earnings are secured by Loopin",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        backgroundColor: const Color.fromARGB(255, 34, 34, 34),
                        builder: (context) => SingleChildScrollView(
                          padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 24,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 4,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Add bank account",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 24),
                              buildCustomTextField(
                                label: "Account Holder Name",
                                controller: controller.nameController,
                                onChanged: (_) => controller.checkFields(),
                              ),
                              buildCustomTextField(
                                label: "Enter Bank Name",
                                controller: controller.bankController,
                                onChanged: (_) => controller.checkFields(),
                              ),
                              buildCustomTextField(
                                label: "Enter Account Number",
                                controller: controller.accountController,
                                onChanged: (_) {
                                  controller.checkFields();
                                },
                              ),
                              Obx(
                                () => buildCustomTextField(
                                  label: "Confirm Account Number",
                                  controller:
                                      controller.confirmAccountController,
                                  showError: controller.isMismatch.value,
                                  isRedLabel: controller.isMismatch.value,
                                  errorText: controller.isMismatch.value
                                      ? "Account numbers don't match"
                                      : null,
                                  onChanged: (_) {
                                    controller
                                        .checkMatch(); // ✅ check if both numbers match
                                    controller.checkFields();
                                  },
                                ),
                              ),
                              buildCustomTextField(
                                label: "IFSC CODE",
                                controller: controller.ifscController,
                                onChanged: (_) => controller.checkFields(),
                              ),
                              const SizedBox(height: 20),
                              Obx(
                                () => GestureDetector(
                                  onTap: () {
                                    controller.checkMatch();
                                    controller.checkFields();

                                    if (controller.isActive.value) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LastPaeg(),
                                        ),
                                      );
                                    }
                                  },
                                  child: Image.asset(
                                    controller.isActive.value
                                        ? "assets/images/button (3).png" // ✅ Active image
                                        : "assets/images/submitbut.png", // ❌ Inactive image
                                    height: 52,
                                  ),
                                ),
                              ),
                              SizedBox(height: 40),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Image.asset(
                      "assets/images/button (4).png",
                      height: 52,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCustomTextField({
    required String label,
    required TextEditingController controller,
    bool showError = false,
    String? errorText,
    bool isRedLabel = false,
    Function(String)? onChanged, // ✅ new parameter
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isRedLabel ? Colors.red : Colors.grey[400],
            ),
          ),
          TextField(
            controller: controller,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
            cursorColor: Colors.white,
            onChanged: onChanged, // ✅ connect here
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: showError ? Colors.red : Colors.white24,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: showError ? Colors.red : Colors.white,
                ),
              ),
            ),
          ),
          if (showError && errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                errorText,
                style: GoogleFonts.poppins(color: Colors.red, fontSize: 12),
              ),
            ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget Cardresuable(String text, String text1, String assestpath) {
    return Card(
      color: Color.fromRGBO(33, 32, 32, 1),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      text1,
                      style: GoogleFonts.bricolageGrotesque(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Image.asset(assestpath, width: 40, height: 40, fit: BoxFit.contain),
          ],
        ),
      ),
    );
  }

  Widget rowReusable(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
              ),
            ),
            Text(
              value,
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(color: Colors.grey, thickness: 0.5),
        const SizedBox(height: 8),
      ],
    );
  }
}
