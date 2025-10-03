import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiServicesMap {
  Future<List<String>> fetchPlaceSuggestions(String input) async {
    const String apiKey = "AIzaSyBAAPv0Z6CZUdjnphbj9XH7YR1Z2jOS684";
    final Uri url = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/autocomplete/json"
      "?input=$input"
      "&components=country:in" // restrict results to India
      "&key=$apiKey",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data["status"] != "OK") {
          if (kDebugMode) {
            print("⚠️ Google API Error: ${data["status"]}");
          }
          if (kDebugMode) {
            print("📌 Message: ${data["error_message"]}");
          }
          return [];
        }
        final List<dynamic> predictions = data['predictions'];

        // Extract only the 'description' from each prediction
        List<String> suggestions = predictions
            .map((prediction) => prediction['description'] as String)
            .toList();

        return suggestions;
      } else {
        if (kDebugMode) {
          print("Failed with status code: ${response.statusCode}");
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
      return [];
    }
  }
}
