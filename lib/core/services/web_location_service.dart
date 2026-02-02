import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:text_code/core/constants/env.dart';

class WebLocationService {
  static Future<List<String>> fetchWebLocationSuggestions(String input) async {
    if (input.trim().length < 2) return [];
    
    final String apiKey = Env.googleMapsApiKey;
    
    if (kDebugMode) {
      print("🌐 WebLocationService: Fetching for '$input'");
      print("🌐 API Key available: ${apiKey.isNotEmpty}");
    }
    
    // Try JSONP approach first (sometimes works better for web CORS)
    try {
      return await _fetchWithJSONP(input, apiKey);
    } catch (e) {
      if (kDebugMode) {
        print("🌐 JSONP failed: $e");
      }
      // Fallback to regular HTTP request
      return await _fetchWithHTTP(input, apiKey);
    }
  }
  
  static Future<List<String>> _fetchWithJSONP(String input, String apiKey) async {
    // For web, we can try using a CORS proxy or direct API call
    final String url = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
        "?input=${Uri.encodeComponent(input)}"
        "&components=country:in"
        "&key=$apiKey";
    
    if (kDebugMode) {
      print("🌐 JSONP URL: ${url.replaceAll(apiKey, 'HIDDEN')}");
    }
    
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 8));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final predictions = data['predictions'] as List<dynamic>? ?? [];
        return predictions
            .map((p) => p['description'] as String)
            .where((desc) => desc.isNotEmpty)
            .toList();
      } else {
        if (kDebugMode) {
          print("🌐 API Error: ${data['status']} - ${data['error_message'] ?? ''}");
        }
      }
    } else {
      if (kDebugMode) {
        print("🌐 HTTP Error: ${response.statusCode}");
        print("🌐 Response: ${response.body}");
      }
    }
    
    return [];
  }
  
  static Future<List<String>> _fetchWithHTTP(String input, String apiKey) async {
    // Fallback approach with different headers
    final String url = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
        "?input=${Uri.encodeComponent(input)}"
        "&components=country:in"
        "&key=$apiKey";
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (compatible; Flutter Web App)',
          'Accept': '*/*',
        },
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List<dynamic>? ?? [];
          return predictions
              .map((p) => p['description'] as String)
              .where((desc) => desc.isNotEmpty)
              .toList();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("🌐 HTTP fallback failed: $e");
      }
    }
    
    return [];
  }
}