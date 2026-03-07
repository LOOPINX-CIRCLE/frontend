import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:onesignal_flutter/onesignal_flutter.dart';

class OneSignalHandler {
  static final OneSignalHandler _instance = OneSignalHandler._internal();

  factory OneSignalHandler() {
    return _instance;
  }

  OneSignalHandler._internal();

  String? _playerIdCache;
  String? _oneSignalAppId;
  Function(Map<String, dynamic>)? _notificationTapHandler;

  /// Initialize OneSignal
  /// Call this after user authentication
  /// Uses the exact API from Loopin Backend documentation
  Future<String?> initializeOneSignal({
    required String appId,
    void Function(Map<String, dynamic>)? onNotificationTap,
  }) async {
    try {
      _oneSignalAppId = appId;
      _notificationTapHandler = onNotificationTap;

      if (kDebugMode) {
        print('🔔 Initializing OneSignal');
        print('   App ID: $appId');
        print('   Platform: ${Platform.isIOS ? 'iOS' : 'Android'}');
      }

      // Initialize OneSignal with App ID
      OneSignal.initialize(appId);
      
      if (kDebugMode) {
        print('   ✅ OneSignal.initialize() called');
        print('   Waiting for OneSignal to initialize...');
      }
      
      // Request notification permissions
      await requestNotificationPermission();

      // Give OneSignal time to initialize subscription
      if (kDebugMode) {
        print('   Waiting for subscription to be ready...');
      }
      await Future.delayed(const Duration(milliseconds: 2000));

      // Get player ID using the official method from documentation
      final playerId = await getPlayerIdFromSdk();
      _playerIdCache = playerId;

      if (kDebugMode) {
        print('✅ OneSignal initialized');
        print('   Player ID: $_playerIdCache');
        if (_playerIdCache == null) {
          print('⚠️ DIAGNOSTIC INFO:');
          print('   OneSignal App ID was set: ${_oneSignalAppId != null}');
          print('   Notification permission was requested');
          _printDiagnostics();
        }
      }

      _setupNotificationHandlers();

      return _playerIdCache;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to initialize OneSignal: $e');
      }
      return null;
    }
  }

  /// Print diagnostic information about OneSignal state
  void _printDiagnostics() {
    try {
      if (kDebugMode) {
        print('   Checking OneSignal subscription state:');
        try {
          final subscription = OneSignal.User.pushSubscription;
          print('      Subscription object exists: ${subscription != null}');
          print('      Subscription.id: "${subscription.id}"');
          print('      Subscription.id type: ${subscription.id.runtimeType}');
          print('      Subscription.id isEmpty: ${subscription.id?.isEmpty}');
          print('      Subscription.optedIn: ${subscription.optedIn}');
        } catch (e) {
          print('      Error accessing subscription: $e');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('   Error printing diagnostics: $e');
      }
    }
  }

  /// Get player ID from OneSignal SDK
  /// Uses onesignal_flutter v5.4.0+ API that actually exists
  Future<String?> getPlayerIdFromSdk() async {
    try {
      if (kDebugMode) {
        print('   Fetching player ID from OneSignal SDK...');
      }
      
      final maxWaitTime = 8000; // 8 seconds total wait
      final checkInterval = 300; // Check every 300ms
      
      final stopwatch = Stopwatch()..start();
      String? playerId;
      int attempts = 0;
      
      while (stopwatch.elapsedMilliseconds < maxWaitTime) {
        attempts++;
        
        try {
          // Get the player ID from OneSignal subscription (this API exists and compiles)
          playerId = OneSignal.User.pushSubscription.id;
          
          if (kDebugMode && attempts % 5 == 0) {
            print('   ⏳ Attempt $attempts: ID="${playerId}", ${stopwatch.elapsedMilliseconds}ms');
          }
          
          if (playerId != null && playerId.isNotEmpty) {
            if (kDebugMode) {
              print('   ✅ Player ID obtained: $playerId');
            }
            return playerId;
          }
          
          // Wait before trying again
          await Future.delayed(Duration(milliseconds: checkInterval));
        } catch (e) {
          if (kDebugMode && attempts % 5 == 0) {
            print('   ⚠️ Error accessing device state (attempt $attempts): $e');
          }
          await Future.delayed(Duration(milliseconds: checkInterval));
        }
      }
      
      if (kDebugMode) {
        print('   ❌ Player ID timed out after ${stopwatch.elapsedMilliseconds}ms');
        print('   ⚠️ This typically means:');
        print('      - OneSignal SDK not fully initialized on native layer');
        print('      - Device requires network connectivity for ID generation');
        print('      - Check OneSignal Dashboard → App Settings');
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error getting player ID from SDK: $e');
      }
      return null;
    }
  }

  /// Get the current player ID
  /// Returns null if OneSignal hasn't been initialized
  String? getPlayerId() {
    return _playerIdCache;
  }

  /// Get the platform type
  /// Returns 'ios' or 'android'
  String getPlatform() {
    return Platform.isIOS ? 'ios' : 'android';
  }

  /// Setup notification handlers for received and opened events
  void _setupNotificationHandlers() {
    try {
      // Handle foreground notifications
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        if (kDebugMode) {
          print('🔔 Notification received (foreground): ${event.notification.body}');
        }
      });

      // Handle notification taps
      OneSignal.Notifications.addClickListener((event) {
        if (kDebugMode) {
          print('🔔 Notification tapped');
        }
        final data = event.notification.additionalData ?? {};
        _handleNotificationTap(data);
      });

      if (kDebugMode) {
        print('🔔 Notification handlers configured');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error setting up notification handlers: $e');
      }
    }
  }

  /// Handle notification tap - called when user taps a notification
  void _handleNotificationTap(Map<String, dynamic> data) {
    if (kDebugMode) {
      print('🔔 Notification tapped');
      print('   Data: $data');
    }

    // Call the registered handler if provided
    if (_notificationTapHandler != null) {
      _notificationTapHandler!(data);
    }
  }

  /// Request notification permissions from the user
  /// Uses onesignal_flutter v5.4.0+ API
  Future<void> requestNotificationPermission() async {
    try {
      if (kDebugMode) {
        print('🔔 Requesting notification permissions');
      }

      // Request permission from OneSignal (this API exists and compiles)
      await OneSignal.Notifications.requestPermission(true);

      if (kDebugMode) {
        print('✅ Notification permission requested');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error requesting notification permission: $e');
      }
      // Don't rethrow - permission denial should not block app functionality
    }
  }

  /// Cleanup OneSignal on logout
  void cleanup() {
    _playerIdCache = null;
    _oneSignalAppId = null;
    _notificationTapHandler = null;

    if (kDebugMode) {
      print('🔔 OneSignal cleaned up on logout');
    }
  }
}
