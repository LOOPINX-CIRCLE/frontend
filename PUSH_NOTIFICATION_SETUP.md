# Push Notification Integration Guide

## Overview

This guide explains how to integrate the push notification system into your Flutter app using OneSignal and the Loopin Backend API.

**Services Created:**
- `notification_service.dart` - Backend API calls for device registration/deactivation
- `onesignal_handler.dart` - OneSignal SDK initialization and handlers
- `push_notification_manager.dart` - Main manager that orchestrates everything
- `notification_navigator.dart` - Handles navigation based on notification payload

## Step 1: Update pubspec.yaml

Add the OneSignal Flutter package:

```yaml
dependencies:
  onesignal_flutter: ^5.0.0
  shared_preferences: ^2.0.0
```

Then run:
```bash
flutter pub get
```

## Step 2: Configure OneSignal App ID

In `push_notification_manager.dart`, replace `YOUR_ONESIGNAL_APP_ID` with your actual OneSignal App ID:

```dart
static const String _oneSignalAppId = 'YOUR_ONESIGNAL_APP_ID'; // Get from OneSignal dashboard
```

## Step 3: Initialize After Login

After successful user authentication, initialize push notifications in your login screen or auth service:

```dart
// In your login success handler
final pushNotificationManager = PushNotificationManager();

// Initialize push notifications
final success = await pushNotificationManager.initializeForUser(
  onNotificationTap: (notificationData) {
    // Handle notification tap navigation
    NotificationNavigator.handleNotificationTap(
      context,
      notificationData,
    );
  },
);

if (success) {
  print('✅ Push notifications initialized');
} else {
  print('⚠️ Push notifications failed to initialize');
  // App continues normally - push notifications are optional
}
```

## Step 4: Handle Notification Taps

The notification tap handler is called when a user taps a notification. Implement real navigation in `notification_navigator.dart`:

### Example: Navigate to Ticket Detail

```dart
// In notification_navigator.dart, update _navigateToTicketDetail:
static Future<void> _navigateToTicketDetail(
  BuildContext context,
  dynamic ticketId,
  dynamic eventId,
  Map<String, dynamic> arguments,
) async {
  if (ticketId == null) return;
  
  // Import your ticket detail page
  // import 'package:text_code/path/to/ticket_detail_page.dart';
  
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TicketDetailPage(
        ticketId: int.tryParse(ticketId.toString()) ?? 0,
        eventId: eventId,
      ),
    ),
  );
}
```

### Available Routes

Implement navigation for these routes in `notification_navigator.dart`:

| Route | Required Fields | Use Case |
|-------|-----------------|----------|
| `ticket_detail` | ticketId, eventId | User taps ticket confirmation notification |
| `event_detail` | eventId | User taps event update notification |
| `profile` | None | User taps profile-related notification |
| `check_in` | eventId | User taps check-in notification |
| `payment_retry` | paymentOrderId | User taps payment retry notification |
| `event_invites` | eventId | User taps event invitation notification |
| `event_requests` | eventId | User taps event request notification |

## Step 5: Deactivate on Logout

When user logs out, deactivate the device to stop receiving notifications:

```dart
// In your logout handler
final pushNotificationManager = PushNotificationManager();

try {
  await pushNotificationManager.deactivateOnLogout();
  print('✅ Device deactivated');
} catch (e) {
  print('⚠️ Error deactivating device: $e');
  // Don't block logout if deactivation fails
}

// Then proceed with logout
await authService.logout();
Navigator.pushReplacementNamed(context, '/login');
```

## Architecture & Flow

### Initialization Flow (After Login)

```
1. User logs in successfully
   ↓
2. Call PushNotificationManager.initializeForUser()
   ↓
3. Initialize OneSignal SDK → Get player ID
   ↓
4. Request notification permissions
   ↓
5. Store player ID locally (for logout deactivation)
   ↓
6. Register device with backend API
   POST /api/notifications/devices/register
   {
     "onesignal_player_id": "...",
     "platform": "ios|android"
   }
   ↓
7. Backend stores device linked to user account
   ↓
✅ Ready to receive notifications
```

### Notification Reception Flow

```
1. Backend event occurs (payment, invitation, etc.)
   ↓
2. Backend sends notification via OneSignal API
   ↓
3. OneSignal delivers to all registered devices
   ↓
4. Device receives notification
   ├─ If app closed: System shows notification
   └─ If app open: OneSignal SDK delivers to app
   ↓
5. User taps notification
   ↓
6. OneSignal SDK calls notification tap handler
   ↓
7. Extract route and reference IDs from payload
   ↓
8. NotificationNavigator routes to appropriate screen
   ├─ Load required data (event, ticket, etc.)
   └─ Display to user
```

