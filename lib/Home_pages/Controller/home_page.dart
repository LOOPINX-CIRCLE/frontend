import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:text_code/core/models/event.dart';
import 'package:text_code/core/network/api_exception.dart';
import 'package:text_code/core/services/event_service.dart';

class CityController extends GetxController {
  var selectedCity = "Mumbai".obs;
  var cities = [
    {"name": "Mumbai", "image": "assets/images/mumbai.png"},
    {"name": "Delhi", "image": "assets/images/delhi.png"},
    {"name": "Bangalore", "image": "assets/images/bangalore.png"},
    {"name": "Pune", "image": "assets/images/pune.png"},
  ].obs;

  void selectCity(String cityName) {
    selectedCity.value = cityName;
  }
}

class HomePageController extends GetxController {
  final EventService _eventService = EventService();

  // Observable state
  var isLoading = false.obs;
  var events = <Event>[].obs;
  var errorMessage = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  /// Fetch events from API
  Future<void> fetchEvents() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final fetchedEvents = await _eventService.fetchEvents();
      events.value = fetchedEvents;

      if (kDebugMode) {
        print('Fetched ${fetchedEvents.length} events');
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      if (kDebugMode) {
        print('Error fetching events: ${e.message}');
      }
    } catch (e) {
      errorMessage.value = 'Failed to load events: ${e.toString()}';
      if (kDebugMode) {
        print('Unexpected error fetching events: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh events
  Future<void> refreshEvents() async {
    await fetchEvents();
  }

  @override
  void onClose() {
    _eventService.dispose();
    super.onClose();
  }
}

