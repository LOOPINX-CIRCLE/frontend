import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:text_code/Reusable/ticker_payment_screen.dart';
import 'package:text_code/Host_Pages/Controller_files/event_cntroller.dart';
import 'package:text_code/login-signup/sign_up/booked_ticket.dart';
import 'package:text_code/Home_pages/Controller/ticket_controller.dart';

class SucessFullPayment extends StatelessWidget {
  const SucessFullPayment({super.key});

  String generateRandomCode() {
    // Generate random 4-digit code
    final random = Random();
    return (1000 + random.nextInt(9000)).toString();
  }

  @override
  Widget build(BuildContext context) {
    final EventController eventController = Get.find<EventController>();
    final UserTicketController ticketController = Get.put(UserTicketController());

    // Format date and time for display
    String formattedDateTime = "";
    if (eventController.date.value.isNotEmpty && eventController.time.value.isNotEmpty) {
      // Format date from "Saturday 7, June 2025" to "07/05/25" or similar
      String dateStr = eventController.date.value;
      String timeStr = eventController.time.value;
      
      // Extract date parts if possible, otherwise use as is
      formattedDateTime = "$dateStr $timeStr";
    }

    return PaymentStatusScreen(
      appBarTitle: "Payment successful",
      imagePath: "assets/icons/payment.png",
     
      primaryButtonText: "View Ticket",
      onPrimaryPressed: () {
        // Generate random 4-digit code
        final code = generateRandomCode();
        
        // Create ticket with event details from EventController
        final ticket = UserTicket(
          title: eventController.eventTitle.value,
          date: eventController.date.value,
          time: eventController.time.value,
          location: eventController.loaction.value,
          code: code,
          eventImage: eventController.eventImage.value.isNotEmpty 
              ? eventController.eventImage.value 
              : "assets/images/image (1).png",
        );
        
        // Add ticket to controller
        ticketController.addTicket(ticket);
        
        // Navigate to BookedTicket
        Get.to(() => const BookedTicket());
      },
      secondaryButtonText: "Add to calendar",
      onSecondaryPressed: () {
        // Add to calendar logic
      },
      eventTitle: eventController.eventTitle.value.isNotEmpty 
          ? eventController.eventTitle.value 
          : "Sizzle",
      venue: eventController.loaction.value.isNotEmpty 
          ? eventController.loaction.value 
          : "Bastian garden city",
      dateTime: formattedDateTime.isNotEmpty 
          ? formattedDateTime 
          : (eventController.date.value.isNotEmpty && eventController.time.value.isNotEmpty
              ? "${eventController.date.value} ${eventController.time.value}"
              : "07/05/25 7:00PM"),
    );
  }
}
