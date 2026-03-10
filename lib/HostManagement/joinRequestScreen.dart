import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'package:text_code/core/services/event_request_service.dart';
import 'package:text_code/core/models/requester_profile.dart';
import 'package:text_code/core/network/api_exception.dart';
import 'package:text_code/Reusable/tab_content_ui.dart';
import 'package:text_code/core/utils/image_url_helper.dart';

class RequestUser {
  final int requestId;
  final int eventId;
  final int userId;
  final String name;
  final String imagePath;
  final String status; // 'pending' or 'accepted'
  bool isSelected;
  bool isProcessed;

  RequestUser({
    required this.requestId,
    required this.eventId,
    required this.userId,
    required this.name,
    required this.imagePath,
    this.status = 'pending',
    this.isSelected = false,
    this.isProcessed = false,
  });
}

class JoinRequestScreen extends StatefulWidget {
  final int eventId;
  final String? eventName;
  final String? eventPrice;
  final int? confirmedUsers;

  const JoinRequestScreen({
    super.key,
    required this.eventId,
    this.eventName,
    this.eventPrice,
    this.confirmedUsers,
  });

  @override
  State<JoinRequestScreen> createState() => _JoinRequestScreenState();
}

class _JoinRequestScreenState extends State<JoinRequestScreen> {
  final TextEditingController _searchController = TextEditingController();
  final EventRequestService _eventRequestService = EventRequestService();
  
