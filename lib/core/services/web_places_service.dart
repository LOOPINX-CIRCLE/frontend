// Web-specific Places service using JavaScript interop
import 'dart:js' as js;
import 'package:flutter/foundation.dart';
import 'dart:async';

class WebPlacesService {
  static bool _isInitialized = false;
  static final Completer<void> _initCompleter = Completer<void>();

  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    if (kDebugMode) {
      print('🚀 Initializing WebPlacesService...');
    }
    
    // Check if Google Maps is loaded
    if (js.context.hasProperty('google') && 
        js.context['google'].hasProperty('maps') &&
        js.context['google']['maps'].hasProperty('places')) {
      _isInitialized = true;
      _initCompleter.complete();
      if (kDebugMode) {
        print('✅ Google Maps Places API already loaded');
      }
      return;
    }
    
    // Wait for Google Maps to load
    const maxAttempts = 100; // Increased attempts
    int attempts = 0;
    
    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
      
      if (js.context.hasProperty('google') && 
          js.context['google'].hasProperty('maps') &&
          js.context['google']['maps'].hasProperty('places')) {
        _isInitialized = true;
        _initCompleter.complete();
        if (kDebugMode) {
          print('✅ Google Maps Places API loaded after ${attempts * 100}ms');
        }
        return;
      }
      
      if (kDebugMode && attempts % 10 == 0) {
        print('⏳ Still waiting for Google Maps API... (${attempts * 100}ms)');
      }
    }
    
    if (kDebugMode) {
      print('❌ Google Maps Places API failed to load after ${maxAttempts * 100}ms');
      print('Available properties: ${js.context.callMethod('Object.keys', [js.context])}');
    }
    _initCompleter.completeError('Google Maps Places API failed to load');
  }
  
  static Future<List<String>> fetchPlaceSuggestions(String input) async {
    if (!kIsWeb) return [];
    
    try {
      if (!_isInitialized) {
        await _initCompleter.future;
      }
      
      if (kDebugMode) {
        print('🔍 WebPlacesService: Fetching suggestions for "$input"');
      }
      
      final completer = Completer<List<String>>();
      
      // Create JavaScript function to handle Places Autocomplete
      js.context['flutterPlacesCallback'] = js.allowInterop((List results) {
        final suggestions = results.cast<String>();
        if (kDebugMode) {
          print('📍 WebPlacesService: Got ${suggestions.length} suggestions');
        }
        completer.complete(suggestions);
      });
      
      js.context['flutterPlacesError'] = js.allowInterop((error) {
        if (kDebugMode) {
          print('❌ WebPlacesService error: $error');
        }
        completer.complete([]);
      });
      
      // Execute JavaScript to get predictions
      js.context.callMethod('eval', ['''
        (function() {
          try {
            var service = new google.maps.places.AutocompleteService();
            service.getPlacePredictions({
              input: "$input",
              componentRestrictions: { country: 'IN' },
              types: ['establishment', 'geocode']
            }, function(predictions, status) {
              if (status === google.maps.places.PlacesServiceStatus.OK && predictions) {
                var descriptions = predictions.map(function(prediction) {
                  return prediction.description;
                });
                flutterPlacesCallback(descriptions);
              } else {
                console.log('Places API status:', status);
                flutterPlacesCallback([]);
              }
            });
          } catch (error) {
            console.error('Places API error:', error);
            flutterPlacesError(error.message);
          }
        })();
      ''']);
      
      return completer.future;
    } catch (e) {
      if (kDebugMode) {
        print('💥 WebPlacesService exception: $e');
      }
      return [];
    }
  }
}