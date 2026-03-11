import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:text_code/core/services/auth_service.dart';
import 'package:text_code/core/services/secure_storage_service.dart';
import 'package:text_code/core/services/payment_service.dart';
import 'package:text_code/core/services/event_request_service_host.dart';
import 'package:text_code/Host_Pages/Controller_files/event_cntroller.dart';
import 'package:text_code/Home_pages/Controller/ticket_controller.dart';
import 'package:text_code/Home_pages/Ticket_Pages_navigation/ticket_fail_sucess/sucess_full_payment.dart';
import 'package:text_code/Home_pages/Ticket_Pages_navigation/ticket_fail_sucess/failed.dart';

import 'package:video_player/video_player.dart';
// The screen to navigate to
import 'package:text_code/login-signup/sign_up/mobile_no.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    // Hide system UI for a full-screen experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // Fix: Use correct case-sensitive filename (Splash.mp4 not splash.mp4)
    _controller = VideoPlayerController.asset('assets/video/Splash.mp4')
      ..initialize().then((_) {
        // This block of code only runs AFTER the video has finished initializing.

        // Ensure the first frame is shown and trigger a rebuild
        if (mounted) {
          setState(() {});

          // Now, play the video
          _controller.play();

          // And ONLY NOW, start the timer to navigate away.
          _navigateToHome();
        }
      }).catchError((error) {
        // Handle video loading errors - navigate immediately if video fails
        print('Error loading splash video: $error');
        if (mounted) {
          _navigateToHome();
        }
      });

    // Set volume can be done here.
    _controller.setVolume(0.0);
  }

  void _navigateToHome() async {
    // Wait for a duration. 4 seconds should be enough for your video.
    await Future.delayed(const Duration(seconds: 4));

    // Check if the widget is still in the tree before navigating
    if (mounted) {
      // First check for pending UPI payment (app might have been killed during payment)
      final hasPendingPayment = await _checkPendingPayment();
      if (hasPendingPayment) {
        // Pending payment was handled, don't navigate to MobileNo
        return;
      }

      // Always navigate to mobile number page (skip auto-login)
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MobileNo(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  /// Check for pending payment and handle it
  /// Returns true if there was a pending payment that was handled
  Future<bool> _checkPendingPayment() async {
    try {
      final secureStorage = SecureStorageService();
      final pendingPayment = await secureStorage.getPendingPayment();

      if (pendingPayment == null) {
        if (kDebugMode) {
          print('No pending payment found');
        }
        return false;
      }

      final orderId = pendingPayment['orderId'] as String;
      final eventId = pendingPayment['eventId'] as int;

      if (kDebugMode) {
        print('Found pending payment: orderId=$orderId, eventId=$eventId');
        print('Checking payment status...');
      }

      // Check if user is logged in first
      final authService = AuthService();
      final token = await authService.getStoredToken();
      
      if (token == null || token.isEmpty) {
        if (kDebugMode) {
          print('User not logged in, clearing pending payment');
        }
        await secureStorage.clearPendingPayment();
        return false;
      }

      // Check payment status
      final paymentService = PaymentService();
      final orderResponse = await paymentService.getPaymentOrder(orderId);
      final status = orderResponse.data.order.status.toLowerCase();

      if (kDebugMode) {
        print('Pending payment status: $status');
      }

      if (status == 'paid') {
        // Payment was successful! Fetch ticket and navigate to success
        if (kDebugMode) {
          print('Payment was successful! Fetching ticket...');
        }
        
        await _handleSuccessfulPendingPayment(eventId);
        await secureStorage.clearPendingPayment();
        return true;
      } else if (status == 'failed' || status == 'expired') {
        // Payment failed, navigate to failure screen
        if (kDebugMode) {
          print('Payment failed or expired');
        }
        await secureStorage.clearPendingPayment();
        
        if (mounted) {
          Get.off(() => const Failed());
        }
        return true;
      } else {
        // Payment still pending - clear it and let user retry
        if (kDebugMode) {
          print('Payment still pending/created - clearing');
        }
        await secureStorage.clearPendingPayment();
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking pending payment: $e');
      }
      // Clear pending payment on error
      final secureStorage = SecureStorageService();
      await secureStorage.clearPendingPayment();
      return false;
    }
  }

  /// Handle successful pending payment - fetch ticket and navigate to success
  Future<void> _handleSuccessfulPendingPayment(int eventId) async {
    try {
      final eventRequestService = EventRequestService();
      final ticketData = await eventRequestService.getTicket(eventId);

      if (kDebugMode) {
        print('Ticket fetched for pending payment: $ticketData');
      }

      // Initialize controllers
      final eventController = Get.put(EventController());
      final ticketController = Get.put(UserTicketController());

      // Extract ticket data
      final ticketSecret = ticketData['ticket_secret']?.toString() ?? '';
      final eventTitle = ticketData['event_title']?.toString() ?? '';
      final venueName = ticketData['venue_name']?.toString() ?? '';
      final eventStartTime = ticketData['event_start_time']?.toString() ?? '';
      final coverImageUrl = ticketData['cover_image_url']?.toString() ?? '';

      // Format date
      String formattedDate = 'Date TBD';
      if (eventStartTime.isNotEmpty) {
        try {
          final dateTime = DateTime.parse(eventStartTime);
          formattedDate = DateFormat('EEEE d, MMMM yyyy').format(dateTime);
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing date: $e');
          }
        }
      }

      // Create ticket
      final ticket = UserTicket(
        title: eventTitle,
        date: formattedDate,
        location: venueName,
        code: ticketSecret,
        eventImage: coverImageUrl.isNotEmpty ? coverImageUrl : 'assets/images/image (1).png',
      );

      ticketController.addTicket(ticket);

      // Update event controller
      eventController.eventTitle.value = eventTitle;
      eventController.loaction.value = venueName;
      eventController.date.value = formattedDate;
      eventController.eventId.value = eventId;
      if (coverImageUrl.isNotEmpty) {
        eventController.eventImage.value = coverImageUrl;
      }

      // Navigate to success screen
      if (mounted) {
        Get.off(() => const SucessFullPayment());
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling successful pending payment: $e');
      }
      // Still navigate to success even if ticket fetch fails
      if (mounted) {
        Get.off(() => const SucessFullPayment());
      }
    }
  }

  Future<void> _checkAutoLogin() async {
    try {
      // Add a small delay to ensure services are initialized
      await Future.delayed(const Duration(milliseconds: 500));
      
      final authService = AuthService();
      final token = await authService.getStoredToken();
      
      if (mounted) {
        if (token != null && token.isNotEmpty) {
          // Token exists, go to home
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // No token, go to login/signup - use direct navigation since route might not exist
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => MobileNo(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        }
      }
    } catch (error) {
      print('Error during auto login check: $error');
      // Fallback navigation on error - always go to mobile number page
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => MobileNo(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Dispose the controller to free up resources
    _controller.dispose();
    // Restore system UI when leaving the splash screen
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Match the video's background
      body: Center(
        // We wait for the controller to be initialized before showing the video
        child: _controller.value.isInitialized
            ? SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              )
            // While loading, show a loading indicator instead of just black screen
            : const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
      ),
    );
  }
}
