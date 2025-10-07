// ticket_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:text_code/Host_Pages/Controller_files/event_cntroller.dart';
import 'package:text_code/Reusable/ticket_navigation.dart';

class TicketScreen extends StatelessWidget {
  final EventController eventController =
      Get.find<EventController>(); // ✅ same instance used

  TicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => TicketInfoCard(
        title: "Just one click away from your spot",
        infoItems: [
          {"title": "Event", "value": eventController.event},
          {
            "title": "Venue",
            "value": eventController.fullLocation,
            "isBold": true,
          },
          {"title": "Date & Time", "value": eventController.dateTime},
          {"title": "Ticket Type", "value": eventController.Price},
        ],
        buttonText: "Generate Ticket",
        onButtonPressed: () {},
        // bottomLabel: "View Breakdown",
      ),
    );
  }
}
