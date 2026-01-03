import 'package:flutter/foundation.dart';
import 'package:text_code/core/network/api_client.dart';
import 'package:text_code/core/network/api_exception.dart';
import 'package:text_code/core/services/secure_storage_service.dart';
import 'package:text_code/core/models/event_interest.dart';
import 'package:text_code/core/constants/api_constants.dart';

class AuthService {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

  AuthService({
    ApiClient? apiClient,
    SecureStorageService? secureStorage,
  })  : _apiClient = apiClient ?? ApiClient(),
        _secureStorage = secureStorage ?? SecureStorageService();

  /// Send OTP to phone number
  /// Returns a response with success status
  Future<Map<String, dynamic>> sendOTP({
    required String phoneNumber,
    required String countryCode, // This should be the phone code (e.g., "91"), not ISO code
  }) async {
    try {
      // Use the signup endpoint as per existing AuthRepository
      // Format: phone number with country code (e.g., +917819083469)
      // countryCode should be the numeric phone code (e.g., "91" for India)
      final formattedPhoneNumber = '+$countryCode$phoneNumber';
      
      if (kDebugMode) {
        print('Formatted phone number: $formattedPhoneNumber');
        print('Sending OTP request... (this may take up to 2 minutes)');
      }
      
      final response = await _apiClient.post(
        '/auth/signup',
        body: {
          'phone_number': formattedPhoneNumber, // Use snake_case with country code prefix
        },
        timeout: ApiConstants.otpTimeout, // Use extended timeout for OTP
      );
      
      if (kDebugMode) {
        print('OTP request completed successfully');
      }
      
      return response;
    } on ApiException catch (e) {
      if (kDebugMode) {
        print('OTP request failed: ${e.message}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error in sendOTP: $e');
      }
      rethrow;
    }
  }

  /// Verify OTP
  /// Returns a response with success status and token if valid
  /// Automatically stores the token securely on success
  Future<Map<String, dynamic>> verifyOTP({
    required String phoneNumber,
    required String countryCode, // This should be the phone code (e.g., "91"), not ISO code
    required String otp,
  }) async {
    try {
      // Format phone number with country code (e.g., +917819083469)
      final formattedPhoneNumber = '+$countryCode$phoneNumber';
      
      if (kDebugMode) {
        print('Verify OTP - Formatted phone number: $formattedPhoneNumber');
        print('Verify OTP - OTP: $otp');
      }
      
      final response = await _apiClient.post(
        '/auth/verify-otp',
        body: {
          'phone_number': formattedPhoneNumber, // Use snake_case with country code prefix
          'otp_code': otp, // Use otp_code instead of otp
        },
      );

      // Check if verification was successful and token exists
      if (response['success'] == true && response['token'] != null) {
        final token = response['token'] as String;
        // Store token securely
        await _secureStorage.saveToken(token);
       
      } else if (response['success'] == false) {
        // Handle failure cases (expired OTP, invalid OTP, etc.)
        final errorMessage = response['message']?.toString() ?? 'OTP verification failed';
        throw ApiException(
          message: errorMessage,
          statusCode: 400,
          error: response,
        );
      }

      return response;
    } on ApiException catch (e) {
      rethrow;
    }
  }

  /// Fetch event interests
  /// Requires authentication token in Authorization header
  /// Returns a list of EventInterest objects
  Future<List<EventInterest>> fetchEventInterests() async {
    try {
      // Retrieve token from secure storage
      final token = await _secureStorage.getToken();
      
      if (token == null || token.isEmpty) {
        throw ApiException(
          message: 'Authentication required. Please verify OTP first.',
          statusCode: 401,
          error: 'No token found',
        );
      }

      if (kDebugMode) {
        print('Fetching event interests with token...');
      }

      final response = await _apiClient.get(
        '/auth/event-interests',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('Event interests response: $response');
      }

      // Parse response
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> dataList = response['data'] as List<dynamic>;
        return dataList
            .map((json) => EventInterest.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException(
          message: response['message']?.toString() ?? 'Failed to fetch event interests',
          statusCode: response['statusCode'] ?? 400,
          error: response,
        );
      }
    } on ApiException catch (e) {
      rethrow;
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching event interests: $error');
      }
      throw ApiException(
        message: 'An error occurred while fetching event interests: ${error.toString()}',
        error: error,
      );
    }
  }

  /// Complete user profile
  /// Requires JWT token in Authorization header
  /// Throws readable error messages if success is false
  Future<Map<String, dynamic>> completeProfile({
    required String token,
    required Map<String, dynamic> payload,
  }) async {
    try {
      if (kDebugMode) {
        print('Completing profile with token...');
        print('Payload: $payload');
      }

      final response = await _apiClient.post(
        '/auth/complete-profile',
        headers: {
          'Authorization': 'Bearer $token',
        },
        body: payload,
      );

      if (kDebugMode) {
        print('Complete profile response: $response');
      }

      // Check if the response indicates success
      if (response['success'] == false || response.containsKey('detail')) {
        // Handle validation errors (FastAPI format)
        String errorMessage = 'Failed to complete profile';
        
        if (response['detail'] != null) {
          final detail = response['detail'];
          if (detail is List) {
            // Parse validation errors
            final errorMessages = detail.map((error) {
              if (error is Map && error['msg'] != null) {
                return error['msg'].toString();
              }
              return '';
            }).where((msg) => msg.isNotEmpty).toList();
            
            if (errorMessages.isNotEmpty) {
              errorMessage = errorMessages.join('; ');
            }
          } else if (detail is String) {
            errorMessage = detail;
          }
        } else {
          errorMessage = response['message']?.toString() ?? errorMessage;
        }
        
        throw ApiException(
          message: errorMessage,
          statusCode: response['statusCode'] ?? 400,
          error: response,
        );
      }

      return response;
    } on ApiException catch (e) {
      // Re-throw ApiException with readable message
      rethrow;
    } catch (error) {
      if (kDebugMode) {
        print('Error completing profile: $error');
      }
      throw ApiException(
        message: 'An error occurred while completing profile: ${error.toString()}',
        error: error,
      );
    }
  }

  /// Get stored token (for external use if needed)
  Future<String?> getStoredToken() async {
    return await _secureStorage.getToken();
  }

  /// Clear stored token (logout)
  Future<void> logout() async {
    await _secureStorage.deleteToken();
  }

  void dispose() {
    _apiClient.close();
  }
}

