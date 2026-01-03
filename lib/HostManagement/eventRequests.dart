import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/Reusable/tab_content_ui.dart';

class EventRequests extends StatelessWidget {
  final List<User> users;
  final VoidCallback? onUsersAccepted;

  const EventRequests({
    super.key,
    required this.users,
    this.onUsersAccepted,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    List<User> filteredUsers = List.from(users);
    bool selectAllClicked = false; // Track if "Select All" was clicked
    final onUsersAcceptedCallback = onUsersAccepted; // Capture callback before StatefulBuilder

    return StatefulBuilder(
      builder: (context, setState) {
        void filterUsers(String query) {
          setState(() {
            if (query.isEmpty) {
              filteredUsers = List.from(users);
            } else {
              filteredUsers = users
                  .where((user) => user.name.toLowerCase().contains(query.toLowerCase()))
                  .toList();
            }
          });
        }

        void saveAcceptedUsers() {
          // Save accepted users (users with isProcessed = true) to tab_content_ui
          // Create new User instances to avoid reference issues
          final acceptedUsers = filteredUsers
              .where((u) => u.isProcessed)
              .map((u) => User(
                    id: u.id,
                    name: u.name,
                    imagePath: u.imagePath,
                    isSelected: u.isSelected,
                    isProcessed: u.isProcessed,
                  ))
              .toList();
          
          if (acceptedUsers.isNotEmpty) {
            // Add to confirmed users
            TabContentUI.addConfirmedUsers(acceptedUsers);
            
            // Remove from requests list
            final acceptedIds = acceptedUsers.map((u) => u.id).toList();
            TabContentUI.removeAcceptedUsersFromRequests(acceptedIds);
            
            // Notify parent to refresh count
            if (onUsersAcceptedCallback != null) {
              onUsersAcceptedCallback!();
            }
          }
        }

        void toggleSelectAll() {
          setState(() {
            // Check current state - if all are accepted, deselect all; otherwise select all
            final allCurrentlyAccepted = filteredUsers.every((u) => u.isProcessed);
            final newState = !allCurrentlyAccepted;
            
            if (newState) {
              // Mark that "Select All" was clicked (only when selecting, not deselecting)
              selectAllClicked = true;
            } else {
              // Reset when deselecting
              selectAllClicked = false;
            }
            
            for (var user in filteredUsers) {
              user.isProcessed = newState;
              user.isSelected = newState;
            }
            // Don't save immediately - only change state
          });
        }

        void toggleUserSelection(User user) {
          setState(() {
            user.isProcessed = !user.isProcessed;
            if (user.isProcessed) {
              user.isSelected = true;
            } else {
              // Reset selectAllClicked when deselecting an individual user
              // Only reset if not all are processed (meaning user manually deselected)
              if (!filteredUsers.every((u) => u.isProcessed)) {
                selectAllClicked = false;
              }
            }
            // Don't save immediately - only change state
          });
        }

        final allProcessed = filteredUsers.every((u) => u.isProcessed);
        // Show "Accept all" if "Select All" was clicked (regardless of all processed state)
        final showAcceptAll = selectAllClicked;

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
                'Join Request',
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
              // Section header with Select All
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Exclusive users',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: toggleSelectAll,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF171717),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        allProcessed ? 'Deselect All' : 'Select All',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
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
                          GestureDetector(
                            onTap: () => toggleUserSelection(user),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                              decoration: BoxDecoration(
                                color: user.isProcessed
                                    ? const Color(0xFF2F2E2E)
                                    : const Color(0xFF9355F0),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                user.isProcessed ? 'Accepted' : 'Accept',
                                style: GoogleFonts.poppins(
                                  color: user.isProcessed
                                      ? const Color(0xFF6D6767)
                                      : Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
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
              // Button
              Center(
                child: GestureDetector(
                  onTap: () {
                    if (showAcceptAll) {
                      // "Accept all" button clicked - accept all remaining requests (just change state)
                      setState(() {
                        for (var user in filteredUsers) {
                          user.isProcessed = true;
                          user.isSelected = true;
                        }
                        // Reset selectAllClicked after accepting
                        selectAllClicked = false;
                      });
                      // Don't save here - wait for "Done" button
                    } else {
                      // "Done" button clicked - save accepted users and close
                      // Get all accepted users from the original users list
                      final acceptedUsers = users
                          .where((u) => u.isProcessed)
                          .map((u) => User(
                                id: u.id,
                                name: u.name,
                                imagePath: u.imagePath,
                                isSelected: false,
                                isProcessed: true,
                              ))
                          .toList();
                      
                      if (acceptedUsers.isNotEmpty) {
                        // Add to confirmed users
                        TabContentUI.addConfirmedUsers(acceptedUsers);
                        
                        // Remove from requests list
                        final acceptedIds = acceptedUsers.map((u) => u.id).toList();
                        TabContentUI.removeAcceptedUsersFromRequests(acceptedIds);
                        
                        // Notify parent to refresh count
                        if (onUsersAcceptedCallback != null) {
                          onUsersAcceptedCallback!();
                        }
                      }
                      
                      Navigator.pop(context);
                    }
                  },
                  child: IntrinsicWidth(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9355F0),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (showAcceptAll) ...[
                            const Icon(
                              Icons.people,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            showAcceptAll ? 'Accept all' : 'Done',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
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
