import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/Reusable/tab_content_ui.dart';

class EventInvited extends StatelessWidget {
  final List<User> users;

  const EventInvited({
    super.key,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    List<User> filteredUsers = List.from(users);

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
                'Invited guest',
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
                    'Invited guest list',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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
                  onTap: () {
                    // Users are already saved when they're invited from sentInvitesScreen
                    // Just close the modal
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
      },
    );
  }
}
