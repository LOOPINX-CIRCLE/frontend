import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'package:text_code/core/constants/env.dart';

class ApiServicesMap {
  Future<List<String>> fetchPlaceSuggestions(String input) async {
    final String apiKey = Env.googleMapsApiKey;
    
    if (kDebugMode) {
      print("🔍 fetchPlaceSuggestions called with input: '$input'");
      print("🗝️ API Key from Env: '${apiKey.isEmpty ? 'EMPTY' : 'LOADED (${apiKey.length} chars)'}");
      print("🌐 Running on web: $kIsWeb");
    }
    
    if (apiKey.isEmpty) {
      if (kDebugMode) {
        print("❌ API Key is empty!");
      }
      return [];
    }
    
    if (input.trim().length < 2) {
      if (kDebugMode) {
        print("⚠️ Input too short, skipping API call");
      }
      return [];
    }
    
    final Uri url = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/autocomplete/json"
      "?input=${Uri.encodeComponent(input.trim())}"
      "&components=country:in" // restrict results to India
      "&key=$apiKey",
    );

    if (kDebugMode) {
      print("📡 Making request to: ${url.toString().replaceAll(apiKey, 'API_KEY_HIDDEN')}");
    }

    try {
      // Add headers for web CORS compatibility
      final Map<String, String> headers = kIsWeb 
        ? {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          }
        : {};

      final response = await http.get(url, headers: headers).timeout(
        const Duration(seconds: 15), // Increased timeout
      );

      if (kDebugMode) {
        print("📥 Response status: ${response.statusCode}");
        print("📥 Response body length: ${response.body.length}");
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (kDebugMode) {
          print("📋 API Status: ${data["status"]}");
        }
        
        if (data["status"] == "OK") {
          final List<dynamic> predictions = data['predictions'] ?? [];

          // Extract only the 'description' from each prediction
          List<String> suggestions = predictions
              .map((prediction) => prediction['description'] as String)
              .where((description) => description.isNotEmpty)
              .toList();

          if (kDebugMode) {
            print("✅ Found ${suggestions.length} suggestions");
            if (suggestions.isNotEmpty) {
              print("📍 Sample suggestions:");
              for (int i = 0; i < suggestions.length && i < 3; i++) {
                print("   ${i + 1}. ${suggestions[i]}");
              }
            }
          }

          return suggestions;
        } else {
          if (kDebugMode) {
            print("⚠️ Google API returned status: ${data["status"]}");
            print("📌 Error message: ${data["error_message"] ?? 'No error message'}");
            
            // Handle common API errors for web
            if (data["status"] == "REQUEST_DENIED") {
              print("🚫 REQUEST_DENIED - Check API key and referrer restrictions");
            }
          }
          return [];
        }
      } else {
        if (kDebugMode) {
          print("❌ HTTP Error: ${response.statusCode}");
          print("📄 Response body: ${response.body}");
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print("💥 Exception in fetchPlaceSuggestions: $e");
        if (kIsWeb) {
          print("🌐 Web-specific error - this might be a CORS issue");
        }
      }
      // Return empty list instead of letting exception propagate
      return [];
    }
  }
}
