import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:text_code/core/services/payment_service.dart';
import 'package:text_code/core/network/api_exception.dart';
import 'package:text_code/Home_pages/Ticket_Pages_navigation/ticket_fail_sucess/sucess_full_payment.dart';
import 'package:text_code/Home_pages/Ticket_Pages_navigation/ticket_fail_sucess/failed.dart';

/// Intermediate screen shown AFTER user returns from PayU / UPI app.
/// It:
/// 1. Verifies payment status via GET /api/payments/orders/{order_id}
/// 2. If status == "paid"  → navigates to SucessFullPayment
/// 3. Otherwise            → navigates to Failed
class PaymentProcessingScreen extends StatefulWidget {
  final String orderId;
  final int eventId;

  const PaymentProcessingScreen({
    super.key,
    required this.orderId,
    required this.eventId,
  });

  @override
  State<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  final PaymentService _paymentService = PaymentService();
  bool _isProcessing = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processPayment();
    });
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    if (kDebugMode) {
      print('PaymentProcessingScreen: verifying order ${widget.orderId} for event ${widget.eventId}');
    }

    try {
      // Call: GET /api/payments/orders/{order_id}
      final orderResponse = await _paymentService.getPaymentOrder(widget.orderId);
      final status = orderResponse.data.order.status.toLowerCase();

      if (kDebugMode) {
        print('PaymentProcessingScreen: status=$status, successFlag=${orderResponse.success}');
      }

      // Decide based on status
      if (status == 'paid') {
        // Payment successful → go to success screen
        if (kDebugMode) {
          print('PaymentProcessingScreen: payment PAID, navigating to success screen');
        }
        if (!mounted) return;
        Get.off(() => const SucessFullPayment());
      } else {
        // Any non-paid status is treated as failure
        if (kDebugMode) {
          print('PaymentProcessingScreen: payment NOT PAID ($status), navigating to failure screen');
        }
        if (!mounted) return;
        Get.off(() => const Failed());
      }
    } catch (e) {
      if (kDebugMode) {
        print('PaymentProcessingScreen: error while verifying payment: $e');
      }

      String message = 'Unable to verify payment. Please try again.';
      if (e is ApiException) {
        final statusCode = e.statusCode;
        if (statusCode == 404) {
          message = 'Payment order not found. Please try again.';
        } else if (statusCode == 401) {
          message = 'Session expired. Please log in again.';
        } else if (statusCode != null && statusCode >= 500) {
          message = 'Server error. Please try again later.';
        }
      }

      if (mounted) {
        Get.off(() => const Failed());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 24),
              const Text(
                'Processing your payment...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please wait while we verify your payment status.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


