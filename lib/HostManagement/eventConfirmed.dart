import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/Reusable/tab_content_ui.dart';
import 'package:text_code/core/services/invitation_service.dart';
import 'package:text_code/core/utils/image_url_helper.dart';

class EventConfirmed extends StatefulWidget {
  final List<User> users;
  final bool isCheckInMode; // Flag to determine if it's check-in mode
  final int? eventId; // For check-in API calls
  final DateTime? eventDateTime; // For check-in time validation (3 hours before)

  const EventConfirmed({
    super.key,
    required this.users,
    this.isCheckInMode = false,
    this.eventId,
    this.eventDateTime,
  });

  @override
  State<EventConfirmed> createState() => _EventConfirmedState();
}

class _EventConfirmedState extends State<EventConfirmed> {
  // Track check-in state separately for check-in mode
  final Map<String, bool> _checkInState = {};
  final InvitationService _invitationService = InvitationService();
  String? _checkingInUserId; // Track which user is currently being checked in

  // Generate 4-digit secret code based on user ID
  String _generateSecretCode(String userId) {
    // Generate a consistent code based on user ID
    final hash = userId.hashCode.abs();
    return (1000 + (hash % 9000)).toString();
  }

  /// Check if check-in is allowed (3 hours before event or after)
  bool _isCheckInAllowed() {
    if (widget.eventDateTime == null) {
      return false; // No event time specified
    }

    final now = DateTime.now();
    final threeHoursBefore = widget.eventDateTime!.subtract(const Duration(hours: 3));
    
    // Check-in is allowed from 3 hours before event until now (and after event)
    return now.isAfter(threeHoursBefore);
  }

  /// Check user in via API
  Future<void> _checkInUser(String userId) async {
    if (widget.eventId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event ID not available')),
      );
      return;
    }

