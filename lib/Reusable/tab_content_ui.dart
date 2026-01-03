import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/HostManagement/eventInvited.dart';
import 'package:text_code/HostManagement/eventRequests.dart';
import 'package:text_code/HostManagement/eventConfirmed.dart';
import 'package:text_code/HostManagement/eventCheckIn.dart';
import 'package:text_code/HostManagement/confirmedEmpty.dart';
import 'package:text_code/HostManagement/sentInvitesScreen.dart';

class User {
  final String id;
  final String name;
  final String imagePath;
  bool isSelected;
  bool isProcessed; // For invited/accepted/checked-in status

  User({
    required this.id,
    required this.name,
    required this.imagePath,
    this.isSelected = false,
    this.isProcessed = false,
  });
}

class TabContentUI {
  // Hardcoded user lists for each tab
  static List<User> _invitedUsers = [
    User(id: '1', name: 'Clara', imagePath: 'assets/images/avatar.png'),
    User(id: '2', name: 'Muskan', imagePath: 'assets/images/avatar.png'),
    User(id: '3', name: 'Anshi', imagePath: 'assets/images/avatar.png'),
    User(id: '4', name: 'Sanjana mall', imagePath: 'assets/images/avatar.png'),
    User(id: '5', name: 'Anushka', imagePath: 'assets/images/avatar.png'),
    User(id: '6', name: 'Priya', imagePath: 'assets/images/avatar.png'),
    User(id: '7', name: 'Riya', imagePath: 'assets/images/avatar.png'),
    User(id: '8', name: 'Sneha', imagePath: 'assets/images/avatar.png'),
    User(id: '9', name: 'Kavya', imagePath: 'assets/images/avatar.png'),
    User(id: '10', name: 'Meera', imagePath: 'assets/images/avatar.png'),
  ];

  // Dynamic list to store pending request users
  static List<User> _requestUsers = [
    User(id: '1', name: 'Clara', imagePath: 'assets/images/avatar.png'),
    User(id: '2', name: 'Muskan', imagePath: 'assets/images/avatar.png'),
    User(id: '3', name: 'Anshi', imagePath: 'assets/images/avatar.png'),
    User(id: '4', name: 'Senan', imagePath: 'assets/images/avatar.png'),
    User(id: '5', name: 'Anushka', imagePath: 'assets/images/avatar.png'),
    User(id: '6', name: 'Priya', imagePath: 'assets/images/avatar.png'),
    User(id: '7', name: 'Riya', imagePath: 'assets/images/avatar.png'),
    User(id: '8', name: 'vaishnavi', imagePath: 'assets/images/avatar.png'),
    User(id: '9', name: 'kamran', imagePath: 'assets/images/avatar.png'),
    User(id: '10', name: 'Isha', imagePath: 'assets/images/avatar.png'),
     User(id: '11', name: 'Priyanka', imagePath: 'assets/images/avatar.png'),
    User(id: '12', name: 'Raj kapoor ', imagePath: 'assets/images/avatar.png'),
    User(id: '13', name: 'Anvesha', imagePath: 'assets/images/avatar.png'),
    User(id: '13', name: 'Kavya upadhaya ', imagePath: 'assets/images/avatar.png'),
    User(id: '14', name: 'Meera Malhotra', imagePath: 'assets/images/avatar.png'),
    User(id: '15', name: 'Amitabh Bachchan', imagePath: 'assets/images/avatar.png'),
  ];
  
  // Method to get request users count
  static int getRequestUsersCount() {
    return _requestUsers.length;
  }
  
  // Method to get request users
  static List<User> getRequestUsers() {
    return List.from(_requestUsers);
  }
  
  // Method to remove accepted users from requests list
  static void removeAcceptedUsersFromRequests(List<String> acceptedUserIds) {
    _requestUsers.removeWhere((user) => acceptedUserIds.contains(user.id));
  }

  // Dynamic list to store accepted users from eventInvited (for invited flow)
  static List<User> _invitedAcceptedUsers = [];
  
  // Dynamic list to store accepted users from eventRequests (for confirmed flow)
  static List<User> _confirmedUsers = [];
  
  // Set to track which users have been checked in (separate from confirmation status)
  static Set<String> _checkedInUserIds = {};
  
  // Dynamic list to store invited users from sentInvitesScreen (cumulative)
  static List<User> _invitedUsersList = [];
  
  // Method to add invited users from sentInvitesScreen (appends, doesn't replace)
  static void addInvitedUsers(List<User> users) {
    // Get existing invited user IDs to avoid duplicates
    final existingIds = _invitedUsersList.map((u) => u.id).toSet();
    
    // Add only new users (not already invited)
    for (var user in users) {
      if (!existingIds.contains(user.id)) {
        _invitedUsersList.add(User(
          id: user.id,
          name: user.name,
          imagePath: user.imagePath,
          isSelected: false,
          isProcessed: true,
        ));
      }
    }
  }
  
