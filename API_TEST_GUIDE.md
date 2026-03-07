# Loopin API Testing Guide

## Fixed Issues ✅
- **SentInvitesScreen was 100% commented out** → Fixed by switching to `SendInvitesScreen`
- **Invites were not refreshing after sending** → Fixed: callback chain now properly refreshes list

---

## API Flow Testing Checklist

### 1. SEND INVITE FLOW
**Status**: ✅ FIXED AND READY TO TEST

**Flow:**
```
User clicks "Send Invites" button
    ↓
InvitesLoader opens SendInvitesScreen (FIXED: was using commented-out SentInvitesScreen)
    ↓
User searches for users (GET /api/events/users/search)
    ↓
User selects users & clicks "Send"
    ↓
SendInvitesScreen calls POST /api/events/{eventId}/invitations
    ↓
onInvitesSent callback triggers → InvitesLoader refreshes list
    ↓
New invited users appear in list
```

**Test Steps:**
1. Run app and navigate to Host Management
2. Click "Invited" tab → Click "Send Invites" button
3. Search for a user (type 2+ characters)
4. Select 1-3 users
5. Add optional message
6. Click "Send"
7. **Expected**: 
   - ✅ Success SnackBar showing "Created: X, Skipped: Y"
   - ✅ Invited users list REFRESHES and shows new invites
   - ✅ Count updates without leaving page

**API Endpoints Used:**
- ✅ GET `/api/events/users/search` - Search users
- ✅ POST `/api/events/{eventId}/invitations` - Send invites
- ✅ GET `/api/events/{eventId}/invitations?status_filter=pending` - Reload invites

---

### 2. INVITED USERS LIST DISPLAY
**Status**: ✅ WORKING

**Flow:**
```
User opens "Invited" tab
    ↓
InvitesLoader fetches GET /api/events/{eventId}/invitations?status_filter=pending
    ↓
Displays all pending invitations in EventInvited component
    ↓
Shows search & filter functionality
```

**Test Steps:**
1. Open "Invited" tab
2. Verify invited users appear
3. Search for a user by name
4. Verify count matches actual list

**API Endpoints Used:**
- ✅ GET `/api/events/{eventId}/invitations` - Get invited users list

---

### 3. COUNT UPDATES (REAL-TIME)
**Status**: ⚠️ NEEDS VERIFICATION

**Components Involved:**
- MainScreen._fetchActualInvitedCount() - Fetches from API on init
- Count should refresh after:
  - Sending new invites
  - User accepts invite → moves to confirmed
  - User rejects → removed from pending

**Test Steps:**
1. Note current "Invited" count
2. Send invites to new users
3. **Expected**: Count updates WITH REFRESH needed OR shows immediately
4. Go back to main screen
5. Verify count reflects all pending invitations

**API Endpoints Used:**
- ✅ GET `/api/events/{eventId}/invitations` - Get count (length of pending)

---

### 4. CONFIRM/REQUEST ACCEPTANCE FLOW
**Status**: ✅ IMPLEMENTED

**Flow:**
```
Join requests come in
    ↓
RequestsLoader fetches requests
    ↓
User clicks "Accept All" or selects individual requests
    ↓
Calls PUT /api/events/{eventId}/requests/{requestId}/accept
    ↓
Users moved to "Confirmed" list
    ↓
Count updates
```

**Test Steps:**
1. Open "Requests" tab
2. Select individual request or "Select All"
3. Click "Accept All"
4. **Expected**:
   - ✅ Request removed from pending list
   - ✅ User appears in "Confirmed" list
   - ✅ Count updates

**API Endpoints Used:**
- ✅ PUT `/api/events/{eventId}/requests/{requestId}/accept` - Accept single request
- ✅ GET `/api/events/{eventId}/requests/pending` - Get pending requests

---

### 5. CHECK-IN FLOW
**Status**: ✅ WORKING

**Flow:**
```
User opens "Start Check-In"
    ↓
Gets confirmed users + check-in status
    ↓
Displays check-in list
    ↓
User scans/enters ticket secret
    ↓
POST /api/events/{eventId}/check-in with ticket_secret
    ↓
User marked as checked-in
    ↓
Button changes to "Checked In" (grayed out)
    ↓
Count updates in main screen
```

**Test Steps:**
1. Click "Start Check-In" tab
2. Verify list shows confirmed users with ticket secrets
3. Click check-in button on a user
4. **Expected**:
   - ✅ Button changes to "Checked In" (gray)
   - ✅ User stays visible in list
   - ✅ Check-in count increases
   - ✅ Confirmed count stays the same

**API Endpoints Used:**
- ✅ GET `/api/events/{eventId}/attendees` - Get confirmed users with ticket_secret
- ✅ POST `/api/events/{eventId}/check-in` - Check-in with ticket_secret

---

### 6. BULK ACTIONS
**Status**: ⚠️ VERIFY WORKING

**Implemented Bulk Actions:**
1. **Accept All Requests**
   - Endpoint: PUT `/api/events/{eventId}/requests/{requestId}/accept`
   - Tested in flow #4

2. **Select All Invites / Requests / Confirmed**
   - UI feature to select all items (no API needed)

