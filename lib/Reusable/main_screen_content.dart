import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable main screen content widget that can be used for both empty and non-empty states
class MainScreenContent extends StatelessWidget {
  final String eventName;
  final String eventPrice;
  final int confirmedUsers;
  final int invitedCount;
  final int requestsCount;
  final int checkInCount;
  final VoidCallback? onBackPressed;
  final VoidCallback? onInvitedTap;
  final VoidCallback? onRequestsTap;
  final VoidCallback? onConfirmedTap;
  final VoidCallback? onCheckedInTap;
  final VoidCallback? onStartCheckInTap; // Separate callback for Start check-in button
  final VoidCallback? onEditRsvpTap;
  final VoidCallback? onEventAnalyticsTap;
  final VoidCallback? onSentInvitesTap;
  final String? selectedRsvpOption; // Track selected RSVP option

  const MainScreenContent({
    super.key,
    required this.eventName,
    required this.eventPrice,
    this.confirmedUsers = 0,
    this.invitedCount = 0,
    this.requestsCount = 0,
    this.checkInCount = 0,
    this.onBackPressed,
    this.onInvitedTap,
    this.onRequestsTap,
    this.onConfirmedTap,
    this.onCheckedInTap,
    this.onStartCheckInTap,
    this.onEditRsvpTap,
    this.onEventAnalyticsTap,
    this.onSentInvitesTap,
    this.selectedRsvpOption,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 56),
        child: Column(
          children: [
            // Top row with back button and event info container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: onBackPressed ?? () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2C2C2E),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/arrowbackbutton.png',
                          width: 24,
                          height: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Event name and price container
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0x1A000000), // rgba(0, 0, 0, 0.10)
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0x802B2B2B), // rgba(43, 43, 43, 0.50)
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              eventName,
                              style: GoogleFonts.bricolageGrotesque(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              eventPrice,
                              style: GoogleFonts.bricolageGrotesque(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Gradient container
            Center(
              child: Container(
                width: 346,
                constraints: const BoxConstraints(
                  minHeight: 247,
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF333333),
                    width: 1,
                  ),
                  gradient: const LinearGradient(
                    begin: Alignment(-0.3, -0.95),
                    end: Alignment(0.3, 0.95),
                    stops: [0.2984, 0.5878, 0.9065],
                    colors: [
                      Color(0x991B1B1B), // rgba(27, 27, 27, 0.60)
                      Color(0x6B3C3C3C), // rgba(60, 60, 60, 0.42)
                      Color(0x991B1B1B), // rgba(27, 27, 27, 0.60)
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    // Capacity row with image and text
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 8,
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/shinypurple.png',
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Capacity $confirmedUsers / 200 Accepted',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFAEAEAE),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 1),
                    // Divider line
                    Container(
                      width: 362,
                      height: 1,
                      color: const Color(0xFF333333),
                    ),
                    const SizedBox(height: 10),
                    // Statistics row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            context,
                            count: invitedCount,
                            label: 'Invited',
                            onTap: onInvitedTap,
                          ),
                          _buildStatItem(
                            context,
                            count: requestsCount,
                            label: 'Requests',
                            onTap: onRequestsTap,
                          ),
                          _buildStatItem(
                            context,
                            count: confirmedUsers,
                            label: 'Confirmed',
                            onTap: onConfirmedTap,
                          ),
                          _buildStatItem(
                            context,
                            count: checkInCount,
                            label: 'Checked-In',
                            onTap: onCheckedInTap,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Divider line
                    Container(
                      width: 362,
                      height: 1,
                      color: const Color(0xFF333333),
                    ),
                    const SizedBox(height: 10),
                    // Start check-in button
                    GestureDetector(
                      onTap: selectedRsvpOption == '48 Hours' ? onStartCheckInTap : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 57, vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: selectedRsvpOption == '48 Hours'
                              ? const Color(0xFF9355F0) // Active when 48 Hours selected
                              : const Color(0xFF2F2E2E), // Inactive
                        ),
                        child: Text(
                          'Start check-in',
                          style: GoogleFonts.poppins(
                            color: selectedRsvpOption == '48 Hours'
                                ? Colors.white // White text when active
                                : const Color(0xFF6D6767), // Gray text when inactive
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18), // Gap from gradient box
            // Two buttons row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context,
                      text: 'Edit RSVP deadline',
                      onTap: onEditRsvpTap,
                    ),
                  ),
                  const SizedBox(width: 15), // Gap between buttons
                  Expanded(
                    child: _buildActionButton(
                      context,
                      text: 'Event Analytics',
                      onTap: onEventAnalyticsTap,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18), // Gap below buttons
            // Sent Invites button with image
           GestureDetector(
  onTap: onSentInvitesTap,
  child: Image.asset(
    'assets/images/SentinvitesHost.png',
    width: 386,
    height: 56,
    fit: BoxFit.contain,
  ),
),

            const SizedBox(height: 20), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String text,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 19),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color.fromRGBO(255, 255, 255, 0.14),
            width: 1,
          ),
          color: const Color(0xFF171717),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required int count,
    required String label,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            count.toString(),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: const Color(0xFFAEAEAE), // --Colors-Secondary-300
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}


