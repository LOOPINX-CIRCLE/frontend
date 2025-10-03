// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/Host_Pages/Controller_files/event_cntroller.dart';

class EventDetailsCard extends StatelessWidget {
  final EventController controller = Get.put(EventController());

  EventDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        width: MediaQuery.of(context).size.width, // ✅ full screen width
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
            buildRow("Experience type", controller.experienceType.value),
            buildRow("Event title", controller.eventTitle.value),
            buildRow("Date", controller.date.value),
            buildRow("Time", controller.time.value),
            buildRow("Duration", controller.duration.value),
            buildRow("Capacity", controller.capacity.value),
            buildRow("Ticket Price", controller.ticketPrice.value),
            buildRow("Description", controller.description.value),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
