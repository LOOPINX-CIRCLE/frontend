import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/Host_Pages/Controller_files/event_cntroller.dart';
import 'package:text_code/Host_Pages/Map_integration/api_services.dart';
import 'package:text_code/core/config/web_config.dart';
import 'package:text_code/core/services/web_places_service.dart';
import 'package:text_code/core/services/web_location_service.dart';

class MapController extends StatefulWidget {
  const MapController({super.key});

  @override
  State<MapController> createState() => _MapControllerState();
}

class _MapControllerState extends State<MapController> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ApiServicesMap _apiServices = ApiServicesMap();
  final EventController eventController =
      Get.find<EventController>(); // ✅ use EventController

  List<String> _suggestions = [];

  bool get isActive => _focusNode.hasFocus || _controller.text.isNotEmpty;

  Timer? _debounceTimer;
  
  void _selectLocation(String suggestion) {
    // Extract venue name (first part before comma)
    String venueName = suggestion.split(",").first.trim();
    
    if (kDebugMode) {
      print("🎯 Selected location: $suggestion");
      print("🎯 Extracted venue name: $venueName");
    }
    
    _controller.text = venueName; // Show only venue name in input
    FocusScope.of(context).unfocus();

    // ✅ Update EventController with both values
    eventController.loaction.value = suggestion; // full address for backend
    eventController.mainLocationName.value = venueName; // venue name for display
    
    // Additional location data for backend
    eventController.locationPlaceId.value = ""; // Place ID will be populated when available
    eventController.locationCountryCode.value = "IN"; // India
    
    // Set default coordinates (will be replaced with actual coordinates if needed)
    // For now using approximate coordinates for common Indian cities
    if (venueName.toLowerCase().contains('mumbai')) {
      eventController.latitude.value = 19.0760;
      eventController.longitude.value = 72.8777;
    } else if (venueName.toLowerCase().contains('delhi')) {
      eventController.latitude.value = 28.7041;
      eventController.longitude.value = 77.1025;
    } else if (venueName.toLowerCase().contains('bangalore') || venueName.toLowerCase().contains('bengaluru')) {
      eventController.latitude.value = 12.9716;
      eventController.longitude.value = 77.5946;
    } else if (venueName.toLowerCase().contains('dehradun')) {
      eventController.latitude.value = 30.3165;
      eventController.longitude.value = 78.0322;
    } else {
      // Default to Delhi coordinates
      eventController.latitude.value = 28.7041;
      eventController.longitude.value = 77.1025;
    }
    
    if (kDebugMode) {
      print("✅ EventController updated:");
      print("   Full location: ${eventController.loaction.value}");
      print("   Venue name: ${eventController.mainLocationName.value}");
      print("   Coordinates: ${eventController.latitude.value}, ${eventController.longitude.value}");
      print("   Ready for backend submission");
    }

    setState(() {
      _suggestions = [];
    });
    
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✓ Venue selected: $venueName'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  void _onSearchChanged(String input) async {
    if (kDebugMode) {
      print("🔍 MapController _onSearchChanged called with: '$input'");
      print("🌐 Running on web: ${WebConfig.isWeb}");
    }
    
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    if (input.trim().isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    // Add debounce for better performance, especially on web
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        if (kDebugMode) {
          print("🚀 Making API call for: '$input'");
        }
        
        List<String> suggestions;
        if (kIsWeb) {
          // Use JavaScript Places API for web
          suggestions = await WebPlacesService.fetchPlaceSuggestions(input);
          if (kDebugMode) {
            print("🌐 Web Places API returned: ${suggestions.length} results");
          }
        } else {
          // Use regular API service for mobile
          suggestions = await _apiServices.fetchPlaceSuggestions(input);
          if (kDebugMode) {
            print("📱 Mobile service returned: ${suggestions.length} results");
          }
        }
        
        if (mounted) {  // Check if widget is still mounted
          setState(() {
            _suggestions = suggestions;
          });
          
          if (kDebugMode) {
            print("📍 Updated UI with ${suggestions.length} suggestions");
            if (suggestions.isEmpty && input.length >= 2) {
              print("⚠️ No suggestions found for '$input' - check API key/CORS");
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("💥 Error in _onSearchChanged: $e");
          if (WebConfig.isWeb) {
            print("🌐 Web-specific error - might be CORS or API key issue");
          }
        }
        
        if (mounted) {
          setState(() => _suggestions = []);
          
          // Show user-friendly error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unable to fetch location suggestions${kIsWeb ? ' (Web)' : ''}. Please check your internet connection.'),
              backgroundColor: Colors.orange,
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () => _onSearchChanged(input),
              ),
            ),
          );
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
    
    // Initialize web places service if on web
    if (kIsWeb) {
      WebPlacesService.initialize().catchError((error) {
        if (kDebugMode) {
          print("Failed to initialize WebPlacesService: $error");
        }
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Input field with icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Image.asset(
                  "assets/icons/Map Point.png",
                  width: 24,
                  height: 24,
                  color: isActive ? Colors.white : Colors.grey,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    style: GoogleFonts.poppins(color: Colors.white),
                    onChanged: (value) {
                      _onSearchChanged(value);
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'Type to search venues, cities, areas... (e.g. "Kapil Kavuri")',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                if (_suggestions.isNotEmpty || _controller.text.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      _controller.clear();
                      FocusScope.of(context).unfocus();
                      setState(() {
                        _suggestions = [];
                      });
                    },
                    icon: const Icon(
                      Icons.clear,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
          
          // Show help text when focused but no input
          if (isActive && _controller.text.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start typing to search for locations',
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'e.g. "Kapil Kavuri", "Hyderabad", "Cyber City"',
                    style: GoogleFonts.poppins(
                      color: Colors.grey.withOpacity(0.7),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            
          // Show no results message
          if (_controller.text.isNotEmpty && _suggestions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.location_off,
                    color: Colors.grey,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No locations found',
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Try searching for a city, area, or venue name',
                    style: GoogleFonts.poppins(
                      color: Colors.grey.withOpacity(0.7),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

          // Suggestions dropdown inside the same container
          if (_suggestions.isNotEmpty)
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Suggestions header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_suggestions.length} location${_suggestions.length == 1 ? '' : 's'} found - Tap to select',
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Suggestions list
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        final suggestion = _suggestions[index];
                        return Container(
                          decoration: BoxDecoration(
                            border: index < _suggestions.length - 1
                                ? Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.withOpacity(0.2),
                                      width: 0.5,
                                    ),
                                  )
                                : null,
                          ),
                          child: ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            leading: const Icon(
                              Icons.location_on,
                              color: Colors.grey,
                              size: 18,
                            ),
                            title: Text(
                              suggestion,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _selectLocation(suggestion),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class MapPreview extends StatelessWidget {
  final String placeName;
  final String apiKey;

  const MapPreview({super.key, required this.placeName, required this.apiKey});

  @override
  Widget build(BuildContext context) {
    if (placeName.isEmpty) return const SizedBox();

    // ✅ Google Static Map API URL
    final String staticMapUrl =
        "https://maps.googleapis.com/maps/api/staticmap"
        "?center=$placeName"
        "&zoom=18"
        "&size=600x300"
        "&maptype=roadmap"
        "&markers=color:red%7Clabel:P%7C$placeName"
        "&key=$apiKey";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          placeName,
          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 10),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            staticMapUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Text(
              "⚠️ Map load failed",
              style: GoogleFonts.poppins(color: Colors.red, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