### Logout Flow

```
1. User clicks logout
   ↓
2. Call PushNotificationManager.deactivateOnLogout()
   ↓
3. Get stored player ID
   ↓
4. Call backend API
   DELETE /api/notifications/devices/{player_id}
   ↓
5. Backend marks device as inactive
   ↓
6. Cleanup OneSignal locally
   ↓
7. Clear stored player ID
   ↓
8. Proceed with logout
   ↓
✅ Device no longer receives notifications
```

## Notification Payload Reference

When a notification is received, it contains this structure:

```dart
{
  "notification": {
    "title": "Booking Confirmed!",
    "body": "Your spot at Summer Concert is locked."
  },
  "data": {
    "type": "payment_success",
    "route": "ticket_detail",
    "event_id": 456,
    "ticket_id": 101,
    "payment_order_id": 789
  }
}
```

**Available Fields:**
- `type` - Notification category (payment_success, event_invite, event_request, etc.)
- `route` - Target screen for navigation (ticket_detail, event_detail, profile, etc.)
- `event_id` - Event ID for fetching event details
- `ticket_id` - Ticket ID for fetching ticket details
- `payment_order_id` - Payment order ID for payment-related notifications
- `invite_id` - Invitation ID for invitation-related notifications
- `request_id` - Request ID for request-related notifications

## Error Handling

All functions handle errors gracefully:

- **Registration failure**: Logged but doesn't block app
- **Deactivation failure**: Logged but doesn't block logout
- **Permission denial**: App works normally without notifications
- **Network failure**: With automatic retry logic

## Debugging

Enable debug logging by checking if `kDebugMode` is true. All services log detailed information:

```
🔔 Initializing OneSignal
🔔 Initializing push notifications for user
📱 Registering device with backend
✅ Device registered successfully
🔔 Notification tapped
📍 Navigating to: ticket_detail
```

## Testing

### Manually Test Device Registration

Use this API endpoint to verify your device is registered:

```bash
GET /api/notifications/devices
Authorization: Bearer YOUR_JWT_TOKEN
```

### Send Test Notification

Backend can send test notifications via OneSignal dashboard or API.

## Platform-Specific Notes

### Android
- Requires Firebase Cloud Messaging (FCM) setup in OneSignal
- Compile SDK 33+ required
- Runtime permissions handled by OneSignal SDK

### iOS
- Requires APNS certificate in OneSignal dashboard
- Requires NSUserNotificationCenterDelegate implementation
- iPad & iPhone both supported

## Common Issues & Solutions

### Issue: Device registration fails with 401
**Solution**: Ensure user is authenticated and JWT token is valid before initializing push notifications.

### Issue: No notifications received
**Solution**: Verify:
1. Device was registered successfully
2. OneSignal app ID is correct
3. Platform settings (ios/android) are correct in OneSignal dashboard
4. User hasn't denied notification permissions

### Issue: App crashes on notification tap
**Solution**: Implement all route handlers in `notification_navigator.dart` even if they do nothing.

## What's NOT Implemented Yet

The following need to be completed in your app code:

1. **Real OneSignal SDK**: Replace placeholder in `onesignal_handler.dart` with actual `onesignal_flutter` package calls
2. **Route handlers**: Implement actual navigation in `notification_navigator.dart` switch cases
3. **Integration points**: Add initialization calls to your login flow and deactivation calls to your logout flow
4. **App ID configuration**: Replace `YOUR_ONESIGNAL_APP_ID` with actual value

## Integration Checklist

- [ ] Add `onesignal_flutter` to pubspec.yaml
- [ ] Get OneSignal App ID from dashboard
- [ ] Configure OneSignal App ID in `push_notification_manager.dart`
- [ ] Call `PushNotificationManager.initializeForUser()` after login
- [ ] Implement route handlers in `notification_navigator.dart`
- [ ] Call `PushNotificationManager.deactivateOnLogout()` on logout
- [ ] Test device registration via backend API
- [ ] Test notification tap navigation
- [ ] Test logout device deactivation

## References

- Backend API: https://loopinbackend-g17e.onrender.com/api/docs
- OneSignal Flutter Docs: https://documentation.onesignal.com/docs/flutter-sdk-setup
- Device Registration: POST `/api/notifications/devices/register`
- Device Deactivation: DELETE `/api/notifications/devices/{player_id}`
