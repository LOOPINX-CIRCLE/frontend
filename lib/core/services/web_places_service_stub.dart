// Stub implementation for non-web platforms
import 'dart:async';
import 'package:flutter/foundation.dart';

class WebPlacesService {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (kDebugMode) {
      print('📱 WebPlacesService stub - no initialization needed on mobile');
    }
    _isInitialized = true;
  }
  
  static Future<List<String>> fetchPlaceSuggestions(String input) async {
    if (kDebugMode) {
      print('📱 WebPlacesService stub - returning empty suggestions on mobile');
    }
    return [];
  }
}