**Test Steps for Bulk Accept:**
1. Open "Requests" tab
2. Click "Select All" checkbox
3. All requests should select (UI changes)
4. Click "Accept All" button
5. **Expected**: All requests moved to confirmed in batch

**Status**: Need to verify if backend supports true bulk accept or does individual requests.

---

## All API Endpoints Reference

### INVITATIONS APIs
| Method | Endpoint | Purpose | Response |
|--------|----------|---------|----------|
| POST | `/api/events/{eventId}/invitations` | Send invites to multiple users | `{success, created_count, skipped_count, invites[], errors[]}` |
| GET | `/api/events/{eventId}/invitations` | Get list of sent invitations | `{invitations:[{invite_id, user_id, full_name, status, expires_at}]}` |
| GET | `/api/events/users/search` | Search users to invite | `{total, offset, limit, data:[{id, full_name, username, profile_picture_url}]}` |

### REQUESTS APIs
| Method | Endpoint | Purpose | Response |
|--------|----------|---------|----------|
| PUT | `/api/events/{eventId}/requests/{requestId}/accept` | Accept single request | `{success, request_id, user_id, status}` |
| GET | `/api/events/{eventId}/requests/pending` | Get pending requests | `[{request_id, user_id, full_name, ...}]` |
| GET | `/api/events/{eventId}/requests` | Get all requests | `[{...request_data...}]` |

### CONFIRMED/ATTENDEES APIs
| Method | Endpoint | Purpose | Response |
|--------|----------|---------|----------|
| GET | `/api/events/{eventId}/attendees` | Get confirmed attendees | `{going_count, attendees:[{user_id, full_name, ticket_secret, checked_in}]}` |

### CHECK-IN APIs
| Method | Endpoint | Purpose | Response |
|--------|----------|---------|----------|
| POST | `/api/events/{eventId}/check-in` | Check-in user with ticket secret | `{success, already_checked_in, attendance_record}` |

---

## Testing Sequence (RECOMMENDED ORDER)

### Step 1: Verify Send Invites Flow (15 min)
- ✅ Open app
- ✅ Click Invited tab
- ✅ Click "Send Invites"
- ✅ Search & select users
- ✅ Send invitations
- ✅ **Verify**: List refreshes, new users appear

### Step 2: Verify Join Requests Flow (15 min)
- ✅ Navigate to test join requests
- ✅ Check pending requests load
- ✅ Accept individual request
- ✅ **Verify**: Moves to confirmed

### Step 3: Verify Check-In Flow (15 min)
- ✅ Click "Start Check-In"
- ✅ Click check-in button on user
- ✅ **Verify**: User marked as checked-in, count updates

### Step 4: Verify Counts Update Correctly (10 min)
- ✅ Go back to main screen
- ✅ Verify all counts reflect current state
- ✅ Re-enter tabs to verify persistence

### Step 5: Verify Search & Filtering (10 min)
- ✅ In each tab, test search functionality
- ✅ Test filter options (if available)

---

## Known Issues & Fixes Applied

### Issue #1: SentInvitesScreen Completely Commented Out ✅ FIXED
**Before:**
```
invitesLoader.dart tried to use SentInvitesScreen which was 100% commented out
→ Would crash when user tried to send invites
```

**After:**
```
Changed to use SendInvitesScreen from sendInvitesDialog.dart
→ Fully functional with search, message, and batch sending
```

**Files Changed:**
- `lib/HostManagement/invitesLoader.dart` - Updated import and screen reference

### Issue #2: Invites Not Refreshing After Send ✅ FIXED
**Before:**
```
User sends invites → Dialog closes → List doesn't refresh
→ Newly invited users don't appear until navigating away
```

**After:**
```
SendInvitesScreen calls onInvitesSent callback
→ InvitesLoader setState(() { _invitesFuture = _loadInvites(); })
→ List refreshes immediately with new invites
```

---

## Debug Logging

### To see API calls in console:
All API services use `kDebugMode` for logging.

**Screenshots to capture during testing:**
1. `📤 Sending invitations to {eventId}` - Sending invites
2. `📥 Invitation response status: 200` - Success response
3. `✅ Invitations processed: Created: X, Skipped: Y` - Result

---

## Next Steps If Issues Found

### If invites don't refresh:
- [ ] Check browser console for errors (Flutter web)
- [ ] Check Android logcat (Flutter mobile)
- [ ] Verify API returns 200 status
- [ ] Check that onInvitesSent is being called

### If counts don't update:
- [ ] Verify API returns correct pending count
- [ ] Check MainScreen._fetchActualInvitedCount() is called
- [ ] Verify statusFilter: 'pending' is being sent

### If accept all requests fails:
- [ ] Check if backend supports bulk accept or needs individual requests
- [ ] Verify requestId is valid
- [ ] Check authorization token is valid

---

## Success Criteria ✅

**All of these should work end-to-end:**
1. ✅ Send invites → List refreshes immediately (no page reload needed)
2. ✅ Counts update correctly (invited, confirmed, requests, check-in)
3. ✅ Searching for users works with debounce
4. ✅ Accept requests moves users to confirmed
5. ✅ Check-in marks users as checked in
6. ✅ All data persists across navigation
7. ✅ No crashes or error screens during flow
8. ✅ Error messages display clearly if API fails

---

Generated: Feb 10, 2026
Last Updated: Current
Status: Ready for Testing
