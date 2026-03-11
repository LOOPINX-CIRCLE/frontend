import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:text_code/core/network/api_client.dart';
import 'package:text_code/core/network/api_exception.dart';
import 'package:text_code/core/services/secure_storage_service.dart';
import 'package:text_code/core/models/event_interest.dart';
import 'package:text_code/core/models/user_profile.dart';
import 'package:text_code/core/constants/api_constants.dart';
import 'package:text_code/profilePage/profile_controller.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;

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
      }
      
      final response = await _apiClient.post(
        '/api/auth/signup',
        body: {
          'phone_number': formattedPhoneNumber, // Use snake_case with country code prefix
        },
        timeout: ApiConstants.otpTimeout, // Use extended timeout for OTP
      );
      
      // Check if the API operation was successful
      if (response['success'] == false) {
        final errorMessage = response['message']?.toString() ?? 'Failed to send OTP. Please try again.';
        throw ApiException(
          message: errorMessage,
          statusCode: 400,
          error: response,
        );
      }
      
      if (kDebugMode) {
      }
      
      return response;
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
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
      }
      
      final response = await _apiClient.post(
        '/api/auth/verify-otp',
        body: {
          'phone_number': formattedPhoneNumber, // Use snake_case with country code prefix
          'otp_code': otp, // Use otp_code instead of otp
        },
      );

      // Check if verification was successful and token exists
      if (response['success'] == true && response['token'] != null) {
        final token = (response['token'] as String).trim(); // âœ… Trim whitespace
        // Store token securely
        await _secureStorage.saveToken(token);

        // Fetch and cache profile immediately after login
        try {
          final profile = await fetchProfile();
          // Cache in ProfileController if available
          final profileController = Get.isRegistered<ProfileController>()
              ? Get.find<ProfileController>()
              : null;
          profileController?.setProfile(profile);
        } catch (e) {
          if (kDebugMode) {
          }
        }
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
    } on ApiException {
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
      }

      final response = await _apiClient.get(
        '/api/auth/event-interests',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
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
    } on ApiException {
      rethrow;
    } catch (error) {
      if (kDebugMode) {
      }
      throw ApiException(
        message: 'An error occurred while fetching event interests: ${error.toString()}',
        error: error,
      );
    }
  }

  /// Fetch user profile
  /// Requires authentication token in Authorization header
  /// Returns a UserProfile object
  Future<UserProfile> fetchProfile() async {
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
      }

      final response = await _apiClient.get(
        '/api/auth/profile',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      // Debug: Print raw API response for troubleshooting
      if (kDebugMode) {
      }

      // Parse response: handle both wrapped and direct profile data
      if (response.containsKey('data') && response['data'] is Map<String, dynamic>) {
        return UserProfile.fromJson(response['data'] as Map<String, dynamic>);
      } else {
        // Direct profile data (no 'data' wrapper)
        return UserProfile.fromJson(response);
      }
        } on ApiException {
      rethrow;
    } catch (error) {
      if (kDebugMode) {
      }
      throw ApiException(
        message: 'An error occurred while fetching profile: ${error.toString()}',
        error: error,
      );
    }
  }

  /// Complete user profile with multipart file upload
  /// Requires JWT token in Authorization header
  /// Uploads images as multipart files
  Future<Map<String, dynamic>> completeProfileMultipart({
    required String token,
    required String phoneNumber,
    required String name,
    required String birthDate, // YYYY-MM-DD format
    required String gender, // lowercase: male, female, other
    required List<int> eventInterests,
    required List<Map<String, dynamic>> profilePictures, // List of {bytes: Uint8List, filename: String}
  }) async {
    try {
      if (kDebugMode) {
      }

      // Prepare fields
      // For FastAPI multipart forms, arrays should be sent as JSON string without double-encoding
      final fields = <String, String>{
        'phone_number': phoneNumber,
        'name': name,
        'birth_date': birthDate,
        'gender': gender,
        'event_interests': '[${eventInterests.join(',')}]', // Send as valid JSON array string: [1,2]
      };

      // Prepare multipart files from bytes
      final files = <http.MultipartFile>[];
      for (int i = 0; i < profilePictures.length; i++) {
        final pictureData = profilePictures[i];
        final bytes = pictureData['bytes'] as Uint8List;
        String filename = pictureData['filename'] as String? ?? 'image_$i.jpg';
        
        // Detect image format from magic numbers (more reliable than filename)
        String contentType = 'image/jpeg'; // Default
        String fileExtension = '.jpg';
        
        if (bytes.length >= 4) {
          // Check magic numbers for different image formats
          if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
            // JPEG
            contentType = 'image/jpeg';
            fileExtension = '.jpg';
          } else if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
            // PNG
            contentType = 'image/png';
            fileExtension = '.png';
          } else if (bytes.length >= 12 && 
                     bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46 &&
                     bytes[8] == 0x57 && bytes[9] == 0x45 && bytes[10] == 0x42 && bytes[11] == 0x50) {
            // WEBP
            contentType = 'image/webp';
            fileExtension = '.webp';
          }
        }
        
        // Ensure filename has correct extension
        if (!filename.toLowerCase().endsWith(fileExtension)) {
          filename = 'image_$i$fileExtension';
        }
        
        // Validate file size (max 10MB per file)
        const maxFileSize = 10 * 1024 * 1024; // 10MB
        if (bytes.length > maxFileSize) {
          throw ApiException(
            message: 'File "$filename" is too large (${(bytes.length / 1024 / 1024).toStringAsFixed(2)}MB). Maximum size is 10MB.',
            statusCode: 400,
          );
        }
        
        // Validate minimum file size (at least 100 bytes for a valid image)
        const minFileSize = 100;
        if (bytes.length < minFileSize) {
          throw ApiException(
            message: 'File "$filename" is too small or corrupted (${bytes.length} bytes).',
            statusCode: 400,
          );
        }
        
        if (kDebugMode) {
        }
        
        // Try different field names - FastAPI might expect different naming
        // Common patterns: 'profile_pictures', 'profile_picture', 'files', 'images'
        final multipartFile = http.MultipartFile.fromBytes(
          'profile_pictures', // Field name - FastAPI expects this for List[UploadFile]
          bytes,
          filename: filename,
          contentType: MediaType.parse(contentType),
        );
        files.add(multipartFile);
        
        if (kDebugMode) {
        }
      }

      if (files.isEmpty) {
        throw ApiException(
          message: 'At least 1 profile picture is required',
          statusCode: 400,
        );
      }

      final response = await _apiClient.postMultipart(
        '/api/auth/complete-profile',
        fields: fields,
        files: files,
        headers: {
          'Authorization': 'Bearer $token',
        },
        timeout: ApiConstants.imageUploadTimeout, // Use longer timeout for image uploads
      );

      if (kDebugMode) {
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
    } on ApiException {
      // Re-throw ApiException with readable message
      rethrow;
    } catch (error) {
      if (kDebugMode) {
      }
      throw ApiException(
        message: 'An error occurred while completing profile: ${error.toString()}',
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
      }

      final response = await _apiClient.post(
        '/api/auth/complete-profile',
        headers: {
          'Authorization': 'Bearer $token',
        },
        body: payload,
      );

      if (kDebugMode) {
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
    } on ApiException {
      // Re-throw ApiException with readable message
      rethrow;
    } catch (error) {
      if (kDebugMode) {
      }
      throw ApiException(
        message: 'An error occurred while completing profile: ${error.toString()}',
        error: error,
      );
    }
  }

  /// Get stored token (for external use if needed)
  Future<String?> getStoredToken() async {
    final token = await _secureStorage.getToken();
    // âœ… Trim whitespace to ensure clean token
    final cleanToken = token?.trim();
    if (kDebugMode) {
      if (cleanToken != null) {
      } else {
      }
    }
    return cleanToken;
  }

  /// Clear stored token (logout)
  Future<void> logout() async {
    await _secureStorage.deleteToken();
  }

  void dispose() {
    _apiClient.close();
  }
}

