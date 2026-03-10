import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:text_code/Host_Pages/Controller_files/event_cntroller.dart';
import 'package:text_code/Reusable/ticket_navigation.dart';
import 'package:text_code/Home_pages/Ticket_Pages_navigation/ticket_navigation_going/payu_webview_screen.dart';
import 'package:text_code/login-signup/Controller/user_controller.dart';
import 'package:text_code/core/services/payment_service.dart';
import 'package:text_code/core/services/event_service.dart';
import 'package:text_code/core/network/api_exception.dart';

class TicketPriceScreen extends StatefulWidget {
  const TicketPriceScreen({super.key});

  @override
  State<TicketPriceScreen> createState() => _TicketPriceScreenState();
}

class _TicketPriceScreenState extends State<TicketPriceScreen> {
  final EventController eventController = Get.find<EventController>();
  final UserController userController = Get.put(UserController());
  final PaymentService _paymentService = PaymentService();
  final EventService _eventService = EventService();
  bool isLoading = false;

  /// Create payment order and navigate to payment screen
  Future<void> _createPaymentOrder() async {
    if (eventController.eventId.value == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event ID not available'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Parse amount from ticket price
    final priceString = eventController.ticketPrice.value.replaceAll('₹', '').trim();
    final amount = double.tryParse(priceString) ?? 0.0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid ticket price'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (kDebugMode) {
        print('Creating payment order for event ID: ${eventController.eventId.value}');
        print('Amount: $amount');
      }

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );

      // First, fetch event details to verify it's actually a paid event
      if (kDebugMode) {
        print('Fetching event details to verify payment status...');
      }
      
      final event = await _eventService.fetchEventById(eventController.eventId.value);
      
      if (kDebugMode) {
        print('Event fetched - isPaid: ${event.isPaid}, ticketPrice: ${event.ticketPrice}');
      }

      // Verify event is actually marked as paid in the database
      if (!event.isPaid) {
        // Close loading dialog
        if (mounted) Navigator.of(context).pop();
        
        setState(() {
          isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This event is not configured as a paid event. Please contact the event host.'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      // Use the ticket price from the event if available, otherwise use the parsed amount
      final finalAmount = event.ticketPrice != null && event.ticketPrice!.isNotEmpty
          ? (double.tryParse(event.ticketPrice!.replaceAll('₹', '').trim()) ?? amount)
          : amount;

      if (kDebugMode) {
        print('Event is paid. Creating payment order with amount: $finalAmount');
      }

      // Create payment order via API
      final createResponse = await _paymentService.createPaymentOrder(
        eventId: eventController.eventId.value,
        amount: finalAmount,
        seatsCount: 1, // Default to 1 seat
      );

      if (kDebugMode) {
        print('Payment order created successfully');
        print('Order ID: ${createResponse.data.order.orderId}');
        print('Order Status: ${createResponse.data.order.status}');
        print('PayU URL: ${createResponse.data.payuRedirect?.payuUrl ?? 'N/A'}');
      }

      // Validate PayU redirect data from create response
      if (createResponse.data.payuRedirect == null) {
        // Close loading dialog
        if (mounted) Navigator.of(context).pop();
        
        setState(() {
          isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment gateway information is missing. Please try again.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Update loading dialog to show "Redirecting to payment gateway..."
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.black,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'Redirecting to payment gateway...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      setState(() {
        isLoading = false;
      });

      // Navigate directly to PayU WebView screen with create response
      // The PayU WebView will build and submit the form automatically
      // After PayU callback, it will check payment status via GET /api/payments/orders/{order_id}
      if (mounted) {
        // Close loading dialog before navigation
        Navigator.of(context).pop();
        Get.to(() => PayUWebViewScreen(
          paymentResponse: createResponse,
        ));
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      setState(() {
        isLoading = false;
      });

      if (kDebugMode) {
        print('Error creating payment order: $e');
        print('Error type: ${e.runtimeType}');
      }

      // Extract meaningful error message
      String errorMessage = e.toString();
      
      // Remove "ApiException: " prefix if present
      if (errorMessage.startsWith('ApiException: ')) {
        errorMessage = errorMessage.substring('ApiException: '.length);
      }

      // Show error message
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
        buttonText: isLoading 
            ? "Processing..." 
            : (eventController.ticketPrice.value == "Free" 
                ? "Free" 
                : "Pay ₹${eventController.ticketPrice.value}"),
        onButtonPressed: isLoading 
            ? () {} // Empty function when loading
            : _createPaymentOrder,
        bottomLabel: "View Breakdown",
      ),
    );
  }
}
