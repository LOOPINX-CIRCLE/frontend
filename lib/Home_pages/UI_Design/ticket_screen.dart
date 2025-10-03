import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/Host_Pages/Controller_files/detail_controller_file.dart';
import 'package:text_code/Host_Pages/Controller_files/event_cntroller.dart';
import 'package:text_code/Reusable/text_Bricolage%20Grotesque_reusable.dart';
import 'package:text_code/Reusable/text_reusable.dart';

class TicketScreen extends StatelessWidget {
  final EventController eventController = Get.find<EventController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: 351,
          height: 500,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/85 1.png"),
              alignment: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.black, Colors.black],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(
              color: Colors.grey, // border color
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextBricolage(
                FontWeight.w500,
                "Just one click away from your spot",
                26,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 20),

              // Ticket Info Card
              Container(
                height: 230,
                width: 298,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 23, 23, 23),
                  borderRadius: BorderRadius.circular(16),
                  // border: Border.all(
                  //   color: Colors.grey, // border color
                  //   width: 0, // border thickness
                  // ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => ticketRowStatic("Event", eventController.event)),
                    Divider(color: Colors.grey),
                    Obx(() => ticketRow("Venue", eventController.fullLocation)),
                    Divider(color: Colors.grey),
                    Obx(
                      () => ticketRowStatic(
                        "Date & Time",
                        eventController.dateTime,
                      ),
                    ),
                    Divider(color: Colors.grey),
                    ticketRowStatic("Ticket Type", eventController.Price),
                    Divider(color: Colors.grey),
                  ],
                ),
              ),

              SizedBox(height: 15),

              // Generate Ticket Button
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero, // extra space remove
                  backgroundColor: Colors.transparent, // button bg remove
                  shadowColor: Colors.transparent, // shadow remove
                  minimumSize: Size(298, 60), // size image ke equal
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // image ke corner match
                  ),
                ),
                child: Image.asset(
                  "assets/images/button/ticketbutt.png",
                  height: 60,
                  width: 298,
                ),
              ),

              // Go Back
              TextButton(
                onPressed: () => Get.back(),
                child: FormLabel(
                  "Go Back",
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget ticketRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget ticketRowStatic(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
