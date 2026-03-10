import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:text_code/core/models/event.dart';
import 'package:text_code/core/models/event_invitation.dart';
import 'package:text_code/core/network/api_exception.dart';
import 'package:text_code/core/services/event_service.dart';
import 'package:text_code/core/services/event_invitation_service.dart';

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
  final EventInvitationService _invitationService = EventInvitationService();

  // Observable state
  var isLoading = false.obs;
  var events = <Event>[].obs;
  var errorMessage = Rxn<String>();

  // Invitations state
  var isLoadingInvitations = false.obs;
  var invitations = <EventInvitation>[].obs;
  var invitationsErrorMessage = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
    fetchInvitations();
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

  /// Fetch event invitations for the current user
  Future<void> fetchInvitations() async {
    isLoadingInvitations.value = true;
    invitationsErrorMessage.value = null;

    try {
      final fetchedInvitations = await _invitationService.fetchInvitations();
      invitations.value = fetchedInvitations;

      if (kDebugMode) {
        print('Fetched ${fetchedInvitations.length} invitations');
      }
    } on ApiException catch (e) {
      invitationsErrorMessage.value = e.message;
      if (kDebugMode) {
        print('Error fetching invitations: ${e.message}');
      }
    } catch (e) {
      invitationsErrorMessage.value =
          'Failed to load invitations: ${e.toString()}';
      if (kDebugMode) {
        print('Unexpected error fetching invitations: $e');
      }
    } finally {
      isLoadingInvitations.value = false;
    }
  }

  /// Refresh events
  Future<void> refreshEvents() async {
    await Future.wait([
      fetchEvents(),
      fetchInvitations(),
    ]);
  }

   /// Update invitation status locally for a given event ID
   void updateInvitationStatusForEvent(int eventId, String status) {
     final updated = invitations.map((inv) {
       if (inv.eventId == eventId) {
         return inv.copyWith(status: status);
       }
       return inv;
     }).toList();
     invitations.value = updated;
   }

  @override
  void onClose() {
    _eventService.dispose();
    super.onClose();
  }
}

