import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:text_code/Host_Pages/Controller_files/event_cntroller.dart';
import 'package:text_code/Reusable/ticket_navigation.dart';
import 'package:text_code/Home_pages/Ticket_Pages_navigation/ticket_navigation_going/payment_ticket.dart';
import 'package:text_code/login-signup/Controller/user_controller.dart';

class TicketPriceScreen extends StatelessWidget {
  final EventController eventController = Get.find<EventController>();
  final UserController userController = Get.put(UserController());

  TicketPriceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => TicketInfoCard(
        title: "One step closer to the event",
        infoItems: [
          {
            "title": "Name",
            "value": userController.userName.value.isNotEmpty 
                ? userController.userName.value 
                : "Not set"
          },
          {
            "title": "Mobile No:",
            "value": userController.mobileNumber.value.isNotEmpty 
                ? "${userController.countryCode.value} ${userController.mobileNumber.value}"
                : "Not set",
            "isBold": true,
          },
          {
            "title": "Ticket Type",
            "value": eventController.ticketPrice.value == "Free" ? "Free" : "₹${eventController.ticketPrice.value}",
          },
        ],
        buttonText: "Pay ₹499",
        onButtonPressed: () {
          // Navigate to payment screen
          Get.to(() => const PaymentTicket());
        },
        bottomLabel: "View Breakdown",
      ),
    );
  }
}
