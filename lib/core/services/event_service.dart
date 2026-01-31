import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:text_code/core/services/auth_service.dart';

class EventService {
  static const String _baseUrl = 'https://loopinbackend-g17e.onrender.com/api/events';

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
      print('🖼️ Cover images: ${coverImages.length}');
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

    if (kDebugMode) {
      print('🔑 Using auth token: ${token.substring(0, 20)}...');
    }

    var uri = Uri.parse(_baseUrl);
    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['accept'] = 'application/json';

    // Required fields
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['start_time'] = startTime;
    request.fields['duration_hours'] = durationHours.toString();
    request.fields['venue_name'] = venueName; // ✅ REQUIRED field
    request.fields['location_address'] = locationAddress;
    request.fields['location_city'] = locationCity;
    request.fields['location_latitude'] = locationLatitude.toString();
    request.fields['location_longitude'] = locationLongitude.toString();
    request.fields['location_place_id'] = locationPlaceId;
    request.fields['location_country_code'] = locationCountryCode;
    request.fields['max_capacity'] = maxCapacity.toString();
    request.fields['is_paid'] = isPaid.toString();
    request.fields['ticket_price'] = ticketPrice.toString();
    request.fields['allow_plus_one'] = allowPlusOne.toString();
    request.fields['gst_number'] = gstNumber;
    request.fields['allowed_genders'] = allowedGenders;
    request.fields['status'] = status;
    request.fields['is_public'] = isPublic.toString();
    request.fields['event_interest_ids'] = eventInterestIds;

    if (kDebugMode) {
      print('📤 Request fields being sent:');
      request.fields.forEach((key, value) {
        print('   $key: $value');
      });
    }

    // Cover images (max 3)
    if (coverImages.isNotEmpty) {
      for (int i = 0; i < coverImages.length && i < 3; i++) {
        final image = coverImages[i];
        if (kIsWeb) {
          // On web, expect a map: {'bytes': Uint8List, 'filename': String, 'mimeType': String}
          final bytes = image['bytes'] as List<int>;
          final filename = image['filename'] as String;
          final mimeType = image['mimeType'] as String? ?? 'image/jpeg';
          request.files.add(
            http.MultipartFile.fromBytes(
              'cover_images',
              bytes,
              filename: filename,
              contentType: MediaType.parse(mimeType),
            ),
          );
        } else {
          // On mobile, image is a File
          final fileName = image.path.split('/').last;
          // Detect file extension and set correct contentType
          String ext = fileName.split('.').last.toLowerCase();
          MediaType? mediaType;
          if (ext == 'jpg' || ext == 'jpeg') {
            mediaType = MediaType('image', 'jpeg');
          } else if (ext == 'png') {
            mediaType = MediaType('image', 'png');
          } else if (ext == 'webp') {
            mediaType = MediaType('image', 'webp');
          }
          request.files.add(
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

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    if (kDebugMode) {
      print('📤 Event creation response status: ${response.statusCode}');
      print('📤 Response body: ${response.body}');
    }
    
    if (response.statusCode == 201) {
      if (kDebugMode) {
        print('✅ Event created successfully!');
      }
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      if (kDebugMode) {
        print('❌ Event creation failed: ${response.statusCode}');
        print('📄 Error response: ${response.body}');
      }
      throw Exception('Failed to create event: ${response.body}');
    }
  }
}
