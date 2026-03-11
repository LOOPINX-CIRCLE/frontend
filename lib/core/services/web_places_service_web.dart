// Web-specific Places service using JavaScript interop
import 'dart:async';
import 'dart:js' as js;
import 'package:flutter/foundation.dart';

class WebPlacesService {
  static bool _isInitialized = false;
  static final Completer<void> _initCompleter = Completer<void>();

  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    if (kDebugMode) {
    }
    
    try {
      // Check if Google Maps is loaded
      if (js.context.hasProperty('google') && 
          js.context['google'].hasProperty('maps') &&
          js.context['google']['maps'].hasProperty('places')) {
        _isInitialized = true;
        if (!_initCompleter.isCompleted) {
          _initCompleter.complete();
        }
        if (kDebugMode) {
        }
        return;
      }
      
      // Wait for Google Maps to load
      const maxAttempts = 100;
      int attempts = 0;
      
      while (attempts < maxAttempts) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
        
        if (js.context.hasProperty('google') && 
            js.context['google'].hasProperty('maps') &&
            js.context['google']['maps'].hasProperty('places')) {
          _isInitialized = true;
          if (!_initCompleter.isCompleted) {
            _initCompleter.complete();
          }
          if (kDebugMode) {
          }
          return;
        }
        
        if (kDebugMode && attempts % 10 == 0) {
        }
      }
      
      if (kDebugMode) {
      }
      if (!_initCompleter.isCompleted) {
        _initCompleter.completeError('Google Maps Places API failed to load');
      }
    } catch (e) {
      if (kDebugMode) {
      }
      if (!_initCompleter.isCompleted) {
        _initCompleter.completeError(e);
      }
    }
  }
  
  static Future<List<String>> fetchPlaceSuggestions(String input) async {    
    try {
      if (!_isInitialized) {
        await _initCompleter.future;
      }
      
      if (kDebugMode) {
      }
      
      final completer = Completer<List<String>>();
      
      // Create JavaScript function to handle Places Autocomplete
      js.context['flutterPlacesCallback'] = js.allowInterop((List results) {
        final suggestions = results.cast<String>();
        if (kDebugMode) {
        }
        if (!completer.isCompleted) {
          completer.complete(suggestions);
        }
      });
      
      js.context['flutterPlacesError'] = js.allowInterop((error) {
        if (kDebugMode) {
        }
        if (!completer.isCompleted) {
          completer.complete([]);
        }
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
      
      return await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          if (kDebugMode) {
          }
          return <String>[];
        },
      );
    } catch (e) {
      if (kDebugMode) {
      }
      return [];
    }
  }
}
