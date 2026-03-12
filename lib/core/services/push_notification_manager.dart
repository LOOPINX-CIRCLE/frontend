import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_code/core/services/notification_service.dart';
import 'package:text_code/core/services/onesignal_handler.dart';

class PushNotificationManager {
  static final PushNotificationManager _instance =
      PushNotificationManager._internal();

  factory PushNotificationManager() {
    return _instance;
  }

  PushNotificationManager._internal();

  final NotificationDeviceService _deviceService = NotificationDeviceService();
  final OneSignalHandler _oneSignal = OneSignalHandler();

  static const String _playerIdStorageKey = 'onesignal_player_id';
  // ⚠️ IMPORTANT: Replace 'YOUR_ONESIGNAL_APP_ID' with your actual OneSignal App ID
  // Get it from: https://onesignal.com → Settings → Keys & IDs
  static const String _oneSignalAppId = '30833fb7-d4f1-4cf5-aef7-c42f59cdbc61';

  /// Initialize push notifications for a logged-in user
  /// Call this after successful login
  /// The notification tap handler lets you customize navigation behavior
  Future<bool> initializeForUser({
    void Function(Map<String, dynamic>)? onNotificationTap,
  }) async {
    try {
      if (kDebugMode) {
        print('═════════════════════════════════════════════════════════');
        print('🔔 INITIALIZING PUSH NOTIFICATIONS FOR USER');
        print('═════════════════════════════════════════════════════════');
      }

      // ⚠️ Check if App ID is still placeholder
      if (_oneSignalAppId == 'YOUR_ONESIGNAL_APP_ID') {
        if (kDebugMode) {
          print('❌ CRITICAL: OneSignal App ID not configured!');
          print('   You must replace "YOUR_ONESIGNAL_APP_ID" with your actual App ID');
          print('   Go to: https://onesignal.com → Settings → Keys & IDs');
          print('   Then update: lib/core/services/push_notification_manager.dart line 23');
        }
        return false;
      }

      // Step 1: Initialize OneSignal SDK
      final playerId = await _oneSignal.initializeOneSignal(
        appId: _oneSignalAppId,
        onNotificationTap: onNotificationTap,
      );

      if (kDebugMode) {
        print('Step 1 Complete: OneSignal initialization');
        print('   ➜ Player ID: $playerId');
        print('   ➜ Player ID is null? ${playerId == null}');
      }

      if (playerId == null || playerId.isEmpty) {
        if (kDebugMode) {
          print('❌ OneSignal player ID is null or empty');
          print('   Possible causes:');
          print('   - OneSignal app ID is invalid');
          print('   - Notification permissions were denied');
          print('   - OneSignal SDK failed to initialize');
        }
        return false;
      }

      // Step 2: Store player ID locally for potential reuse
      await _storePlayerIdLocally(playerId);

      // Step 3: Register device with backend
      await _registerDeviceWithBackend(playerId);
      
      if (kDebugMode) {
        print('Step 3 Complete: Backend registration attempted');
      }

      if (kDebugMode) {
        print('═════════════════════════════════════════════════════════');
        print('✅ PUSH NOTIFICATIONS INITIALIZED SUCCESSFULLY');
        print('═════════════════════════════════════════════════════════');
        print('   📱 Player ID: $playerId');
        print('   🔌 Platform: ${_oneSignal.getPlatform()}');
        print('   💾 Status: Device registered with backend');
        print('═════════════════════════════════════════════════════════');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to initialize push notifications: $e');
      }
      // Don't rethrow - push notification failure shouldn't block app
      return false;
    }
  }

  /// Register device with Loopin backend
  /// This links the OneSignal player ID to the user's account
  Future<void> _registerDeviceWithBackend(String playerId) async {
    try {
      if (kDebugMode) {
        print('═══════════════════════════════════════════════════════════');
        print('📱 REGISTERING DEVICE WITH BACKEND');
        print('═══════════════════════════════════════════════════════════');
        print('   🔑 Player ID: $playerId');
      }

      final platform = _oneSignal.getPlatform(); // 'ios' or 'android'

      if (kDebugMode) {
        print('   🔌 Platform: $platform');
        print('   🔌 Platform: $platform');
      }

      final success = await _deviceService.registerDevice(
        oneSignalPlayerId: playerId,
        platform: platform,
      );

      if (kDebugMode) {
        print('   📤 Backend Response: $success');
      }

      if (success['success'] == true) {
        if (kDebugMode) {
          print('   ✅ BACKEND REGISTRATION SUCCESSFUL! Device registered with user account');
        }
      } else {
        if (kDebugMode) {
          print('   ❌ BACKEND REGISTRATION FAILED: ${success['message'] ?? success['error'] ?? 'Unknown error'}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('   ❌ EXCEPTION: Error registering device with backend: $e');
      }
    }
  }

  /// Deactivate device on logout
  /// Call this when user logs out
  Future<void> deactivateOnLogout() async {
    try {
      if (kDebugMode) {
        print('🔔 Deactivating device on logout');
      }

      // Get stored player ID
      final playerId = await _getStoredPlayerId();

      if (playerId != null) {
        // Deactivate with backend
        await _deviceService.deactivateDevice(
          oneSignalPlayerId: playerId,
        );

        if (kDebugMode) {
          print('✅ Device deactivated');
        }
      }

      // Cleanup OneSignal locally
      _oneSignal.cleanup();

      // Clear stored player ID
      await _clearStoredPlayerId();
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error during device deactivation: $e');
      }
      // Don't block logout if deactivation fails
    }
  }

  /// Store player ID locally
  /// Useful for device deactivation on logout
  Future<void> _storePlayerIdLocally(String playerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_playerIdStorageKey, playerId);

      if (kDebugMode) {
        print('💾 Player ID stored locally');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to store player ID: $e');
      }
    }
  }

  /// Retrieve stored player ID
  Future<String?> _getStoredPlayerId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_playerIdStorageKey);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to retrieve player ID: $e');
      }
      return null;
    }
  }

  /// Clear stored player ID
  Future<void> _clearStoredPlayerId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_playerIdStorageKey);

      if (kDebugMode) {
        print('💾 Player ID cleared from storage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to clear player ID: $e');
      }
    }
  }

  /// Get current player ID
  String? getCurrentPlayerId() {
    return _oneSignal.getPlayerId();
  }

  /// Get current platform
  String getPlatform() {
    return _oneSignal.getPlatform();
  }
}
