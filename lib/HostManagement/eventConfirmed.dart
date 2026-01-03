import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/Reusable/tab_content_ui.dart';

class EventConfirmed extends StatefulWidget {
  final List<User> users;
  final bool isCheckInMode; // Flag to determine if it's check-in mode

  const EventConfirmed({
    super.key,
    required this.users,
    this.isCheckInMode = false,
  });

  @override
  State<EventConfirmed> createState() => _EventConfirmedState();
}

class _EventConfirmedState extends State<EventConfirmed> {
  // Track check-in state separately for check-in mode
  final Map<String, bool> _checkInState = {};

  // Generate 4-digit secret code based on user ID
  String _generateSecretCode(String userId) {
    // Generate a consistent code based on user ID
    final hash = userId.hashCode.abs();
    return (1000 + (hash % 9000)).toString();
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
          setState(() {
            _checkInState[userId] = !(_checkInState[userId] ?? false); // Toggle checked-in state
          });
        }
        
        bool isUserCheckedIn(String userId) {
          if (!widget.isCheckInMode) {
            // In normal mode, use the user's isProcessed property
            return widget.users.firstWhere((u) => u.id == userId).isProcessed;
          }
          // In check-in mode, use the checkInState map
          return _checkInState[userId] ?? false;
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
                                    backgroundImage: AssetImage(user.imagePath),
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
                                    onTap: () => toggleCheckIn(user.id),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isUserCheckedIn(user.id)
                                            ? const Color(0xFF4A4A4A)
                                            : const Color(0xFF9355F0),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        isUserCheckedIn(user.id) ? 'Checked In' : 'Check-in',
                                        style: GoogleFonts.poppins(
                                          color: isUserCheckedIn(user.id)
                                              ? const Color(0xFFAEAEAE)
                                              : Colors.white,
                                          fontSize: isUserCheckedIn(user.id) ? 16 : 14,
                                          fontWeight: FontWeight.w500,
                                        ),
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
                            backgroundImage: AssetImage(user.imagePath),
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
                          // Show "Checked In" tag if user has been checked in from eventCheckIn
                          if (TabContentUI.isUserCheckedIn(user.id)) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2F2E2E),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Checked In',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF6D6767),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
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