  // Method to check if a user is already invited
  static bool isUserInvited(String userId) {
    return _invitedUsersList.any((u) => u.id == userId);
  }
  
  // Method to get invited users count
  static int getInvitedUsersCount() {
    return _invitedUsersList.length;
  }
  
  // Method to get invited users
  static List<User> getInvitedUsers() {
    return List.from(_invitedUsersList);
  }
  
  // Method to add accepted users from eventInvited
  static void addInvitedAcceptedUsers(List<User> users) {
    _invitedAcceptedUsers = List.from(users);
  }
  
  // Method to add accepted users from eventRequests (appends, doesn't replace)
  static void addConfirmedUsers(List<User> users) {
    // Get existing confirmed user IDs to avoid duplicates
    final existingIds = _confirmedUsers.map((u) => u.id).toSet();
    
    // Add only new users (not already confirmed)
    for (var user in users) {
      if (!existingIds.contains(user.id)) {
        _confirmedUsers.add(User(
          id: user.id,
          name: user.name,
          imagePath: user.imagePath,
          isSelected: false,
          isProcessed: true,
        ));
      }
    }
  }
  
  // Method to get confirmed users count
  static int getConfirmedUsersCount() {
    return _confirmedUsers.length;
  }
  
  // Method to get confirmed users (from requests)
  static List<User> getConfirmedUsers() {
    // Sync check-in status from _checkedInUserIds to the user objects
    final users = <User>[];
    for (var user in _confirmedUsers) {
      // Create a copy with updated check-in status
      final userCopy = User(
        id: user.id,
        name: user.name,
        imagePath: user.imagePath,
        isSelected: user.isSelected,
        isProcessed: _checkedInUserIds.contains(user.id),
      );
      users.add(userCopy);
    }
    return users;
  }
  
  // Method to check if a user has been checked in
  static bool isUserCheckedIn(String userId) {
    // Only return true if user is in the checked-in set (checked in from eventCheckIn.dart)
    return _checkedInUserIds.contains(userId);
  }
  
  // Method to update check-in status for a confirmed user
  static void updateUserCheckInStatus(String userId, bool isCheckedIn) {
    if (isCheckedIn) {
      // Add to checked-in set
      _checkedInUserIds.add(userId);
    } else {
      // Remove from checked-in set
      _checkedInUserIds.remove(userId);
    }
    // Also update the user's isProcessed status in the list for UI consistency
    for (var user in _confirmedUsers) {
      if (user.id == userId) {
        user.isProcessed = isCheckedIn;
        break;
      }
    }
  }

  static List<User> _checkInUsers = [
    User(id: '1', name: 'Muskan', imagePath: 'assets/images/avatar.png', isProcessed: true, isSelected: false),
    User(id: '2', name: 'Anshi', imagePath: 'assets/images/avatar.png', isProcessed: false, isSelected: false),
    User(id: '3', name: 'Sanjana', imagePath: 'assets/images/avatar.png', isProcessed: false, isSelected: false),
  ];

  /// Returns UI for Invited tab based on count
  static Widget getInvitedUI(int count, BuildContext context, {
    String? eventName,
    String? eventPrice,
    int? confirmedUsers,
    VoidCallback? onUsersInvited,
  }) {
    // Use dynamic count from stored invited users
    final dynamicCount = getInvitedUsersCount();
    
    // If dynamic count is 0, always show empty state (no users invited yet)
    if (dynamicCount == 0) {
      return _buildEmptyState(
        context,
        title: 'Invited Guest',
        iconPath: 'assets/icons/Invite empty state.png',
        mainText: 'Start building your guest list',
        subText: 'Use Send invites to handpick your crew.',
        buttonText: 'Sent Invites',
        onButtonTap: () {
          // Get root navigator context before closing
          final rootContext = Navigator.of(context, rootNavigator: true).context;
          // Close current modal
          Navigator.pop(context);
          // Open SentInvitesScreen
          Future.delayed(const Duration(milliseconds: 300), () {
            if (rootContext.mounted) {
              showModalBottomSheet(
                context: rootContext,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => SentInvitesScreen(
                  eventName: eventName ?? 'Event',
                  eventPrice: eventPrice ?? '₹0',
                  confirmedUsers: confirmedUsers ?? 0,
                  onUsersInvited: onUsersInvited,
                ),
              );
            }
          });
        },
      );
     } 
    else {
      // If dynamic count > 0, show the invited users
      final usersToShow = getInvitedUsers();
      return EventInvited(users: usersToShow);
    }
  }

