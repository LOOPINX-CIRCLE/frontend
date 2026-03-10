# ⚡ OneSignal Push Notifications - Quick Start Guide

## ✅ What's Been Set Up

- **✓** Push notification services created
- **✓** OneSignal SDK integrated  
- **✓** Device registration with backend API implemented
- **✓** Notification handlers configured
- **✓** Login flow updated to initialize push notifications
- **✓** Dependencies added (onesignal_flutter, shared_preferences)

**What's missing:** Your OneSignal App ID

---

## 🚀 Step 1: Get Your OneSignal App ID (5 minutes)

### Create OneSignal Account
1. Go to https://onesignal.com
2. Click **Sign Up** (or Sign In if you already have account)
3. Create new account with email

### Create New App
1. Click **Create App** in dashboard
2. Enter app name: `Loopin`
3. Select **Flutter** as platform
4. Click **Create App**

### Get Your App ID
1. Go to **Settings → Keys & IDs**
2. Copy the **App ID** (looks like: `1a2b3c4d-5e6f-7g8h-9i0j-1k2l3m4n5o6p`)

---

## 🔧 Step 2: Update App ID in Code

### Update the placeholder

**File:** [lib/core/services/push_notification_manager.dart](lib/core/services/push_notification_manager.dart#L20)

Find line 20:
```dart
static const String _oneSignalAppId = 'YOUR_ONESIGNAL_APP_ID';
```

Replace `YOUR_ONESIGNAL_APP_ID` with your actual App ID:
```dart
static const String _oneSignalAppId = '1a2b3c4d-5e6f-7g8h-9i0j-1k2l3m4n5o6p';
```

---

## 📱 Step 3: Android Configuration

### Update android/app/build.gradle

Add this to `android/app/build.gradle` in the `dependencies` section:

```gradle
implementation 'com.onesignal:OneSignal:[5, 6)'
```

### Update android/build.gradle

Add this to `android/build.gradle` in the `dependencies` section:

```gradle
classpath 'com.onesignal:onesignal-gradle-plugin:[0.12.0, 0.99.99]'
```

### Apply plugin in android/app/build.gradle (at top)

Add this line near the top of the file after `plugins {`:

```gradle
id 'com.onesignal.onesignal-gradle-plugin'
```

### AndroidManifest.xml Permissions

The permissions should already be there, but verify `android/app/src/main/AndroidManifest.xml` has:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

---

## 🍎 Step 4: iOS Configuration (if testing on iOS)

### Update ios/Podfile

In `ios/Podfile`, ensure you have a platform version >= 11.0:

```ruby
platform :ios, '12.0'
```

### Add Capabilities

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** target
3. Go to **Signing & Capabilities**
4. Click **+ Capability**
5. Add **Push Notifications**
6. Add **Background Modes** (enable Remote Notifications)

### Link Certificates

You need Apple Push Notification (APN) certificate. How to:
1. In OneSignal dashboard → **Settings → Keys & IDs**
2. Scroll to **Apple Certificates**
3. Follow the instructions to upload your APN certificate

---

## ✅ Step 5: Test the Setup

### 1. Clean and run
```bash
flutter clean
flutter pub get
flutter run -v
```

### 2. Watch for these logs after login:

```
🔔 Initializing push notifications...
🔔 OneSignalHandler: Initializing OneSignal
   App ID: 1a2b3c4d-5e6f-7g8h-9i0j-1k2l3m4n5o6p
   Platform: Android
✅ OneSignal initialized
   Player ID: abc123xyz789
✅ Push notifications initialized: true
```

### 3. Verify Device Registration

In your app logs, you should see:
```
✅ Backend: Device registered successfully
```

Or check OneSignal dashboard:
1. Go to **Audience → Devices**
2. You should see your test device listed with Player ID

### 4. Send Test Notification

1. Go to OneSignal dashboard
2. Click **Messaging → New Notification**
3. Create a test notification with payload:
   ```json
   {
     "title": "Test Notification",
     "body": "Hello from Loopin!",
     "data": {
       "type": "event_detail",
       "event_id": "123"
     }
   }
   ```
4. Click **Send** → Select your device → **Send Now**
5. Watch the app - notification should appear!

---

## 📊 Expected Behavior

### When User Logs In:
1. ✅ OTP verification succeeds
2. ✅ `🔔 Initializing push notifications...` appears in logs
3. ✅ OneSignal initializes (shows Player ID)
4. ✅ Device registers with backend
5. ✅ User navigates to home page
6. ✅ Device shows in OneSignal dashboard

### When Notification is Sent:
1. 📨 Notification appears on device
2. 🔔 Tapping notification triggers navigation to correct screen
3. 📍 Navigation logs show route and data

---

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| "YOUR_ONESIGNAL_APP_ID" error | Replace placeholder with actual App ID |
| Player ID is null | Check OneSignal initialization, verify App ID is correct |
| Device not in dashboard | Check backend registration logs, verify network connection |
| Notification not received | Check device permissions, verify Android/iOS setup |
| Backend returns 401 | Auth token expired, try logging in again |
| Backend returns 403 | User doesn't have permission, check backend logs |

---

## 📝 Configuration Files Changed

1. **pubspec.yaml** - Added dependencies
   - `onesignal_flutter: ^5.0.0`
   - `shared_preferences: ^2.0.0`

2. **lib/core/services/onesignal_handler.dart** - Real SDK implementation
   - OneSignal initialization with actual SDK calls
   - Notification handlers for foreground/tap events

3. **lib/core/services/push_notification_manager.dart** - Main orchestrator
   - Device registration flow
   - Player ID storage

4. **lib/login-signup/sign_up/otp_page.dart** - Login integration
   - Push notifications initialized after successful login

---

## 🎯 Next Steps

After setup and testing:

1. **Implement notification navigation** in [lib/core/services/notification_navigator.dart](lib/core/services/notification_navigator.dart)
   - Replace TODO comments with actual screen navigation

2. **Implement logout deactivation**
   - Call `PushNotificationManager().deactivateOnLogout()` in logout handler

3. **Test different notification types**
   - Event reminders
   - Payment notifications
   - Guest updates
   - Check-in alerts

4. **Monitor in production**
   - Track delivery rates in OneSignal dashboard
   - Monitor backend registration success rate

---

## 📞 Support

If something doesn't work:
1. Check the logs with: `flutter run -v`
2. Verify App ID is correct in code and matches OneSignal dashboard
3. Ensure Android/iOS configuration is complete
4. Check network connectivity
5. Review backend notification API documentation

Good luck! 🎉
