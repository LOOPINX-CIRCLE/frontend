import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/Host_Pages/Controller_files/event_cntroller.dart';
import 'package:text_code/Home_pages/Ticket_Pages_navigation/ticket_fail_sucess/sucess_full_payment.dart';
import 'package:text_code/Home_pages/Ticket_Pages_navigation/ticket_fail_sucess/failed.dart';
import 'package:text_code/Reusable/customer_appbar.dart';
import 'package:text_code/Reusable/text_Bricolage%20Grotesque_reusable.dart';
import 'package:text_code/Reusable/text_reusable.dart';

class PaymentTicket extends StatefulWidget {
  const PaymentTicket({super.key});

  @override
  State<PaymentTicket> createState() => _PaymentTicketState();
}

class _PaymentTicketState extends State<PaymentTicket> {
  final EventController eventController = Get.find<EventController>();
  bool isProcessing = false;

  void _processPayment({bool forceFailure = false}) {
    setState(() {
      isProcessing = true;
    });

    // Simulate payment processing
    Future.delayed(const Duration(seconds: 2), () {
      // Simulate payment success/failure
      // In real app, this would be actual payment gateway response
      // For testing: Tap and hold the Pay button for 2 seconds to simulate failure
      final bool paymentSuccess = !forceFailure;
      
      if (paymentSuccess) {
        // Navigate to success screen
        Get.to(() => const SucessFullPayment());
      } else {
        // Navigate to failed screen
        Get.to(() => const Failed());
      }
      
      setState(() {
        isProcessing = false;
      });
    });
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
                    _buildSummaryRow("Date & Time", eventController.dateTime),
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
              
              // Payment Methods
              TextBricolage(
                FontWeight.w600,
                "Select Payment Method",
                18,
              ),
              const SizedBox(height: 16),
              
              // Payment method cards
              _buildPaymentMethodCard(
                "UPI",
                "Pay using UPI",
                Icons.account_balance_wallet,
                isSelected: true,
              ),
              const SizedBox(height: 12),
              _buildPaymentMethodCard(
                "Credit/Debit Card",
                "Pay using card",
                Icons.credit_card,
              ),
              const SizedBox(height: 12),
              _buildPaymentMethodCard(
                "Net Banking",
                "Pay using net banking",
                Icons.account_balance,
              ),
              
              const SizedBox(height: 40),
              
              // Pay Button - Single tap for success, Long press for failure
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onLongPress: () {
                    if (!isProcessing) {
                      _processPayment(forceFailure: true); // Simulate payment failure
                    }
                  },
                  child: ElevatedButton(
                    onPressed: isProcessing ? null : () => _processPayment(), // Simulate payment success
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.grey, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            "Pay ₹${eventController.ticketPrice.value}",
                            style: GoogleFonts.bricolageGrotesque(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
              
              // Helper text for testing
              const SizedBox(height: 12),
              Center(
                child: Text(
                  "💡 Tip: Long press for payment failure",
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
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

  Widget _buildPaymentMethodCard(String title, String subtitle, IconData icon, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey[900] : Colors.grey[950],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.white : Colors.grey[800]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            const Icon(Icons.check_circle, color: Colors.green, size: 24),
        ],
      ),
    );
  }
}

