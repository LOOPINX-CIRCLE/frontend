import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:text_code/Host_Pages/Controller_files/event_cntroller.dart';
import 'package:text_code/Reusable/ticket_navigation.dart';
import 'package:text_code/login-signup/sign_up/booked_ticket.dart';
import 'package:text_code/Home_pages/Controller/ticket_controller.dart';

class TicketScreen extends StatelessWidget {
  final EventController eventController = Get.find<EventController>();
  final UserTicketController ticketController = Get.put(UserTicketController());

  TicketScreen({super.key});

  String generateRandomCode() {
    // Generate random 4-digit code
    final random = Random();
    return (1000 + random.nextInt(9000)).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => TicketInfoCard(
        title: "Just one click away from your spot",
        infoItems: [
          {"title": "Event", "value": eventController.eventTitle.value},
          {
            "title": "Venue",
            "value": eventController.loaction.value,
            "isBold": true,
          },
          {"title": "Date & Time", "value": eventController.dateTime},
          {"title": "Ticket Type", "value": eventController.ticketPrice.value == "Free" ? "Free" : eventController.Price},
        ],
        buttonText: "Generate Ticket",
        onButtonPressed: () {
          // Generate random 4-digit code
          final code = generateRandomCode();
          
          // Create ticket with event details
          final ticket = UserTicket(
            title: eventController.eventTitle.value,
            date: eventController.date.value,
            time: eventController.time.value,
            location: eventController.loaction.value,
            code: code,
            eventImage: eventController.eventImage.value.isNotEmpty 
                ? eventController.eventImage.value 
                : "assets/images/image (1).png", // Default fallback image
          );
          
          // Add ticket to controller
          ticketController.addTicket(ticket);
          
          // Navigate to BookedTicket
          Get.to(() => const BookedTicket());
        },
      ),
    );
  }
}
