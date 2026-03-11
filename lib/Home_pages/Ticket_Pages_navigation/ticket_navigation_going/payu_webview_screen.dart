import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:text_code/core/models/payment_order_response.dart';
import 'package:text_code/core/services/payment_service.dart';
import 'package:text_code/core/services/event_request_service_host.dart';
import 'package:text_code/core/services/secure_storage_service.dart';
import 'package:text_code/core/network/api_exception.dart';
import 'package:text_code/Host_Pages/Controller_files/event_cntroller.dart';
import 'package:text_code/Home_pages/Controller/ticket_controller.dart';
import 'package:text_code/Home_pages/Ticket_Pages_navigation/ticket_navigation_going/payment_processing_screen.dart';
import 'package:text_code/Home_pages/Ticket_Pages_navigation/ticket_fail_sucess/sucess_full_payment.dart';
import 'package:text_code/Home_pages/Ticket_Pages_navigation/ticket_fail_sucess/failed.dart';

/// PayU WebView Screen for handling payment
/// 
/// Flow:
/// 1. Receives PaymentOrderResponse with PayU URL and payload
/// 2. Submits POST form to PayU with payment details
/// 3. Monitors URL changes to detect success/failure callbacks
/// 4. Navigates to success/failure screen based on callback
class PayUWebViewScreen extends StatefulWidget {
  final PaymentOrderResponse paymentResponse;

  const PayUWebViewScreen({
    super.key,
    required this.paymentResponse,
  });

  @override
  State<PayUWebViewScreen> createState() => _PayUWebViewScreenState();
}

class _PayUWebViewScreenState extends State<PayUWebViewScreen> with WidgetsBindingObserver {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasNavigated = false;
  bool _payuPageLoaded = false; // Track if PayU page has loaded
  bool _upiAppLaunched = false; // Track if UPI app was launched
  bool _checkingPaymentAfterResume = false; // Prevent multiple checks
  final PaymentService _paymentService = PaymentService();
  final EventRequestService _eventRequestService = EventRequestService();
  final SecureStorageService _secureStorage = SecureStorageService();
  final EventController _eventController = Get.find<EventController>();
  final UserTicketController _ticketController = Get.put(UserTicketController());

