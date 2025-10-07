import 'package:flutter/material.dart';
import 'package:text_code/Reusable/ticker_payment_screen.dart';

class SucessFullPayment extends StatelessWidget {
  const SucessFullPayment({super.key});

  @override
  Widget build(BuildContext context) {
    return PaymentStatusScreen(
      appBarTitle: "Payment successful",
      imagePath: "assets/icons/payment.png",
      message: "Your Ticket Is Confirmed",
      primaryButtonText: "View Ticket",
      onPrimaryPressed: () {
        // Open ticket screen logic
      },
      secondaryButtonText: "Add to calendar",
      onSecondaryPressed: () {
        // Add to calendar logic
      },
    );
  }
}
