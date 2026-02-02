// Web-specific configurations for Flutter app
// This file helps handle web platform differences

import 'package:flutter/foundation.dart';

class WebConfig {
  // Check if running on web platform
  static bool get isWeb => kIsWeb;
  
  // Web-specific image handling
  static const List<String> supportedImageTypes = [
    'image/jpeg',
    'image/jpg', 
    'image/png',
    'image/gif',
    'image/webp'
  ];
  
  // Maximum file size for web uploads (5MB)
  static const int maxImageSize = 5 * 1024 * 1024;
  
  // CORS headers for API requests
  static Map<String, String> get corsHeaders => {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  };
  
  // Web-specific location service configuration
  static const Map<String, dynamic> locationConfig = {
    'enableHighAccuracy': true,
    'timeout': 15000, // 15 seconds
    'maximumAge': 300000, // 5 minutes
  };
  
  // Check if geolocation is available in browser
  static bool get isGeolocationAvailable {
    if (!kIsWeb) return false;
    // This will be true for modern browsers
    return true; // We'll handle the actual check in JavaScript
  }
}