  @override
  void initState() {
    super.initState();
    // Add lifecycle observer to detect when app resumes from UPI app
    WidgetsBinding.instance.addObserver(this);
    _initializeWebView();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Handle app lifecycle changes - crucial for UPI payment flow
  /// When user returns from UPI app (Google Pay, PhonePe, etc.), we need to check payment status
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (kDebugMode) {
      print('App lifecycle state changed: $state');
      print('UPI app launched: $_upiAppLaunched, Has navigated: $_hasNavigated');
    }

    // When app resumes after launching UPI app, check payment status
    if (state == AppLifecycleState.resumed && _upiAppLaunched && !_hasNavigated && !_checkingPaymentAfterResume) {
      if (kDebugMode) {
        print('App resumed after UPI payment - checking payment status...');
      }
      
      // Add a small delay to allow any pending callbacks to process
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!_hasNavigated && mounted) {
          _checkPaymentStatusAfterUPI();
        }
      });
    }
  }

  /// Check payment status after returning from UPI app
  Future<void> _checkPaymentStatusAfterUPI() async {
    if (_checkingPaymentAfterResume || _hasNavigated) return;

    _checkingPaymentAfterResume = true;

    if (kDebugMode) {
      print('Checking payment status after UPI app return (redirecting to processing page)...');
    }

    // Simply navigate to the common processing page, which will handle verification
    _navigateToProcessingPage();
  }

  void _initializeWebView() {
    final payuRedirect = widget.paymentResponse.data.payuRedirect;
    if (payuRedirect == null) {
      if (kDebugMode) {
        print('ERROR: PayU redirect data is missing');
      }
      _navigateToFailure('Payment gateway information is missing');
      return;
    }

    final payuUrl = payuRedirect.payuUrl;
    final payload = payuRedirect.payload.toFormData();

    if (kDebugMode) {
      print('Initializing PayU WebView');
      print('PayU URL: $payuUrl');
      print('Payload: $payload');
    }

    // Create WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (kDebugMode) {
              print('Page started loading: $url');
            }
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            if (kDebugMode) {
              print('Page finished loading: $url');
            }
            setState(() {
              _isLoading = false;
            });
            
            // Mark PayU page as loaded if we're on PayU domain
            // This prevents false positives during initial redirect
            if (url.contains('payu') || url.contains('secure.payu')) {
              _payuPageLoaded = true;
              if (kDebugMode) {
                print('PayU page loaded - callback detection enabled');
              }
            }
          },
          // Intercept navigation requests (e.g., UPI deep links) and open external apps
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;

            if (kDebugMode) {
              print('Navigation request: $url');
            }

            // Allow normal http/https navigation (PayU pages & callbacks)
            if (url.startsWith('http://') || url.startsWith('https://')) {
              return NavigationDecision.navigate;
            }

            // Handle UPI / deep link schemes via external apps
            final uri = Uri.parse(url);
            if (uri.scheme == 'upi' ||
                uri.scheme == 'phonepe' ||
                uri.scheme == 'tez' ||
                uri.scheme == 'paytm' ||
                uri.scheme == 'gpay' ||
                uri.scheme == 'bhim' ||
                uri.scheme == 'intent') {
              if (kDebugMode) {
                print('Detected UPI/deep link, launching external app: $url');
              }
              _launchExternalDeepLink(uri);
              // Prevent WebView from trying to load this URL
              return NavigationDecision.prevent;
            }

            // For any other non-http(s) scheme, try to open externally as well
            if (uri.scheme.isNotEmpty && !url.startsWith('http')) {
              if (kDebugMode) {
                print('Detected non-http scheme, launching external app: $url');
              }
              _launchExternalDeepLink(uri);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            if (kDebugMode) {
              print('WebView error: ${error.description}');
            }

            // Do NOT immediately treat unknown URL scheme errors as payment failure,
            // since they may correspond to UPI/deep-link attempts already handled above.
            final errorDescription = (error.description ?? '').toLowerCase();
            if (errorDescription.contains('unknown url scheme')) {
              if (kDebugMode) {
                print('Ignoring unknown URL scheme error (likely handled by external app).');
              }
              return;
            }

            if (!_hasNavigated) {
              _navigateToFailure('Payment page failed to load. Please try again.');
            }
          },
          onUrlChange: (UrlChange change) {
            if (change.url != null) {
              _handleUrlChange(change.url!);
            }
            if (change.url != null) {
              _handleUrlChange(change.url!);
            }
          },
        ),
      );

    // Build HTML form with POST submission
    final htmlContent = _buildPayUForm(payuUrl, payload);
    
    // Load HTML content
    _controller.loadRequest(
      Uri.dataFromString(
        htmlContent,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8'),
      ),
    );
  }

  /// Build HTML form that auto-submits to PayU
  String _buildPayUForm(String actionUrl, Map<String, String> formData) {
    final formFields = formData.entries.map((entry) {
      return '<input type="hidden" name="${entry.key}" value="${entry.value}">';
    }).join('\n');

    return '''
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PayU Payment</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            background-color: #000;
            font-family: Arial, sans-serif;
        }
        .loading {
            color: white;
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="loading">
        <p>Redirecting to payment gateway...</p>
    </div>
    <form id="payuForm" method="POST" action="$actionUrl">
        $formFields
    </form>
    <script>
        // Auto-submit form on page load
        document.getElementById('payuForm').submit();
    </script>
</body>
</html>
''';
  }

  /// Handle URL changes to detect PayU callbacks
  void _handleUrlChange(String url) {
    if (kDebugMode) {
      print('URL changed: $url');
      print('PayU page loaded: $_payuPageLoaded, Has navigated: $_hasNavigated');
    }

    // IMPORTANT: Only check for callbacks AFTER PayU page has loaded
    // This prevents false positives during initial form submission
    if (!_payuPageLoaded) {
      if (kDebugMode) {
        print('Ignoring URL change - PayU page not yet loaded');
      }
      return;
    }

    // Ignore PayU domain URLs - we only want callback URLs
    if (url.contains('payu.in') || url.contains('secure.payu')) {
      if (kDebugMode) {
        print('Ignoring PayU domain URL - waiting for callback');
      }
      return;
    }

    // Get callback URLs from payload
    final successUrl = widget.paymentResponse.data.payuRedirect?.payload.surl ?? '';
    final failureUrl = widget.paymentResponse.data.payuRedirect?.payload.furl ?? '';

    if (kDebugMode) {
      print('Success URL: $successUrl');
      print('Failure URL: $failureUrl');
    }

    // Check for success callback URL - must be exact match or contains the callback domain
    if (successUrl.isNotEmpty) {
      final successUri = Uri.tryParse(successUrl);
      final currentUri = Uri.tryParse(url);
      
      if (successUri != null && currentUri != null) {
        // Check if host and path match (more strict matching)
        final isSuccessCallback = currentUri.host == successUri.host && 
                                   currentUri.path.contains(successUri.path);
        
        if (isSuccessCallback) {
          if (kDebugMode) {
            print('Payment success callback detected from URL: $url');
          }
          if (!_hasNavigated) {
            _navigateToProcessingPage();
          }
          return;
        }
      }
    }

    // Check for failure callback URL - must be exact match or contains the callback domain
    if (failureUrl.isNotEmpty) {
      final failureUri = Uri.tryParse(failureUrl);
      final currentUri = Uri.tryParse(url);
      
      if (failureUri != null && currentUri != null) {
        // Check if host and path match (more strict matching)
        final isFailureCallback = currentUri.host == failureUri.host && 
                                  currentUri.path.contains(failureUri.path);
        
        if (isFailureCallback) {
          if (kDebugMode) {
            print('Payment failure callback detected from URL: $url');
          }
          if (!_hasNavigated) {
            _navigateToProcessingPage();
          }
          return;
        }
      }
    }

    // Check for PayU response parameters in URL (only if not on PayU domain)
    final uri = Uri.tryParse(url);
    if (uri != null) {
      final status = uri.queryParameters['status'];
      final txnid = uri.queryParameters['txnid'];
      
      // Only process if we have status parameter and it's not on PayU domain
      if (status != null && txnid != null && !url.contains('payu')) {
        if (kDebugMode) {
          print('Payment status from URL: $status, TxnID: $txnid');
        }
        
        if (!_hasNavigated) {
          _navigateToProcessingPage();
        }
      }
    }
  }

  /// Launch deep-link / UPI URL in external app
  Future<void> _launchExternalDeepLink(Uri uri) async {
    try {
      if (await canLaunchUrl(uri)) {
        // Mark that we're launching a UPI app - important for lifecycle handling
        setState(() {
          _upiAppLaunched = true;
        });
        
        // Save pending payment info in case app is killed
        final orderId = widget.paymentResponse.data.order.orderId;
        final eventId = widget.paymentResponse.data.order.eventId;
        await _secureStorage.savePendingPayment(
          orderId: orderId,
          eventId: eventId,
        );
        
        if (kDebugMode) {
          print('Launching UPI/external app: $uri');
          print('UPI app launched flag set to true');
          print('Pending payment saved: orderId=$orderId, eventId=$eventId');
        }
        
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (kDebugMode) {
          print('Cannot launch external URL: $uri');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error launching external URL $uri: $e');
      }
    }
  }

  /// Check payment status via GET /api/payments/orders/{order_id}
  /// Then navigate to success or failure screen based on status
  /// 
  /// Status values:
  /// - "paid": Payment successful ✅ → Fetch ticket and show success screen
  /// - "failed": Payment failed ❌ → Show failure screen
  /// - "created": Order created, payment not initiated
  /// - "pending": Payment initiated, waiting for completion
  /// - "expired": Order expired (10 minutes)
  /// - "refunded": Payment refunded
  Future<void> _checkPaymentStatusAndNavigate() async {
    final orderId = widget.paymentResponse.data.order.orderId;
    final eventId = widget.paymentResponse.data.order.eventId;
    
    if (kDebugMode) {
      print('Checking payment status for order ID: $orderId');
      print('Event ID: $eventId');
    }

    try {
      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Verifying payment...',
                  style: TextStyle(color: Colors.white, fontSize: 16, decoration: TextDecoration.none),
                ),
              ],
            ),
          ),
        );
      }

      // Fetch order status from API: GET /api/payments/orders/{order_id}
      final orderResponse = await _paymentService.getPaymentOrder(orderId);

      final status = orderResponse.data.order.status.toLowerCase();
      
      if (kDebugMode) {
        print('Payment status check completed');
        print('Order Status: $status');
        print('Success flag: ${orderResponse.success}');
      }

      // Handle different payment statuses
      switch (status) {
        case 'paid':
          // Payment successful - fetch ticket and show success screen
          if (kDebugMode) {
            print('Payment successful! Fetching ticket...');
          }
          await _fetchTicketAndNavigateToSuccess(eventId);
          break;
          
        case 'failed':
          // Close loading dialog and show failure screen
          if (mounted) Navigator.of(context).pop();
          if (kDebugMode) {
            print('Payment failed! Navigating to failure screen.');
          }
          _navigateToFailure('Payment failed. Please try again.');
          break;
          
        case 'expired':
          // Close loading dialog
          if (mounted) Navigator.of(context).pop();
          if (kDebugMode) {
            print('Payment order expired! Navigating to failure screen.');
          }
          _navigateToFailure('Payment session expired. Please try again.');
          break;
          
        case 'refunded':
          // Close loading dialog
          if (mounted) Navigator.of(context).pop();
          if (kDebugMode) {
            print('Payment was refunded! Navigating to failure screen.');
          }
          _navigateToFailure('Payment was refunded.');
          break;
          
        case 'pending':
        case 'created':
          // Close loading dialog
          if (mounted) Navigator.of(context).pop();
          if (kDebugMode) {
            print('Payment still pending/created. Treating as incomplete.');
          }
          _navigateToFailure('Payment was not completed. Please try again.');
          break;
          
        default:
          // Close loading dialog
          if (mounted) Navigator.of(context).pop();
          if (kDebugMode) {
            print('Unknown payment status: $status');
          }
          _navigateToFailure('Unable to verify payment. Please contact support.');
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (kDebugMode) {
        print('Error checking payment status: $e');
      }

      // On error, show failure screen with helpful message
      String errorMessage = 'Unable to verify payment status. Please contact support.';
      if (e is ApiException) {
        if (e.statusCode == 404) {
          errorMessage = 'Payment order not found. Please try again.';
        } else if (e.statusCode == 401) {
          errorMessage = 'Session expired. Please log in and try again.';
        }
      }
      
      _navigateToFailure(errorMessage);
    }
  }

  /// Navigate to dedicated processing screen that will verify status
  void _navigateToProcessingPage() {
    if (_hasNavigated) return;
    _hasNavigated = true;

    final orderId = widget.paymentResponse.data.order.orderId;
    final eventId = widget.paymentResponse.data.order.eventId;

    if (kDebugMode) {
      print('Navigating to PaymentProcessingScreen with orderId=$orderId, eventId=$eventId');
    }

    Get.off(() => PaymentProcessingScreen(
          orderId: orderId,
          eventId: eventId,
        ));
  }

  /// Fetch ticket from API after successful payment
  /// GET /api/events/{event_id}/my-ticket
  Future<void> _fetchTicketAndNavigateToSuccess(int eventId) async {
    try {
      // Update loading dialog text
      if (mounted) {
        Navigator.of(context).pop(); // Close previous dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Generating your ticket...',
                  style: TextStyle(color: Colors.white, fontSize: 16, decoration: TextDecoration.none),
                ),
              ],
            ),
          ),
        );
      }

      if (kDebugMode) {
        print('Fetching ticket for event ID: $eventId');
      }

      // Fetch ticket from API: GET /api/events/{event_id}/my-ticket
      final ticketData = await _eventRequestService.getTicket(eventId);

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (kDebugMode) {
        print('Ticket fetched successfully: $ticketData');
      }

      // Extract ticket data from API response
      final ticketSecret = ticketData['ticket_secret']?.toString() ?? '';
      final eventTitle = ticketData['event_title']?.toString() ?? '';
      final venueName = ticketData['venue_name']?.toString() ?? '';
      final eventStartTime = ticketData['event_start_time']?.toString() ?? '';
      final coverImageUrl = ticketData['cover_image_url']?.toString() ?? '';

      if (ticketSecret.isEmpty) {
        if (kDebugMode) {
          print('WARNING: Ticket secret code not found in API response');
        }
      }

      // Format date from event_start_time
      String formattedDate = '';
      if (eventStartTime.isNotEmpty) {
        try {
          final dateTime = DateTime.parse(eventStartTime);
          formattedDate = DateFormat('EEEE d, MMMM yyyy').format(dateTime);
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing date: $e');
          }
          formattedDate = _eventController.date.value.isNotEmpty
              ? _eventController.date.value
              : "Date TBD";
        }
      } else {
        formattedDate = _eventController.date.value.isNotEmpty
            ? _eventController.date.value
            : "Date TBD";
      }

      // Create ticket with API data
      final ticket = UserTicket(
        title: eventTitle.isNotEmpty ? eventTitle : _eventController.eventTitle.value,
        date: formattedDate,
        location: venueName.isNotEmpty ? venueName : _eventController.loaction.value,
        code: ticketSecret,
        eventImage: coverImageUrl.isNotEmpty
            ? coverImageUrl
            : (_eventController.eventImage.value.isNotEmpty
                ? _eventController.eventImage.value
                : "assets/images/image (1).png"),
      );

      // Add ticket to controller
      _ticketController.addTicket(ticket);

      // Update event controller with API data for consistency
      if (eventTitle.isNotEmpty) {
        _eventController.eventTitle.value = eventTitle;
      }
      if (venueName.isNotEmpty) {
        _eventController.loaction.value = venueName;
      }
      if (formattedDate.isNotEmpty && formattedDate != "Date TBD") {
        _eventController.date.value = formattedDate;
      }
      if (coverImageUrl.isNotEmpty) {
        _eventController.eventImage.value = coverImageUrl;
      }
      _eventController.eventId.value = eventId;

      if (kDebugMode) {
        print('Ticket created and stored successfully');
        print('Ticket secret: $ticketSecret');
      }

      // Navigate to success screen
      _navigateToSuccess();

    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (kDebugMode) {
        print('Error fetching ticket: $e');
      }

      // Even if ticket fetch fails, payment was successful
      // Navigate to success screen - user can retry ticket fetch there
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful! Ticket will be available shortly.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      
      // Still navigate to success since payment was confirmed
      _navigateToSuccess();
    }
  }

  void _navigateToSuccess() async {
    if (kDebugMode) {
      print('Navigating to success screen');
    }
    // Clear pending payment since it's now complete
    await _secureStorage.clearPendingPayment();
    // Replace WebView with success screen (prevents back navigation to payment page)
    Get.off(() => const SucessFullPayment());
  }

  void _navigateToFailure(String message) async {
    if (kDebugMode) {
      print('Navigating to failure screen: $message');
    }
    // Clear pending payment on failure as well
    await _secureStorage.clearPendingPayment();
    // Replace WebView with failure screen (prevents back navigation to payment page)
    Get.off(() => const Failed());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Show confirmation dialog before closing
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.grey[900],
                title: const Text(
                  'Cancel Payment?',
                  style: TextStyle(color: Colors.white),
                ),
                content: const Text(
                  'Are you sure you want to cancel this payment?',
                  style: TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToFailure('Payment was cancelled');
                    },
                    child: const Text('Yes', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
        ),
        title: const Text(
          'PayU Payment',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.black,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Loading payment gateway...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

