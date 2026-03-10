import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:text_code/core/services/auth_service.dart';
import 'package:text_code/core/utils/jwt_utils.dart';
import 'package:text_code/core/network/api_client.dart';
import 'package:text_code/core/constants/api_constants.dart';

class EventCreateService {
  final ApiClient _apiClient;

  EventCreateService({ApiClient? apiClient}) 
    : _apiClient = apiClient ?? ApiClient();

  // Removed: static const String _baseUrl = 'https://loopinbackend-g17e.onrender.com/api/events';
  // Now using ApiClient which respects ApiConstants.baseUrl

  Future<Map<String, dynamic>> createEvent({
    required String title,
    required String description,
    required String startTime, // ISO format
    required double durationHours,
    required String venueName, // Required field for API
    required String locationAddress,
    required String locationCity,
    required double locationLatitude,
    required double locationLongitude,
    required String locationPlaceId,
    required String locationCountryCode,
    required int maxCapacity,
    required bool isPaid,
    required double ticketPrice,
    required double platformFee, // 10% platform fee
    required bool allowPlusOne,
    required String gstNumber,
    required String allowedGenders,
    required String status,
    required bool isPublic,
    required String eventInterestIds, // JSON array string
    required List<dynamic> coverImages, // File for mobile, Map<String, dynamic> for web
  }) async {
    if (kDebugMode) {
      print('🚀 Creating event with title: $title');
      print('🏢 Venue: $venueName');
      print('📍 Location: $locationCity, $locationAddress');
      print('🕐 Start: $startTime, Duration: ${durationHours}h');
      print('👥 Capacity: $maxCapacity, Paid: $isPaid, Price: $ticketPrice');
      print('� Platform Fee (10%): $platformFee');
      print('�🖼️ Cover images: ${coverImages.length}');
      print('🌍 Country: $locationCountryCode, PlaceID: $locationPlaceId');
    }

    final authService = AuthService();
    final token = await authService.getStoredToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('❌ No auth token found');
      }
      throw Exception('Authentication required. Please login first.');
    }

    // ✅ Trim whitespace and validate token
    final cleanToken = token.trim();
    if (cleanToken.isEmpty || !cleanToken.contains('.')) {
      if (kDebugMode) {
        print('❌ Invalid token format: token is empty or missing JWT parts');
      }
      throw Exception('Invalid token format. Please login again.');
    }

    if (kDebugMode) {
      print('🔑 Token length: ${cleanToken.length}');
      print('🔑 Token parts: ${cleanToken.split('.').length}'); // Should be 3 (header.payload.signature)
      print('🔑 Using auth token: ${cleanToken.substring(0, 20)}...');
      
      // ✅ Decode JWT to check payload
      try {
        final parts = cleanToken.split('.');
        if (parts.length == 3) {
          final payload = parts[1];
          // Add padding correctly - only add what's needed (0, 1, or 2 chars)
          String padded = payload;
          while (padded.length % 4 != 0) {
            padded += '=';
          }
          final decoded = utf8.decode(base64.decode(padded));
          final payloadJson = json.decode(decoded);
          
          print('🔐 Token Payload (decoded):');
          payloadJson.forEach((key, value) {
            if (key == 'exp') {
              final expTime = DateTime.fromMillisecondsSinceEpoch(value * 1000);
              final now = DateTime.now();
              print('   ⏰ $key: $value (expires: ${expTime.toIso8601String()})');
              print('      Current time: ${now.toIso8601String()}');
              print('      Expired: ${now.isAfter(expTime) ? 'YES ❌' : 'NO ✅'}');
            } else if (key == 'iat') {
              final iatTime = DateTime.fromMillisecondsSinceEpoch(value * 1000);
              print('   ℹ️ $key: $value (issued: ${iatTime.toIso8601String()})');
            } else {
              print('   📋 $key: $value');
            }
          });
        }
      } catch (e) {
        print('⚠️ Could not decode JWT payload: $e');
      }
    }

    // ✅ TEST: Verify token works with the same endpoint that fetches profile
    if (kDebugMode) {
      print('🧪 Testing token with ApiClient.get(/auth/profile)...');
      try {
        final testResponse = await _apiClient.get(
          '/auth/profile',
          headers: {
            'Authorization': 'Bearer $cleanToken',
          },
        );
        
        print('✅ TOKEN IS VALID - ApiClient can authenticate!');
        print('   Profile data received: ${testResponse['phone_number'] ?? 'N/A'}');
      } catch (e) {
        print('❌ TOKEN VALIDATION FAILED: $e');
      }
    }

    // ✅ Build fields map for multipart request
    final fields = <String, String>{
      'title': title,
      'description': description,
      'start_time': startTime,
      'duration_hours': durationHours.toString(),
      'venue_name': venueName,
      'location_address': locationAddress,
      'location_city': locationCity,
      'location_latitude': locationLatitude.toString(),
      'location_longitude': locationLongitude.toString(),
      'location_place_id': locationPlaceId,
      'location_country_code': locationCountryCode,
      'max_capacity': maxCapacity.toString(),
      'is_paid': isPaid.toString(),
      'ticket_price': ticketPrice.toString(),
      'platform_fee': platformFee.toString(),
      'allow_plus_one': allowPlusOne.toString(),
      'gst_number': gstNumber,
      'allowed_genders': allowedGenders,
      'status': status,
      'is_public': isPublic.toString(),
      'event_interest_ids': eventInterestIds,
    };

    if (kDebugMode) {
      print('📤 Request fields being sent:');
      fields.forEach((key, value) {
        print('   $key: $value');
      });
    }

    // ✅ Build files list
    final files = <http.MultipartFile>[];
    if (coverImages.isNotEmpty) {
      for (int i = 0; i < coverImages.length && i < 3; i++) {
        final image = coverImages[i];
        if (kIsWeb) {
          final bytes = image['bytes'] as List<int>;
          final filename = image['filename'] as String;
          final mimeType = image['mimeType'] as String? ?? 'image/jpeg';
          files.add(
            http.MultipartFile.fromBytes(
              'cover_images',
              bytes,
              filename: filename,
              contentType: MediaType.parse(mimeType),
            ),
          );
        } else {
          final fileName = image.path.split('/').last;
          String ext = fileName.split('.').last.toLowerCase();
          MediaType? mediaType;
          if (ext == 'jpg' || ext == 'jpeg') {
            mediaType = MediaType('image', 'jpeg');
          } else if (ext == 'png') {
            mediaType = MediaType('image', 'png');
          } else if (ext == 'webp') {
            mediaType = MediaType('image', 'webp');
          }
          files.add(
            await http.MultipartFile.fromPath(
              'cover_images',
              image.path,
              filename: fileName,
              contentType: mediaType,
            ),
          );
        }
      }
    }

    // ✅ USE APICLIENT.POSTMULTIPART (Same one that works for profile auth)
    if (kDebugMode) {
      print('📤 Using ApiClient.postMultipart (/events endpoint)...');
      print('📤 Files to upload: ${files.length}');
    }

    try {
      final response = await _apiClient.postMultipart(
        '/events',
        fields: fields,
        files: files,
        headers: {
          'Authorization': 'Bearer $cleanToken',
        },
      );

      if (kDebugMode) {
        print('✅ Event created successfully!');
        print('Response: ${json.encode(response)}');
      }
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Event creation failed: $e');
      }
      rethrow;
    }
  }
}
