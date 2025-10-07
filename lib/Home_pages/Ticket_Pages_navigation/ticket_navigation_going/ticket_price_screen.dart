import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:text_code/Host_Pages/Controller_files/event_cntroller.dart';
import 'package:text_code/Reusable/ticket_navigation.dart';

class TicketPriceScreen extends StatelessWidget {
  final EventController eventController = Get.find<EventController>();

  TicketPriceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => TicketInfoCard(
        title: "One step closer to the event",
        infoItems: [
          {"title": "Name", "value": eventController.experienceType.value},
          {
            "title": "Mobile No:",
            "value": eventController.loaction.value,
            "isBold": true,
          },
          {
            "title": "Ticket Type",
            "value": "₹${eventController.ticketPrice.value}",
          },
        ],
        buttonText: "Pay ₹${eventController.ticketPrice.value}",
        onButtonPressed: () {
          // Payment logic here
        },
        bottomLabel: "View Breakdown",
      ),
    );
  }
}
