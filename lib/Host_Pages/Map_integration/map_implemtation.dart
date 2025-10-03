import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/Host_Pages/Controller_files/event_cntroller.dart';
import 'package:text_code/Host_Pages/Map_integration/api_services.dart';

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

  void _onSearchChanged(String input) async {
    if (input.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    final results = await _apiServices.fetchPlaceSuggestions(input);
    setState(() {
      _suggestions = results;
    });
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
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
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                "assets/icons/Map Point.png",
                width: 24,
                height: 24,
                color: isActive ? Colors.white : Colors.grey, // dynamic color
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: GoogleFonts.poppins(color: Colors.white),
                  onChanged: (value) {
                    _onSearchChanged(value);
                    setState(() {}); // update image color if needed
                  },
                  decoration: InputDecoration(
                    hintText: 'Add venue',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 📍 List of suggestions
          if (_suggestions.isNotEmpty)
            ..._suggestions.map(
              (suggestion) => ListTile(
                title: Text(
                  suggestion,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  _controller.text = suggestion;
                  FocusScope.of(context).unfocus();

                  // ✅ update both in controller
                  eventController.loaction.value = suggestion; // full address
                  eventController.mainLocationName.value = suggestion
                      .split(",")
                      .first; // sirf main name

                  setState(() {
                    _suggestions = [];
                  });
                },
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
