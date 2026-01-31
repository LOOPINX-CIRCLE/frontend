import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationTestPage extends StatefulWidget {
  const LocationTestPage({super.key});

  @override
  State<LocationTestPage> createState() => _LocationTestPageState();
}

class _LocationTestPageState extends State<LocationTestPage> {
  final TextEditingController _controller = TextEditingController();
  List<String> _suggestions = [];
  String _status = "Ready to search";
  bool _isLoading = false;

  Future<void> _testLocationSearch(String input) async {
    if (input.isEmpty) {
      setState(() {
        _suggestions = [];
        _status = "Ready to search";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = "Searching...";
      _suggestions = [];
    });

    try {
      const String apiKey = "AIzaSyBAAPv0Z6CZUdjnphbj9XH7YR1Z2jOS684";
      final Uri url = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/autocomplete/json"
        "?input=$input"
        "&components=country:in"
        "&key=$apiKey",
      );

      print("Making request to: $url");

      final response = await http.get(url);
      
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data["status"] == "OK") {
          final List<dynamic> predictions = data['predictions'];
          final suggestions = predictions
              .map((prediction) => prediction['description'] as String)
              .toList();

          setState(() {
            _suggestions = suggestions;
            _status = "Found ${suggestions.length} suggestions";
            _isLoading = false;
          });
        } else {
          setState(() {
            _status = "API Error: ${data["status"]} - ${data["error_message"] ?? 'Unknown error'}";
            _suggestions = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _status = "HTTP Error: ${response.statusCode}";
          _suggestions = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _status = "Exception: $e";
        _suggestions = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text('Location Search Test', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Status display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status:',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _status,
                    style: TextStyle(
                      color: _status.contains('Error') || _status.contains('Exception') 
                          ? Colors.red 
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Search input
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter location to search...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _isLoading 
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : null,
              ),
              onChanged: (value) {
                _testLocationSearch(value);
              },
            ),
            const SizedBox(height: 20),
            
            // Suggestions list
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _suggestions.isEmpty
                    ? const Center(
                        child: Text(
                          'No suggestions to show',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              _suggestions[index],
                              style: const TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              _controller.text = _suggestions[index];
                              FocusScope.of(context).unfocus();
                              
                              // Show selected location and venue name extraction
                              String venueName = _suggestions[index].split(",").first.trim();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Selected Location:',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text('Full: ${_suggestions[index]}'),
                                      SizedBox(height: 4),
                                      Text(
                                        'Extracted Venue Name:',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Venue: $venueName',
                                        style: TextStyle(color: Colors.yellow),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 4),
                                ),
                              );
                              
                              setState(() {
                                _suggestions = [];
                              });
                            },
                          );
                        },
                      ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Clear button
            ElevatedButton(
              onPressed: () {
                _controller.clear();
                setState(() {
                  _suggestions = [];
                  _status = "Ready to search";
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear'),
            ),
          ],
        ),
      ),
    );
  }
}