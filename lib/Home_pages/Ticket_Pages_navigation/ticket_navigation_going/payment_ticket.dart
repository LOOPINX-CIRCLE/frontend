import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/Host_Pages/Controller_files/event_cntroller.dart';
import 'package:text_code/Home_pages/Ticket_Pages_navigation/ticket_navigation_going/payu_webview_screen.dart';
import 'package:text_code/core/models/payment_order_response.dart';
import 'package:text_code/Reusable/customer_appbar.dart';
import 'package:text_code/Reusable/text_Bricolage%20Grotesque_reusable.dart';
import 'package:text_code/Reusable/text_reusable.dart';

class PaymentTicket extends StatefulWidget {
  final PaymentOrderResponse? paymentResponse;

  const PaymentTicket({
    super.key,
    this.paymentResponse,
  });

  @override
  State<PaymentTicket> createState() => _PaymentTicketState();
}

class _PaymentTicketState extends State<PaymentTicket> {
  final EventController eventController = Get.find<EventController>();

  @override
  void initState() {
    super.initState();
    // If payment response is provided, redirect to PayU immediately
    if (widget.paymentResponse != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _redirectToPayU();
      });
    }
  }

  void _redirectToPayU() {
    if (widget.paymentResponse == null) {
      if (kDebugMode) {
        print('ERROR: Payment response is null');
      }
      Get.back();
      return;
    }

    if (kDebugMode) {
      print('Redirecting to PayU payment gateway...');
    }

    // Navigate to PayU WebView screen
    Get.to(() => PayUWebViewScreen(
      paymentResponse: widget.paymentResponse!,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(
        leadingIcon: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Image.asset(
              "assets/icons/Back Icon.png",
              height: 60,
            ),
          ),
        ),
        titleWidget: FormLabel("Payment", fontSize: 22),
      ),
      body: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Payment Summary Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextBricolage(
                      FontWeight.w600,
                      "Payment Summary",
                      20,
                    ),
                    const SizedBox(height: 20),
                    _buildSummaryRow("Event", eventController.eventTitle.value),
                    const SizedBox(height: 12),
                    _buildSummaryRow("Venue", eventController.loaction.value),
                    const SizedBox(height: 12),
                    _buildSummaryRow("Date", eventController.date.value),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.grey, height: 24),
                    _buildSummaryRow(
                      "Amount",
                      "₹${eventController.ticketPrice.value}",
                      isBold: true,
                      isAmount: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // Loading indicator while redirecting to PayU
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Redirecting to payment gateway...',
                      style: TextStyle(color: Colors.white70),
                  ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, bool isAmount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.bricolageGrotesque(
            fontSize: 14,
            color: Colors.grey[400],
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.bricolageGrotesque(
            fontSize: isAmount ? 18 : 14,
            color: Colors.white,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

}

