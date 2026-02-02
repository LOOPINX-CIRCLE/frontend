import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:text_code/Host_Pages/Controller_files/review_page_controller.dart';
import 'package:text_code/Host_Pages/Map_integration/map_implemtation.dart';
import 'package:text_code/core/config/web_config.dart';

class WebTestingPage extends StatelessWidget {
  final controller = Get.put(CoverImageController());

  WebTestingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web Testing - Location & Image'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Platform info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Platform Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Running on Web: ${WebConfig.isWeb}'),
                    Text('Debug Mode: ${kDebugMode}'),
                    Text('Geolocation Available: ${WebConfig.isGeolocationAvailable}'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Image picker testing
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Image Picker Test',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => controller.pickImage(0),
                      child: const Text('Test Image Picker'),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Text('Images selected: ${controller.images.length}')),
                    const SizedBox(height: 8),
                    if (controller.images.isNotEmpty)
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: kIsWeb
                            ? FutureBuilder(
                                future: controller.images.first.readAsBytes(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Image.memory(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                    );
                                  }
                                  return const Center(child: CircularProgressIndicator());
                                },
                              )
                            : const Icon(Icons.image),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Location testing
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location Search Test',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(
                      height: 200,
                      child: MapController(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}