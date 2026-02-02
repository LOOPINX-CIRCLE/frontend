import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:text_code/core/services/web_location_service.dart';

class LocationDebugPage extends StatefulWidget {
  const LocationDebugPage({super.key});

  @override
  State<LocationDebugPage> createState() => _LocationDebugPageState();
}

class _LocationDebugPageState extends State<LocationDebugPage> {
  final TextEditingController _controller = TextEditingController();
  List<String> _results = [];
  String _status = "Ready to test";
  bool _isLoading = false;

  Future<void> _testLocationSearch() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _isLoading = true;
      _status = "Searching for '$input'...";
      _results = [];
    });

    try {
      final suggestions = await WebLocationService.fetchWebLocationSuggestions(input);
      setState(() {
        _results = suggestions;
        _status = "Found ${suggestions.length} results";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = "Error: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Debug'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Platform: ${kIsWeb ? "Web" : "Mobile"}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter location (e.g., "Mumbai")',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _testLocationSearch(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testLocationSearch,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Search Location'),
            ),
            const SizedBox(height: 16),
            Text(
              'Status: $_status',
              style: TextStyle(
                color: _status.startsWith('Error') ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(_results[index]),
                    dense: true,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}