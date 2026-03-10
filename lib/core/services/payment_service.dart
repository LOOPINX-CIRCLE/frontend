import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:text_code/core/constants/api_constants.dart';
import 'package:text_code/core/network/api_exception.dart';
import 'package:text_code/core/services/secure_storage_service.dart';
import 'package:text_code/core/models/payment_order_response.dart';

class PaymentService {
  final SecureStorageService _secureStorage = SecureStorageService();

  /// Create a payment order for a paid event
  /// 
  /// Important: No capacity reservation required. Users can create payment orders directly.
  /// Seats are confirmed ONLY after payment succeeds. Capacity is checked BEFORE payment order creation.
  /// 
  /// Business Rules:
  /// - Only for paid events (event.is_paid == true)
  /// - Order expires in 10 minutes
  /// - Returns PayU redirect payload
  /// - Seat confirmation happens at payment success (not at order creation)
  /// - Capacity is checked BEFORE creating payment order
  /// 
  /// Flow:
  /// 1. User requests to join event → Host approves (shows interest, no seat reserved)
  /// 2. User creates payment order → This endpoint (capacity checked here)
  /// 3. If seats available → Payment order created → User completes payment → PayU callback → Seat confirmed
  /// 4. If capacity full → Returns error
  /// 
  /// Returns: PaymentOrderResponse containing order details and PayU redirect payload
  Future<PaymentOrderResponse> createPaymentOrder({
    required int eventId,
    required double amount,
    int seatsCount = 1,
  }) async {
    try {
      // Get auth token
      final token = await _secureStorage.getToken();
      if (token == null) {
        throw ApiException(
          message: 'Authentication token not found',
          statusCode: 401,
        );
      }

      // Prepare request (use /api prefix to match backend routing)
      final url = Uri.parse('${ApiConstants.baseUrl}/api/payments/orders');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'accept': 'application/json',
      };

      final body = jsonEncode({
        'event_id': eventId,
        'amount': amount,
        'seats_count': seatsCount,
      });

      if (kDebugMode) {
        print('Creating payment order for event $eventId');
        print('URL: $url');
        print('Amount: $amount, Seats: $seatsCount');
        print('Request body: $body');
      }

      // Send the request
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw ApiException(
            message: 'Request timed out. Please check your connection and try again.',
            statusCode: 408,
          );
        },
      );

      if (kDebugMode) {
        print('Create payment order response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      // Handle response
      if (response.statusCode == 201) {
        // Success - payment order created
        try {
          final responseData = jsonDecode(response.body) as Map<String, dynamic>;
          
          // Parse the nested response structure
          final paymentResponse = PaymentOrderResponse.fromJson(responseData);
          
          if (kDebugMode) {
            print('Payment order created successfully');
            print('Success: ${paymentResponse.success}');
            print('Message: ${paymentResponse.message}');
            print('Order ID: ${paymentResponse.data.order.orderId}');
            print('Order Status: ${paymentResponse.data.order.status}');
            print('Amount: ${paymentResponse.data.order.amount} ${paymentResponse.data.order.currency}');
            print('PayU redirect available: ${paymentResponse.data.payuRedirect != null}');
            
            if (paymentResponse.data.payuRedirect != null) {
              print('PayU URL: ${paymentResponse.data.payuRedirect!.payuUrl}');
              print('Transaction ID: ${paymentResponse.data.payuRedirect!.payload.txnid}');
            }
          }
          
          // Validate that PayU redirect is available
          if (paymentResponse.data.payuRedirect == null) {
            if (kDebugMode) {
              print('WARNING: PayU redirect data is missing in response');
            }
            throw ApiException(
              message: 'Payment gateway information is missing. Please try again.',
              statusCode: 500,
            );
          }
          
          return paymentResponse;
        } catch (e) {
          if (e is ApiException) {
            rethrow;
          }
          
          // If JSON parsing fails, log the raw response for debugging
          if (kDebugMode) {
            print('Error parsing payment order response: $e');
            print('Raw response body: ${response.body}');
          }
          
          throw ApiException(
            message: 'Failed to parse payment order response. Please try again.',
            statusCode: 500,
          );
        }
      } else if (response.statusCode == 400) {
        // Bad request - might be capacity full, event not paid, or other validation error
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['detail'] ?? errorData['error'] ?? 'Invalid request';
          
          // Check for specific error messages
          final errorStr = errorMessage.toString().toLowerCase();
          
          // Capacity-related errors
          if (errorStr.contains('capacity') || errorStr.contains('seat')) {
            throw ApiException(
              message: errorMessage.toString(),
              statusCode: 400,
            );
          }
          
          // Event not paid error
          if (errorStr.contains('does not require payment') || 
              errorStr.contains('not require payment') ||
              errorStr.contains('not a paid event')) {
            throw ApiException(
              message: 'This event is not configured as a paid event. The event must be marked as paid in the system. Please contact the event host.',
              statusCode: 400,
            );
          }
          
          throw ApiException(
            message: errorMessage.toString(),
            statusCode: 400,
          );
        } catch (e) {
          if (e is ApiException) {
            rethrow;
          }
          throw ApiException(
            message: 'Invalid request: please check your input',
            statusCode: 400,
          );
        }
      } else if (response.statusCode == 403) {
        // Forbidden - might be event not paid or other permission issue
        try {
          final errorData = jsonDecode(response.body);
          final detail = errorData['detail'];
          throw ApiException(
            message: detail?.toString() ?? 'You do not have permission to create a payment order for this event.',
            statusCode: 403,
          );
        } catch (_) {
          throw ApiException(
            message: 'You do not have permission to create a payment order for this event.',
            statusCode: 403,
          );
        }
      } else if (response.statusCode == 404) {
        // Event not found
        try {
          final errorData = jsonDecode(response.body);
          final detail = errorData['detail'];
          throw ApiException(
            message: detail?.toString() ?? 'Event not found.',
            statusCode: 404,
          );
        } catch (_) {
          throw ApiException(
            message: 'Event not found.',
            statusCode: 404,
          );
        }
      } else if (response.statusCode == 422) {
        // Validation error
        final errorData = jsonDecode(response.body);
        final detail = errorData['detail'] as List?;
        if (detail != null && detail.isNotEmpty) {
          final firstError = detail[0] as Map<String, dynamic>;
          throw ApiException(
            message: firstError['msg'] as String? ?? 'Validation error',
            statusCode: 422,
          );
        }
        throw ApiException(
          message: 'Validation error occurred',
          statusCode: 422,
        );
      } else if (response.statusCode == 401) {
        throw ApiException(
          message: 'Authentication failed. Please log in again.',
          statusCode: 401,
        );
      } else if (response.statusCode >= 500) {
        throw ApiException(
          message: 'Server error. Please try again later.',
          statusCode: response.statusCode,
        );
      } else {
        throw ApiException(
          message: 'Failed to create payment order: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      if (kDebugMode) {
        print('Error creating payment order: $e');
      }
      throw ApiException(
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  /// Get payment order details by order ID
  /// 
  /// Fetches order details including PayU redirect information
  /// GET /api/payments/orders/{order_id}
  Future<PaymentOrderResponse> getPaymentOrder(String orderId) async {
    try {
      // Get auth token
      final token = await _secureStorage.getToken();
      if (token == null) {
        throw ApiException(
          message: 'Authentication token not found',
          statusCode: 401,
        );
      }

      // Prepare request (use /api prefix to match backend routing)
      final url = Uri.parse('${ApiConstants.baseUrl}/api/payments/orders/$orderId');
      final headers = {
        'Authorization': 'Bearer $token',
        'accept': 'application/json',
      };

      if (kDebugMode) {
        print('Fetching payment order: $url');
        print('Order ID: $orderId');
      }

      // Send the request
      final response = await http.get(
        url,
        headers: headers,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw ApiException(
            message: 'Request timed out. Please check your connection and try again.',
            statusCode: 408,
          );
        },
      );

      if (kDebugMode) {
        print('Get payment order response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      // Handle response
      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body) as Map<String, dynamic>;
          final paymentResponse = PaymentOrderResponse.fromJson(responseData);

          if (kDebugMode) {
            print('Payment order fetched successfully');
            print('Order ID: ${paymentResponse.data.order.orderId}');
            print('Order Status: ${paymentResponse.data.order.status}');
            print('PayU redirect available: ${paymentResponse.data.payuRedirect != null}');
          }

          return paymentResponse;
        } catch (e) {
          if (e is ApiException) {
            rethrow;
          }
          if (kDebugMode) {
            print('Error parsing payment order response: $e');
            print('Raw response body: ${response.body}');
          }
          throw ApiException(
            message: 'Failed to parse payment order response. Please try again.',
            statusCode: 500,
          );
        }
      } else if (response.statusCode == 404) {
        throw ApiException(
          message: 'Payment order not found.',
          statusCode: 404,
        );
      } else if (response.statusCode == 401) {
        throw ApiException(
          message: 'Authentication failed. Please log in again.',
          statusCode: 401,
        );
      } else if (response.statusCode >= 500) {
        throw ApiException(
          message: 'Server error. Please try again later.',
          statusCode: response.statusCode,
        );
      } else {
        throw ApiException(
          message: 'Failed to get payment order: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      if (kDebugMode) {
        print('Error getting payment order: $e');
      }
      throw ApiException(
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  /// Helper method to extract PayU redirect URL and payload from response
  /// Returns null if PayU redirect is not available
  static Map<String, dynamic>? extractPayURedirectData(PaymentOrderResponse response) {
    final payuRedirect = response.data.payuRedirect;
    if (payuRedirect == null) {
      return null;
    }

    return {
      'payu_url': payuRedirect.payuUrl,
      'payload': payuRedirect.payload.toFormData(),
      'order_id': response.data.order.orderId,
      'transaction_id': payuRedirect.payload.txnid,
    };
  }

  void dispose() {
    // Clean up any resources if needed
  }
}

