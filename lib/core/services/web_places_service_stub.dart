// Stub implementation for non-web platforms
import 'dart:async';
import 'package:flutter/foundation.dart';

class WebPlacesService {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (kDebugMode) {
    }
    _isInitialized = true;
  }
  
  static Future<List<String>> fetchPlaceSuggestions(String input) async {
    if (kDebugMode) {
    }
    return [];
  }
}