    try {
      // Set loading state for this user
      setState(() => _checkingInUserId = userId);

      final userIdInt = int.tryParse(userId);
      if (userIdInt == null) {
        throw Exception('Invalid user ID');
      }

      final success = await _invitationService.checkInUser(
        eventId: widget.eventId!,
        userId: userIdInt,
      );

      if (success && mounted) {
        setState(() {
          _checkInState[userId] = true;
          _checkingInUserId = null; // Clear loading state
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ User checked in successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking in user: $e');
      }
      if (mounted) {
        setState(() => _checkingInUserId = null); // Clear loading state
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Load check-in status from API
  Future<void> _loadCheckInStatus() async {
    if (widget.eventId == null || !widget.isCheckInMode) {
      return;
    }

    try {
      final checkInMap = await _invitationService.getCheckInStatus(widget.eventId!);

      if (mounted) {
        setState(() {
          for (var user in widget.users) {
            final userIdInt = int.tryParse(user.id);
            if (userIdInt != null) {
              _checkInState[user.id] = checkInMap[userIdInt] ?? false;
            }
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading check-in status: $e');
      }
      // Error handled silently
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize check-in state to false for all users in check-in mode
    if (widget.isCheckInMode) {
      for (var user in widget.users) {
        if (!_checkInState.containsKey(user.id)) {
          _checkInState[user.id] = false; // Start with false (Check-in button)
        }
      }
      // Load actual check-in status from API
      _loadCheckInStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    List<User> filteredUsers = List.from(widget.users);

    return StatefulBuilder(
      builder: (context, setState) {
        void filterUsers(String query) {
          setState(() {
            if (query.isEmpty) {
              filteredUsers = List.from(widget.users);
            } else {
              filteredUsers = widget.users
                  .where((user) => user.name.toLowerCase().contains(query.toLowerCase()))
                  .toList();
            }
          });
        }

        void toggleCheckIn(String userId) {
          if (!_isCheckInAllowed()) {
            final timeUntilCheckIn = widget.eventDateTime?.difference(DateTime.now()).inHours ?? 0;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Check-in opens 3 hours before event starts (in ~$timeUntilCheckIn hours)'),
              ),
            );
            return;
          }

          // Call API to check in user
          _checkInUser(userId);
        }
        
        bool isUserCheckedIn(String userId) {
          if (!widget.isCheckInMode) {
            // In normal mode, use the user's isProcessed property
            return widget.users.firstWhere((u) => u.id == userId).isProcessed;
          }
          // In check-in mode, use the checkInState map
          return _checkInState[userId] ?? false;
        }

        /// Get check-in button state (enabled/disabled based on time)
        bool isCheckInEnabled() {
          return widget.isCheckInMode && _isCheckInAllowed();
        }

        // If check-in mode, show Guest List UI
        if (widget.isCheckInMode) {
          return Container(
            width: 391,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
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
              children: [
                // Title
                Text(
                  'Guest List',
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
                    controller: searchController,
                    onChanged: filterUsers,
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
                const SizedBox(height: 20),
               Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'List of guest who are joining',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
                
                const SizedBox(height: 20),
                // User list with cards
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final secretCode = _generateSecretCode(user.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Container(
                          width: 343,
                          constraints: const BoxConstraints(
                            minHeight: 116,
                          ),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color.fromRGBO(117, 117, 117, 0.18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.grey[700],
                                    backgroundImage: (user.imagePath.startsWith('assets'))
                                        ? AssetImage(user.imagePath) as ImageProvider
                                        : NetworkImage(imageUrl(user.imagePath)),
                                    onBackgroundImageError: (error, stackTrace) {
                                      if (kDebugMode) {
                                        final resolvedUrl = imageUrl(user.imagePath);
                                        print('❌ [IMAGE_LOAD_FAILED] ${user.name}');
                                        print('   Raw imagePath: ${user.imagePath}');
                                        print('   Resolved URL: $resolvedUrl');
                                        print('   Error: $error');
                                        print('   Error Type: ${error.runtimeType}');
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      user.name,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: (isCheckInEnabled() && _checkingInUserId != user.id) ? () => toggleCheckIn(user.id) : null,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isUserCheckedIn(user.id)
                                            ? const Color(0xFF4A4A4A)
                                            : (isCheckInEnabled() && _checkingInUserId != user.id
                                                ? const Color(0xFF9355F0)
                                                : const Color(0xFF5A5A5A)),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (_checkingInUserId == user.id) ...[
                                            const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                          Text(
                                            _checkingInUserId == user.id
                                                ? 'Checking In...'
                                                : (isUserCheckedIn(user.id) 
                                                    ? 'Checked In' 
                                                    : (isCheckInEnabled() ? 'Check-in' : 'Locked')),
                                            style: GoogleFonts.poppins(
                                              color: isUserCheckedIn(user.id)
                                                  ? const Color(0xFFAEAEAE)
                                                  : (isCheckInEnabled() && _checkingInUserId != user.id ? Colors.white : const Color(0xFF999999)),
                                              fontSize: isUserCheckedIn(user.id) ? 16 : 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Text(
                                    'Secret Code',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    secretCode,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Divider line
                Container(
                  width: double.infinity,
                  height: 1,
                  color: const Color(0xFF333333),
                ),
                const SizedBox(height: 25),
                // Done Button
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: IntrinsicWidth(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9355F0),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          'Done',
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

        // Normal mode - show Confirmed Guests UI
        return Container(
          width: 391,
          height: 670,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
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
            children: [
              // Title
              Text(
                'Confirmed Guests',
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
                  controller: searchController,
                  onChanged: filterUsers,
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
              const SizedBox(height: 20),
              // Section header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Confirmed attendees list',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // User list
              Expanded(
                child: ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey[700],
                            backgroundImage: (user.imagePath.startsWith('assets'))
                                ? AssetImage(user.imagePath) as ImageProvider
                                : NetworkImage(imageUrl(user.imagePath)),
                            onBackgroundImageError: (error, stackTrace) {
                              if (kDebugMode) {
                                final resolvedUrl = imageUrl(user.imagePath);
                                print('❌ [IMAGE_LOAD_FAILED] ${user.name}');
                                print('   Raw imagePath: ${user.imagePath}');
                                print('   Resolved URL: $resolvedUrl');
                                print('   Error: $error');
                                print('   Error Type: ${error.runtimeType}');
                              }
                            },
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              user.name,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Image.asset(
                            'assets/icons/Verified Check.png',
                            width: 28,
                            height: 28,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Divider line
              Container(
                width: double.infinity,
                height: 1,
                color: const Color(0xFF333333),
              ),
              const SizedBox(height: 25),
              // Done Button
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: IntrinsicWidth(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9355F0),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        'Done',
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
      },
    );
  }
}
