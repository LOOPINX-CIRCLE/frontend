import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/Reusable/tab_content_ui.dart';
import 'package:text_code/core/services/event_request_service_host.dart';
import 'package:text_code/core/utils/image_url_helper.dart';

class EventRequests extends StatelessWidget {
  final List<User> users;
  final VoidCallback? onUsersAccepted;
  final int? eventId;

  const EventRequests({
    super.key,
    required this.users,
    this.onUsersAccepted,
    this.eventId,
  });

  @override
  Widget build(BuildContext context) {
    // Use the original UI with the provided users (which may be from API via setRequestUsers)
    return _buildDummyRequestsUI(context);
  }

  // Original dummy UI implementation
  Widget _buildDummyRequestsUI(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    final EventRequestService _eventRequestService = EventRequestService();
    List<User> filteredUsers = List.from(users);
    bool selectAllClicked = false; // Track if "Select All" was clicked
    final onUsersAcceptedCallback = onUsersAccepted; // Capture callback before StatefulBuilder
    bool isAcceptingAll = false; // Track if bulk accept is in progress

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
              onUsersAcceptedCallback();
            }
          }
        }

        void toggleSelectAll() {
          setState(() {
            // Check current state - if all pending are selected, deselect all; otherwise select all pending
            final pendingUsers = filteredUsers.where((u) => !u.isProcessed).toList();
            final allPendingSelected = pendingUsers.isNotEmpty && pendingUsers.every((u) => u.isSelected);
            final newState = !allPendingSelected;
            
            if (newState) {
              // Mark that "Select All" was clicked (only when selecting, not deselecting)
              selectAllClicked = true;
            } else {
              // Reset when deselecting
              selectAllClicked = false;
            }
            
            // Only mark pending users as selected (not already accepted ones)
            for (var user in filteredUsers) {
              if (!user.isProcessed) {
                user.isSelected = newState;
              }
            }
            // Don't save immediately - only change state
          });
        }

        Future<void> toggleUserSelection(User user) async {
          if (kDebugMode) {
            print('===== TOGGLE USER START =====');
            print('User: ${user.name}');
            print('EventId: $eventId');
            print('RequestId: ${user.requestId}');
            print('==============================');
          }
          
          // Show loading state
          setState(() {
            user.isProcessed = !user.isProcessed;
          });

          try {
            // Validate required values
            if (eventId == null) {
              throw Exception('Event ID is missing');
            }

            if (user.requestId == null) {
              throw Exception('Request ID is missing for user: ${user.name}');
            }

            if (kDebugMode) {
              print('[EventRequests] Calling PUT API to accept request');
              print('[EventRequests] Event: $eventId, Request: ${user.requestId}, User: ${user.name}');
            }

            // Call PUT API to accept request
            await _eventRequestService.acceptEventRequest(
              eventId: eventId!,
              requestId: user.requestId!,
            );

            if (kDebugMode) {
              print('Request accepted successfully for user: ${user.name}');
            }

            // Remove from list after successful API call
            setState(() {
              filteredUsers.removeWhere((u) => u.requestId == user.requestId);
              users.removeWhere((u) => u.requestId == user.requestId);
            });

            // Show success message
            try {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${user.name} request accepted!'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            } catch (e) {
              if (kDebugMode) print('SnackBar error: $e');
            }

            // Notify parent
            if (onUsersAcceptedCallback != null) {
              onUsersAcceptedCallback();
            }
          } catch (e) {
            if (kDebugMode) {
              print('Error accepting request: $e');
            }

            // Revert state on error
            setState(() {
              user.isProcessed = !user.isProcessed;
            });

            try {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            } catch (e) {
              if (kDebugMode) print('SnackBar error: $e');
            }
          }
        }

        final allProcessed = filteredUsers.every((u) => u.isProcessed);
        // Show "Accept all" if there are selected pending users
        final selectedPendingUsers = filteredUsers.where((u) => u.isSelected && !u.isProcessed).toList();
        final showAcceptAll = selectedPendingUsers.isNotEmpty;

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
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by name',
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.withOpacity(0.5),
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
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
                        selectedPendingUsers.isNotEmpty ? 'Deselect All' : 'Select All',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
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
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: (user.isProcessed || user.requestStatus == 'accepted') ? null : () async => await toggleUserSelection(user),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 10),
                              decoration: BoxDecoration(
                                color: (user.isProcessed || user.requestStatus == 'accepted')
                                    ? const Color(0xFF2F2E2E)
                                    : (user.isSelected && !user.isProcessed ? const Color(0xFF7B4FC1) : const Color(0xFF9355F0)),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                (user.isProcessed || user.requestStatus == 'accepted') ? 'Accepted' : (user.isSelected ? 'Selected' : 'Accept'),
                                style: GoogleFonts.poppins(
                                  color: (user.isProcessed || user.requestStatus == 'accepted')
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
                  onTap: () async {
                    if (isAcceptingAll) return; // Prevent multiple taps
                    
                    if (kDebugMode) {
                      print('\n🔘 ACCEPT ALL BUTTON TAPPED!');
                    }
                    
                    if (showAcceptAll) {
                      // "Accept all" button clicked - call API to accept all selected pending requests
                      final acceptedUsers = users
                          .where((u) => u.isSelected && !u.isProcessed) // Accept only selected pending ones
                          .toList();
                      
                      if (kDebugMode) {
                        print('\n========== BULK ACCEPT DEBUG ==========');
                        print('📤 Accept All button clicked!');
                        print('   Total users: ${users.length}');
                        print('   Pending users: ${acceptedUsers.length}');
                        print('   Event ID: $eventId');
                      }
                      
                      if (acceptedUsers.isEmpty) {
                        if (kDebugMode) {
                          print('⚠️ No pending users to accept');
                        }
                        return;
                      }
                      
                      // Show loading in button
                      setState(() {
                        isAcceptingAll = true;
                      });

                      try {
                        var successCount = 0;
                        var errorCount = 0;
                        
                        // Call API to accept each request
                        for (var user in acceptedUsers) {
                          if (eventId != null && user.requestId != null) {
                            if (kDebugMode) {
                              print('📝 Accepting: ${user.name} (ID: ${user.requestId})');
                            }

                            try {
                              final response = await _eventRequestService.acceptEventRequest(
                                eventId: eventId!,
                                requestId: user.requestId!,
                              );
                              if (kDebugMode) {
                                print('✅ Accepted: ${user.name}');
                              }
                              successCount++;
                            } catch (e) {
                              if (kDebugMode) {
                                print('❌ Failed: ${user.name} - $e');
                              }
                              errorCount++;
                            }
                          } else {
                            if (kDebugMode) {
                              print('⚠️ Missing data for ${user.name}');
                            }
                            errorCount++;
                          }
                        }

                        if (kDebugMode) {
                          print('✅ Bulk accept completed!');
                          print('   Success: $successCount');
                          print('   Failed: $errorCount');
                          print('========== END DEBUG ==========\n');
                        }

                        // Update UI
                        setState(() {
                          for (var user in acceptedUsers) {
                            user.isProcessed = true;
                            user.isSelected = false;
                          }
                          selectAllClicked = false;
                          isAcceptingAll = false;
                        });

                        // Move to confirmed users
                        final confirmedUsers = acceptedUsers
                            .map((u) => User(
                                  id: u.id,
                                  name: u.name,
                                  imagePath: u.imagePath,
                                  requestStatus: u.requestStatus,
                                  isSelected: false,
                                  isProcessed: true,
                                ))
                            .toList();
                        
                        TabContentUI.addConfirmedUsers(confirmedUsers);
                        final acceptedIds = confirmedUsers.map((u) => u.id).toList();
                        TabContentUI.removeAcceptedUsersFromRequests(acceptedIds);
                        
                        if (onUsersAcceptedCallback != null) {
                          onUsersAcceptedCallback();
                        }

                        // Close modal after success
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (kDebugMode) {
                          print('❌ ERROR during bulk accept: $e');
                          print('========== END DEBUG ==========\n');
                        }

                        setState(() {
                          isAcceptingAll = false;
                        });
                      }
                    } else {
                      // "Done" button clicked
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
                          if (showAcceptAll && !isAcceptingAll) ...[
                            const Icon(
                              Icons.people,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (isAcceptingAll) ...[
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            showAcceptAll ? (isAcceptingAll ? 'Accepting...' : 'Accept all') : 'Done',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.white,
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
