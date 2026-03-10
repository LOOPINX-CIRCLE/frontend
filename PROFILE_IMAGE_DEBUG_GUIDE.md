# Profile Image Loading - Debugging Guide

## Issue
Profile images are showing **grey backgrounds** instead of actual user photos in:
- ✓ Sent Invites screen
- ✓ Requests screen  
- ✓ Confirmed screen

Grey background appearing means the CircleAvatar widget is rendering, but the `NetworkImage` is failing to load the actual profile picture.

---

## What Changed (Enhanced Logging)

Enhanced error handlers in all screens to log detailed information when image loading fails:

**Files Updated:**
- `sentInvitesScreen.dart` - Enhanced logging for searched users
- `eventRequests.dart` - Added error logging 
- `eventConfirmed.dart` - Updated both CircleAvatars with logging
- `eventCheckIn.dart` - Added foundation import + error logging

---

## How to Debug

### Step 1: Run the App in Debug Mode
```bash
flutter run -v
```
The `-v` flag shows verbose output including network requests.

### Step 2: Check Debug Console Output

Run the app and navigate to **Sent Invites** screen. Look for logs like:

#### SUCCESS (Images Loading)
```
[SentInvitesScreen] User: John Doe
  Raw profilePictureUrl: /api/media/s3/profile/...
  Resolved imageUrl: https://app.loopinsocial.in/api/media/s3/profile/...
```

#### FAILURE (Images NOT Loading)
```
❌ [IMAGE_LOAD_FAILED] John Doe
   Raw URL: /api/media/s3/profile/user_123.jpg
   Resolved URL: https://app.loopinsocial.in/api/media/s3/profile/user_123.jpg
   Error: XMLHttpRequest error.
   Error Type: ClientException
```

---

## What to Look For

### Problem 1: URL Resolution Issue
**Symptom:** Resolved URL is malformed or empty
```
Resolved URL: 
```
**Solution:** Check if `imageUrl()` helper is working correctly

### Problem 2: Network Error
**Symptom:** Error type is `ClientException` or similar
```
Error Type: ClientException
Error: XMLHttpRequest error.
```
**Check:** 
- Is the API server running?
- Can you access the image URL in browser?
- Check Network tab in DevTools

### Problem 3: 404 Not Found
**Symptom:** Image file doesn't exist on server
```
Error Type: SocketException
```
**Check:**
- Are profile pictures being uploaded to API?
- Is the S3 bucket path correct?

### Problem 4: CORS Issue
**Symptom:** Cross-Origin errors in console
```
Error: Cross-Origin Request Blocked
```
**Check:**
- API CORS configuration
- Image hosting service CORS settings

---

## Key Information to Collect

When reporting the issue, share console output showing:

1. **Raw URL from API**
   ```
   Raw profilePictureUrl: /api/media/s3/profile/...
   ```

2. **Resolved URL Generated**
   ```
   Resolved imageUrl: https://app.loopinsocial.in/api/media/s3/profile/...
   ```

3. **Error Type and Message**
   ```
   Error Type: ClientException
   Error: [exact error message]
   ```

4. **Network Tab Info**
   - Image request URL
   - Response status (200, 404, 403, etc.)
   - Response headers
   - Response body (if any)

---

## Testing Image URLs Directly

### In Browser
1. Copy the resolved URL from console
2. Paste into browser: `https://app.loopinsocial.in/api/media/s3/profile/...`
3. Does the image load?
   - YES → Network issue in Flutter/Dart
   - NO → Server/API issue

### Command Line
```bash
curl -I "https://app.loopinsocial.in/api/media/s3/profile/user_123.jpg"
```
Check response:
- `HTTP/1.1 200 OK` → Image exists
- `HTTP/1.1 404 Not Found` → Image missing on server
- CORS headers → CORS issue

---

## Code Structure (For Reference)

### Image URL Resolution Chain
1. **API Response** → `profilePictureUrl` field
2. **Loaders** (confirmedLoader, requestsLoader, etc.) → Pass as `imagePath` to User object
3. **Screens** → CircleAvatar widget
4. **Helper** → `imageUrl(user.imagePath)` resolves URL
5. **NetworkImage** → Attempts to load from resolved URL

### CircleAvatar Implementation
```dart
CircleAvatar(
  radius: 24,
  backgroundColor: Colors.grey[700],  // Fallback when image fails
  backgroundImage: (user.imagePath.startsWith('assets'))
      ? AssetImage(user.imagePath)  // Asset image (default avatar)
      : NetworkImage(imageUrl(user.imagePath)),  // Network image
  onBackgroundImageError: (error, stackTrace) {
    // Logs error when image fails to load
    print('❌ Image failed for ${user.name}');
    print('   URL: ${imageUrl(user.imagePath)}');
    print('   Error: $error');
  },
)
```

---

## Next Steps

1. **Run the app** and navigate to Sent Invites/Requests/Confirmed
2. **Copy console output** showing image loading attempts
3. **Check DevTools Network tab**:
   - Developer Tools → Network
   - Look for image requests (.jpg, .png, etc.)
   - Note the request URL and response status
4. **Test URL directly** in browser
5. **Share findings** for further diagnosis

---

## API Base URL Configuration

All relative image URLs are prepended with:
```
API_BASE_URL = 'https://app.loopinsocial.in'
```

If images are hosted elsewhere, `imageUrl_helper.dart` needs to be updated.

---

## Common Solutions

| Symptom | Fix |
|---------|-----|
| Empty grey circles | API not returning `profile_picture_url` |
| URL looks correct but won't load | Server/API issue, check with `curl` |
| Different images on different screens | Inconsistent data flow, check loaders |
| Works locally but not in production | API URL/CORS configuration |
| Works for some users but not others | API data upload issue for those users |

---

## Files to Monitor

- ✅ `core/utils/image_url_helper.dart` - URL resolution logic
- ✅ `HostManagement/sentInvitesScreen.dart` - Sent Invites images
- ✅ `HostManagement/eventRequests.dart` - Requests images
- ✅ `HostManagement/eventConfirmed.dart` - Confirmed images (2 lists)
- ✅ `HostManagement/eventCheckIn.dart` - Check-in images
- ✅ `HostManagement/{loaders}.dart` - Data flow from API

---

## Debug Checklist

- [ ] Run app in debug mode with `-v` flag
- [ ] Navigate to Sent Invites and check console for logs
- [ ] Note what URLs are being resolved
- [ ] Check DevTools Network tab for image requests
- [ ] Test image URL directly in browser
- [ ] Verify API is returning `profile_picture_url` field
- [ ] Check for CORS errors in console
- [ ] Confirm imageUrl() helper is working
- [ ] Share console output and network findings

---

Good luck! The enhanced logging should help pinpoint exactly where the problem is.
