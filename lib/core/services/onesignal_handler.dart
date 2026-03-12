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
        print('🔔 OneSignalHandler: Initializing OneSignal with App ID: $appId');
      }

      // Initialize OneSignal with App ID
      OneSignal.initialize(appId);
      
      if (kDebugMode) {
        print('✅ OneSignal initialized successfully');
      }
      
      // Request notification permissions
      await requestNotificationPermission();

      // Give OneSignal time to initialize subscription
      if (kDebugMode) {
        print('⏳ Waiting for OneSignal to initialize subscription...');
      }
      await Future.delayed(const Duration(milliseconds: 2000));
      if (kDebugMode) {
        print('✅ OneSignal subscription initialization complete');
      }

      // Get player ID using the official method from documentation
      final playerId = await getPlayerIdFromSdk();
      _playerIdCache = playerId;

      if (kDebugMode) {
        if (_playerIdCache == null) {
          print('❌ Player ID is null - checking diagnostics');
          _printDiagnostics();
        } else {
          print('✅ Player ID obtained: $_playerIdCache');
        }
      }

      _setupNotificationHandlers();

      return _playerIdCache;
    } catch (e) {
      if (kDebugMode) {
      }
      return null;
    }
  }

  /// Print diagnostic information about OneSignal state
  void _printDiagnostics() {
    try {
      if (kDebugMode) {
        try {
          final subscription = OneSignal.User.pushSubscription;
        } catch (e) {
        }
      }
    } catch (e) {
      if (kDebugMode) {
      }
    }
  }

  /// Get player ID from OneSignal SDK
  /// Uses onesignal_flutter v5.4.0+ API that actually exists
  Future<String?> getPlayerIdFromSdk() async {
    try {
      if (kDebugMode) {
        print('🔍 Attempting to get Player ID from OneSignal SDK...');
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
          }
          
          if (playerId != null && playerId.isNotEmpty) {
            if (kDebugMode) {
            }
            return playerId;
          }
          
          // Wait before trying again
          await Future.delayed(Duration(milliseconds: checkInterval));
        } catch (e) {
          if (kDebugMode && attempts % 5 == 0) {
          }
          await Future.delayed(Duration(milliseconds: checkInterval));
        }
      }
      
      if (kDebugMode) {
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
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
        }
      });

      // Handle notification taps
      OneSignal.Notifications.addClickListener((event) {
        if (kDebugMode) {
        }
        final data = event.notification.additionalData ?? {};
        _handleNotificationTap(data);
      });

      if (kDebugMode) {
      }
    } catch (e) {
      if (kDebugMode) {
      }
    }
  }

  /// Handle notification tap - called when user taps a notification
  void _handleNotificationTap(Map<String, dynamic> data) {
    if (kDebugMode) {
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
      }

      // Request permission from OneSignal (this API exists and compiles)
      await OneSignal.Notifications.requestPermission(true);

      if (kDebugMode) {
      }
    } catch (e) {
      if (kDebugMode) {
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
    }
  }
}
