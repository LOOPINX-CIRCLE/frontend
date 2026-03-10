import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/Home_pages/UI_Design/home_page.dart';
import 'package:text_code/Reusable/text_reusable.dart';
import 'package:text_code/Host_Pages/Controller_files/event_cntroller.dart';
import 'package:text_code/Home_pages/Ticket_Pages_navigation/ticket_navigation_going/payu_webview_screen.dart';
import 'package:text_code/core/services/payment_service.dart';
import 'package:text_code/core/services/event_service.dart';
import 'package:text_code/core/network/api_exception.dart';

class Failed extends StatefulWidget {
  const Failed({super.key});

  @override
  State<Failed> createState() => _FailedState();
}

class _FailedState extends State<Failed> {
  final EventController eventController = Get.find<EventController>();
  final PaymentService _paymentService = PaymentService();
  final EventService _eventService = EventService();
  bool _isRetrying = false;

  /// Create a fresh payment order and redirect to PayU
  Future<void> _tryAgain() async {
    if (eventController.eventId.value == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event ID not available'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    setState(() {
      _isRetrying = true;
    });

    try {
      if (kDebugMode) {
        print('Creating fresh payment order for retry...');
      }

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );

      // Fetch event details
      final event = await _eventService.fetchEventById(eventController.eventId.value);

      if (!event.isPaid) {
        if (mounted) Navigator.of(context).pop();
        setState(() {
          _isRetrying = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This event is not configured as a paid event.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      // Parse amount
      final priceString = event.ticketPrice?.replaceAll('₹', '').trim() ?? 
                          eventController.ticketPrice.value.replaceAll('₹', '').trim();
      final amount = double.tryParse(priceString) ?? 0.0;

      if (amount <= 0) {
        if (mounted) Navigator.of(context).pop();
        setState(() {
          _isRetrying = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid ticket price'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Create fresh payment order
      final paymentResponse = await _paymentService.createPaymentOrder(
        eventId: eventController.eventId.value,
        amount: amount,
        seatsCount: 1,
      );

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (kDebugMode) {
        print('Fresh payment order created: ${paymentResponse.data.order.orderId}');
      }

      // Validate PayU redirect data
      if (paymentResponse.data.payuRedirect == null) {
        setState(() {
          _isRetrying = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment gateway information is missing. Please try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      setState(() {
        _isRetrying = false;
      });

      // Navigate to PayU WebView with fresh order
      if (mounted) {
        Get.offAll(() => PayUWebViewScreen(
          paymentResponse: paymentResponse,
        ));
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      setState(() {
        _isRetrying = false;
      });

      if (kDebugMode) {
        print('Error creating fresh payment order: $e');
      }

      String errorMessage = 'Failed to create payment order. Please try again.';
      if (e is ApiException) {
        errorMessage = e.message;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button and heading aligned - margin 31 from top
              Padding(
                padding: const EdgeInsets.only(top: 31, left: 16, right: 16),
                child: Row(
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          "assets/icons/Back Icon.png",
                          height: 24,
                          width: 24,
                        ),
                      ),
                    ),
                    // Payment failed heading - centered
                    Expanded(
                      child: Center(
                        child: Text(
                          "Payment failed",
                          style: GoogleFonts.bricolageGrotesque(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    // Spacer to balance the back button
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              // Margin 250, then image
              const SizedBox(height: 80),
              Center(
                child: Image.asset("assets/icons/iconpaym.png"),
              ),
              // Keep Try Again and Go Back buttons same
              const SizedBox(height: 30),
              Center(
                child: GestureDetector(
                  onTap: _isRetrying ? null : _tryAgain,
                  child: Opacity(
                    opacity: _isRetrying ? 0.6 : 1.0,
                    child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromRGBO(40, 40, 40, 1.0), // Lighter gray at top
                          Color.fromRGBO(20, 20, 20, 1.0), // Darker gray in middle
                          Colors.black, // Black at bottom
                        ],
                      
                        stops: [0.0, 0.5, 1.0],
                      ),
                      border: Border.all(color: Colors.grey, width: 1.0),
                    ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        child: _isRetrying
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                "Try Again",
                                style: GoogleFonts.bricolageGrotesque(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    Get.to(() => HomePages());
                  },
                  child: FormLabel("Go Back", fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
