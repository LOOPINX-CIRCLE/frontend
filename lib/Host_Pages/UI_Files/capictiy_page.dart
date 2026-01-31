// ignore_for_file: deprecated_member_use, depend_on_referenced_packages, non_constant_identifier_names, must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/Host_Pages/Controller_files/capicity_cntoller.dart';
import 'package:text_code/Host_Pages/Controller_files/event_cntroller.dart';
import 'package:text_code/Host_Pages/UI_Files/detail_page.dart';
import 'package:text_code/Host_Pages/UI_Files/review_page.dart';
import 'package:text_code/Reusable/text_Bricolage%20Grotesque_reusable.dart';
import 'package:text_code/Reusable/text_reusable.dart';

class CapactiyPage extends StatelessWidget {
  CapactiyPage({super.key});
  final CapacityController controller = Get.put(CapacityController());
  final EventController eventController = Get.put(EventController());
  double? totalAmount;
  double? guestFee;
  @override
  Widget build(BuildContext context) {
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
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Image.asset(
                "assets/images/capicityprocess.png",
                height: 12,
                width: double.infinity,
              ),
            ),
            SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: TextBricolage(
                FontWeight.normal,
                "What about the capacity and pricing ?",
                20,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormLabel("Capacity", fontSize: 16),
                      DecoratedInputs(
                        hint: "100",
                        iconPath: "assets/icons/Users Group Two Rounded.png",
                        controller: controller.capacityController,
                        onChanged: controller.updateCapacity,
                      ),

                      FormLabel("Free ticket", fontSize: 16),
                      DecoratedInputs(
                        hint: "Free",
                        iconPath: "assets/icons/Ticker Star.png",
                        suffix: Obx(
                          () => Switch(
                            value: controller.isFreeTicket.value,
                            onChanged: controller.toggleIsFree,
                            activeColor: Colors.purple,
                            inactiveThumbColor: Colors.grey,
                          ),
                        ),
                      ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormLabel("Ticket Price", fontSize: 16),
                      Obx(() => Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Image.asset(
                              "assets/icons/Ticker Star.png",
                              color: Colors.grey,
                              width: 24,
                              height: 24,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: controller.ticketPriceController,
                                keyboardType: TextInputType.number,
                                enabled: !controller.isFreeTicket.value, // Disable if free
                                onChanged: controller.updateTicketPrice,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: controller.isFreeTicket.value ? Colors.grey : Colors.white,
                                ),
                                decoration: InputDecoration(
                                  hintText: "0",
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),

                      SizedBox(height: 10),
                      reusableText(
                        "You can set a ticket price for your event, and guests will pay as they confirm",
                        9,
                        Colors.white70,
                      ),

                      SizedBox(height: 10),
                      DecoratedInput(
                        hint: "Have a GST number?",
                        suffix: Obx(
                          () => Switch(
                            value: controller.hasGSTNumber.value,
                            onChanged: controller.toggleHasGSTNumber,
                            activeColor: Colors.purple,
                            inactiveThumbColor: Colors.grey,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      reusableText(
                        "Guest Platform fee: 10%",
                        14,
                        Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      SizedBox(height: 40),
                      Obx(
                        () => rowreusable(
                          title: "Guest Pays",
                          value: controller.guestPaysPerTicket,
                          context: context,
                          breakdownTitle: "Guest Price Breakdown",
                          breakdownWidget: _buildGuestBreakdown(),
                        ),
                      ),

                      SizedBox(height: 10),
                      Obx(
                        () => rowreusable(
                          title: "Your earnings",
                          value: controller.estimatedEarnings,
                          context: context,
                          breakdownTitle: "Your Earnings Breakdown",
                          breakdownWidget: _buildEarningsBreakdown(),
                        ),
                      ),

                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              height: 120,
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
                    onTap: controller.isActive.value
                        ? () {
                            Get.to(() => ReviewEventPage());
                          }
                        : null, // ❌ inactive hone par disable
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

  // The rest of the CapactiyPage class...

  Widget rowreusable({
    required String title,
    required double value,
    required BuildContext context,
    required String breakdownTitle,
    required Widget breakdownWidget, // ✅ naya parameter
  }) {
    final currencyFormatter = NumberFormat("#,##0.00", "en_IN");

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
        ),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: const Color(0xFF222222),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => Container(
                padding: const EdgeInsets.all(16),
                height: 330,
                child: breakdownWidget,
              ),
            );
          },
          child: Row(
            children: [
              Image.asset(
                "assets/icons/Rupee (INR).png",
                height: 17,
                width: 17,
              ),
              const SizedBox(width: 4),
              Text(
                currencyFormatter.format(value),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Image.asset(
                "assets/icons/Alt Arrow Down.png",
                height: 16,
                width: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Earnings Breakdown Card
  Widget _buildEarningsBreakdown() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "Your Earnings Breakdown",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 10),
          _row(
            "Total amount",
            "₹${controller.totalAmountCollected.toStringAsFixed(2)}",
          ),
          _row(
            "Guest platform fee \n10%(including 18% GST)",
            "- ₹${controller.totalPlatformFeeCollected.toStringAsFixed(2)}",
          ),
          _row(
            "GST Collected",
            "₹${controller.totalGSTCollected.toStringAsFixed(2)}",
          ),
          Divider(color: Colors.white24),
          _row(
            "Estimate earning",
            "₹${controller.estimatedEarnings.toStringAsFixed(2)}",
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildGuestBreakdown() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Guest Price Breakdown",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          _row(
            "Base price",
            "₹${controller.basePricePerTicket.toStringAsFixed(2)}",
          ),
          _row(
            "Guest platform fee \n10%(including 18% GST)",
            " + ₹${controller.platformFeeIncludingGSTPerTicket.toStringAsFixed(2)}",
          ),
          _row(
            "GST (18% on ticket price)",
            "₹${controller.gstOnBasePerTicket.toStringAsFixed(2)}",
          ),
          Divider(color: Colors.white24),
          _row(
            "Guest pay",
            "₹${controller.guestPaysPerTicket.toStringAsFixed(2)}",
            isBold: true,
          ),
        ],
      ),
    );
  }

  /// Row helper widget
  Widget _row(String left, String right, {bool isBold = false}) {
    final formatter = NumberFormat("#,##0.00", "en_US");

    String formatValue(String value) {
      String clean = value.replaceAll(RegExp(r'[₹+\-\s]'), '');

      double? num = double.tryParse(clean);

      if (num != null) {
        String formatted = formatter.format(num);

        // ✅ prefix handle
        if (value.contains('+')) return " + ₹$formatted";
        if (value.contains('-')) return " - ₹$formatted";
        return "₹$formatted";
      }
      return value; // agar parse fail ho jaye to original hi return karo
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(left, style: const TextStyle(color: Colors.white)),
          Text(
            formatValue(right), // ✅ formatted number
            style: TextStyle(
              color: Colors.white,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // The rest of the CapactiyPage class...

  Widget reusableText(
    String text,
    double size,
    Color color, {
    FontWeight fontWeight = FontWeight.normal, // ✅ default value
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: size,
              color: color,
              fontWeight: fontWeight,
            ),
            softWrap: true, // ✅ next line me chale jayega
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }
}

class DecoratedInputs extends StatelessWidget {
  final String hint;
  final String? value;
  final String? iconPath;
  final double iconSize;
  final bool isEditable;
  final Widget? suffix;
  final TextEditingController? controller; // ✅ added
  final ValueChanged<String>? onChanged; // ✅ added

  const DecoratedInputs({
    super.key,
    required this.hint,
    this.value,
    this.iconPath,
    this.iconSize = 24,
    this.isEditable = true, // ✅ editable default true
    this.suffix,
    this.controller,
    this.onChanged,
  });

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

          // ✅ Agar editable hai to TextField, warna Text
          Expanded(
            child: isEditable
                ? TextField(
                    controller: controller,
                    onChanged: onChanged,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                    ),
                  )
                : Text(
                    (value == null || value!.isEmpty) ? hint : value!,
                    style: GoogleFonts.poppins(
                      color: (value == null || value!.isEmpty)
                          ? Colors.white54
                          : Colors.white,
                      fontSize: 16,
                    ),
                  ),
          ),

          if (suffix != null) suffix!,
        ],
      ),
    );
  }
}