  List<RequestUser> _users = [];
  List<RequestUser> _filteredUsers = [];
  bool _selectAllClicked = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterUsers);
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      if (kDebugMode) {
        print('Fetching requests for event: ${widget.eventId}');
      }

      // Get all requests with their status from first API
      print('[FORCE PRINT] Calling getEventRequestsWithStatus...');
      final requestsWithStatus = await _eventRequestService.getEventRequestsWithStatus(widget.eventId);
      print('[FORCE PRINT] getEventRequestsWithStatus returned ${requestsWithStatus.length} requests');
      print('[FORCE PRINT] Status map: $requestsWithStatus');
      
      if (kDebugMode) {
        print('Found ${requestsWithStatus.length} requests with statuses');
      }

      // Fetch full details for each request
      List<RequestUser> users = [];
      for (int requestId in requestsWithStatus.keys) {
        try {
          // Get the requester's profile for this request
          final profile = await _eventRequestService.getRequesterProfile(
            eventId: widget.eventId,
            requestId: requestId,
          );

          // Get the status from the requests list API
          final requestStatus = requestsWithStatus[requestId] ?? 'pending';

          if (kDebugMode) {
            print('[JoinRequestScreen] Loaded user: ${profile.name}, Status from API: "$requestStatus"');
          }

          // Use first profile picture or default avatar
          final rawImagePath = profile.profilePictures.isNotEmpty
              ? profile.profilePictures[0]
              : 'assets/images/avatar.png';
          // Resolve relative URLs to full URLs using imageUrl helper
          final imagePath = (rawImagePath.startsWith('/') || rawImagePath.startsWith('http'))
              ? imageUrl(rawImagePath)
              : rawImagePath; // Keep asset paths as-is

          // Check if request is already accepted - use trim and toLowerCase for safety
          final statusTrimmed = requestStatus.trim().toLowerCase();
          final isAccepted = statusTrimmed == 'accepted';
          
          if (kDebugMode) {
            print('[JoinRequestScreen] ${profile.name}:');
            print('  - Status from API: "$requestStatus"');
            print('  - Status == "accepted": $isAccepted');
            print('  - Will show button: ${isAccepted ? "ACCEPTED (Gray, Disabled)" : "ACCEPT (Purple, Enabled)"}');
          }

          // Create RequestUser from profile data
          final user = RequestUser(
            requestId: requestId,
            eventId: widget.eventId,
            userId: profile.userId,
            name: profile.name,
            imagePath: imagePath,
            status: requestStatus,
            isProcessed: isAccepted, // Set to true if already accepted
          );

          if (kDebugMode) {
            print('  ✓ Created RequestUser: ${user.name}');
            print('    - user.isProcessed = ${user.isProcessed}');
            print('    - user.status = "${user.status}"');
          }

          users.add(user);
        } catch (e) {
          if (kDebugMode) {
            print('Error fetching profile for request $requestId: $e');
          }
          // Continue with next request even if one fails
        }
      }

      if (kDebugMode) {
        print('\n========== BEFORE setState ==========');
        print('Total users collected: ${users.length}');
        for (var u in users) {
          print('  User: ${u.name}');
          print('    - requestId: ${u.requestId}');
          print('    - status: "${u.status}"');
          print('    - isProcessed: ${u.isProcessed}');
          print('    - will render button as: ${u.isProcessed ? "ACCEPTED" : "ACCEPT"}');
        }
        print('==============================\n');
      }

      setState(() {
        _users = users;
        _filteredUsers = List.from(users);
        _isLoading = false;
        
        if (kDebugMode) {
          print('\\n========== AFTER setState ==========');
          for (var u in _filteredUsers) {
            print('  ${u.name}: isProcessed=${u.isProcessed}');
          }
          print('===================================\\n');
        }
      });

      if (kDebugMode) {
        print('Successfully loaded ${users.length} requests');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching requests: $e');
      }
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load requests: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _eventRequestService.dispose();
    super.dispose();
  }

  void _filterUsers() {
    setState(() {
      final query = _searchController.text;
      if (query.isEmpty) {
        _filteredUsers = List.from(_users);
      } else {
        _filteredUsers = _users
            .where((user) => user.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      final allCurrentlyAccepted = _filteredUsers.every((u) => u.isProcessed);
      final newState = !allCurrentlyAccepted;
      
      if (newState) {
        _selectAllClicked = true;
      } else {
        _selectAllClicked = false;
      }
      
      for (var user in _filteredUsers) {
        user.isProcessed = newState;
        user.isSelected = newState;
      }
    });
  }

  void _toggleUserSelection(RequestUser user) {
    setState(() {
      user.isProcessed = !user.isProcessed;
      if (user.isProcessed) {
        user.isSelected = true;
      } else {
        if (!_filteredUsers.every((u) => u.isProcessed)) {
          _selectAllClicked = false;
        }
      }
    });
  }

  Future<void> _acceptRequest(RequestUser user) async {
    if (kDebugMode) {
      print('===== JOIN REQUEST ACCEPT START =====');
      print('User: ${user.name}');
      print('EventId: ${widget.eventId}');
      print('RequestId: ${user.requestId}');
      print('=======================================');
    }
    
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );

      if (kDebugMode) {
        print('[JoinRequestScreen] Calling PUT API to accept request');
        print('[JoinRequestScreen] Event: ${widget.eventId}, Request: ${user.requestId}, User: ${user.name}');
      }

      await _eventRequestService.acceptEventRequest(
        eventId: widget.eventId,
        requestId: user.requestId,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog
      
      // Close the user details dialog if open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Remove the accepted request from the list
      setState(() {
        _users.removeWhere((u) => u.requestId == user.requestId);
        _filteredUsers.removeWhere((u) => u.requestId == user.requestId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request accepted successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.message}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _showUserDetailsDialog(RequestUser user) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );

      final profile = await _eventRequestService.getRequesterProfile(
        eventId: widget.eventId,
        requestId: user.requestId,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      // Show details dialog with accept/decline
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: const Color(0xFF1C1C1C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profile Picture
                if (user.imagePath.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl(user.imagePath),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey[800],
                          child: const Center(
                            child: Icon(Icons.person, color: Colors.grey, size: 80),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.person, color: Colors.grey, size: 80),
                    ),
                  ),
                const SizedBox(height: 16),

                // User Info
                Text(
                  user.name,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                if (profile.phoneNumber != null)
                  Text(
                    profile.phoneNumber!,
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),

                if (profile.bio != null && profile.bio!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      profile.bio!,
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 16),
                const SizedBox(height: 20),

                // Accept/Decline Buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: user.isProcessed 
                            ? null 
                            : () {
                                Navigator.pop(context);
                                _acceptRequest(user);
                              },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: user.isProcessed
                                ? const Color(0xFF2F2E2E)
                                : const Color(0xFF9355F0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            user.isProcessed ? 'Accepted' : 'Accept',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: user.isProcessed
                                  ? const Color(0xFF6D6767)
                                  : Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Cancel',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_errorMessage != null) {
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage ?? 'Error loading requests',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _fetchRequests,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9355F0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Retry',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final allProcessed = _filteredUsers.every((u) => u.isProcessed);
    final showAcceptAll = _selectAllClicked;

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
              controller: _searchController,
              onChanged: (_) => _filterUsers(),
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
                'Requests (${_filteredUsers.length})',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: _toggleSelectAll,
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
            child: _filteredUsers.isEmpty
                ? Center(
                    child: Text(
                      'No requests found',
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      
                      if (kDebugMode && index == 0) {
                        print('\n[ListView Rendering]');
                        print('Total items: ${_filteredUsers.length}');
                      }
                      
                      if (kDebugMode) {
                        print('Item $index: user=${user.name}, isProcessed=${user.isProcessed}, status=${user.status}');
                      }
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          onTap: () => _showUserDetailsDialog(user),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.grey[700],
                                backgroundImage: (user.imagePath.startsWith('assets'))
                                    ? AssetImage(user.imagePath) as ImageProvider
                                    : NetworkImage(imageUrl(user.imagePath)),
                                onBackgroundImageError: (error, stackTrace) {},
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => user.isProcessed ? null : _acceptRequest(user),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 10),
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
                Navigator.pop(context);
              },
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
}