  /// Returns UI for Requests tab based on count
  static Widget getRequestsUI(int count, BuildContext context, {
    String? eventName,
    String? eventPrice,
    int? confirmedUsers,
  }) {
    // Use dynamic count from pending request users
    final dynamicCount = getRequestUsersCount();
    
    // If dynamic count is 0, always show empty state (no pending requests)
    if (dynamicCount == 0) {
      return _buildEmptyState(
        context,
        title: 'Join Requests',
        iconPath: 'assets/icons/No request empty state.png',
        mainText: 'No requests yet',
        subText: 'Requests from guests will appear here once they start requesting to join your event.',
        buttonText: 'Send Invites',
      );
    } else {
      // If dynamic count > 0, show the pending request users
      final requestUsersList = getRequestUsers();
      return EventRequests(
        users: requestUsersList,
        onUsersAccepted: () {
          // This callback can be used to refresh the UI if needed
        },
      );
    }
  }

  /// Returns UI for Confirmed tab based on count
  static Widget getConfirmedUI(int count, BuildContext context, {
    String? eventName,
    String? eventPrice,
    int? confirmedUsers,
  }) {
    // Use dynamic count from stored confirmed users
    final dynamicCount = getConfirmedUsersCount();
    
    // If dynamic count is 0, always show empty state (no users confirmed yet)
    if (dynamicCount == 0) {
      return _buildEmptyState(
        context,
        title: 'Confirmed Guests',
        iconPath: 'assets/icons/Confirm guest empty state icon.png',
        mainText: 'No confirmed guests yet',
        subText: 'Guests who accept your invitation will appear here.',
        buttonText: 'Send Invites',
      );
    } else {
      // If dynamic count > 0, show the confirmed users
      final confirmedUsersList = getConfirmedUsers();
      return EventConfirmed(users: confirmedUsersList);
    }
  }

  /// Returns UI for Checked-In tab based on count
  static Widget getCheckInUI(int count, BuildContext context, {
    String? eventName,
    String? eventPrice,
    int? confirmedUsers,
  }) {
    if (count == 0) {
      return _buildEmptyState(
        context,
        title: 'Checked-In Guests',
        iconPath: 'assets/icons/Check in empty state.png',
        mainText: ' Check-in starts 3hr \nbefore the event',
        subText: 'Guests who check in at your event will appear here.',
        buttonText: 'View Guest List ',
        onButtonTap: () {
          // Check confirmed users count
          final confirmedCount = getConfirmedUsersCount();
          Navigator.pop(context);
          
          if (confirmedCount == 0) {
            // Show confirmed empty state
            ConfirmedEmpty.show(context, confirmedCount: confirmedCount);
          } else {
            // Show event confirmed in normal mode (not check-in mode)
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => EventConfirmed(
                users: getConfirmedUsers(),
                isCheckInMode: false, // Normal mode, not check-in mode
              ),
            );
          }
        },
      );
    } else {
      // Use confirmed users for check-in, not the separate _checkInUsers list
      return EventCheckIn(users: getConfirmedUsers());
    }
  }

  /// Builds empty state UI
  static Widget _buildEmptyState(
    BuildContext context, {
    required String title,
    required String iconPath,
    required String mainText,
    required String subText,
    required String buttonText,
    VoidCallback? onButtonTap,
  }) {
    return Container(
      width: 391,
      height: 690,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.14),
            width: 1,
          ),
        ),
        gradient: const LinearGradient(
          begin: Alignment(-0.5, -0.9),
          end: Alignment(0.5, 0.9),
          stops: [0.2745, 0.8516],
          colors: [
            Color(0xFF1B1B1B),
            Color(0xFF1B1B1B),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          // Search bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF171717),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: TextField(
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Search by name',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey.withOpacity(0.5),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(height: 100),
          // Icon
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            child: Image.asset(
              iconPath,
              width: 54,
              height: 54,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 5),
          // Main text
          Text(
            mainText,
            textAlign: TextAlign.center,
            style: GoogleFonts.bricolageGrotesque(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          // Sub text
          Text(
            subText,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 16 / 14,
            ),
          ),
          const Spacer(),
          // Divider line
          Container(
            width: double.infinity,
            height: 1,
            color: const Color(0xFF333333),
          ),
          const SizedBox(height: 25),
          // Button
          Center(
            child: GestureDetector(
              onTap: onButtonTap ?? () => Navigator.pop(context),
              child: Container(
                width: buttonText.toLowerCase().trim() == 'view guest list' ? 236 : null,
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF9355F0),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: buttonText.toLowerCase().trim() == 'view guest list'
                    ? Center(
                        child: Text(
                          buttonText,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : IntrinsicWidth(
                        child: Text(
                          buttonText,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // UI methods moved to separate files:
  // - EventInvited (eventInvited.dart) - contains invited list UI
  // - EventRequests (eventRequests.dart) - contains requests list UI
  // - EventConfirmed (eventConfirmed.dart) - contains confirmed list UI
  // - EventCheckIn (eventCheckIn.dart) - contains check-in list UI
}
