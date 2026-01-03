import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/HostManagement/bankDetails/allbanks.dart';

class EventAnalyticsScreen {
  static void show(
    BuildContext context, {
    required int confirmedGuests,
    required String eventPrice,
    required bool isCheckInActive, // Whether start check-in is active
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EventAnalyticsContent(
        confirmedGuests: confirmedGuests,
        eventPrice: eventPrice,
        isCheckInActive: isCheckInActive,
      ),
    );
  }
}

class _EventAnalyticsContent extends StatelessWidget {
  final int confirmedGuests;
  final String eventPrice;
  final bool isCheckInActive;

  const _EventAnalyticsContent({
    required this.confirmedGuests,
    required this.eventPrice,
    required this.isCheckInActive,
  });

  // Parse price string (e.g., "₹499" -> 499.0)
  double _parsePrice(String price) {
    final cleaned = price.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final ticketPrice = _parsePrice(eventPrice);
    final platformFeePerTicket = ticketPrice * 0.10; // 10% platform fee
    final totalCollected = ticketPrice * confirmedGuests;
    final totalPlatformFee = platformFeePerTicket * confirmedGuests;
    final yourEarning = totalCollected - totalPlatformFee;

    return Container(
      height: 420,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.14),
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Center(
            child: Text(
              'Event Break down',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Sub text
          
          const SizedBox(height: 20),
          // Analytics data
          _buildAnalyticsRow('Total guest', confirmedGuests.toString()),
          const SizedBox(height: 12),
          _buildAnalyticsRow('Per ticket price', eventPrice),
          const SizedBox(height: 12),
          _buildAnalyticsRow(
            'Platform fee',
            '₹${platformFeePerTicket.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 12),
          _buildAnalyticsRow(
            'Total collected',
            '₹${totalCollected.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 12),
          _buildAnalyticsRow(
            'Platform fee',
            '₹${totalPlatformFee.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 40),
          // Your earning
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your earning',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '₹${yourEarning.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 33),
          // Add bank account button
          GestureDetector(
            onTap: isCheckInActive
                ? () async {
                    final selectedBank = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllBanksScreen(),
                      ),
                    );
                    if (selectedBank != null) {
                      // Handle selected bank
                      // You can add callback or state management here
                    }
                  }
                : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 57, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: isCheckInActive
                    ? const Color(0xFF9355F0) // Active
                    : const Color(0xFF2F2E2E), // Inactive
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isCheckInActive) ...[
                    Image.asset(
                      'assets/icons/Lock.png',
                      width: 20,
                      height: 20,
                      color: const Color(0xFF6D6767),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    'Add bank account',
                    style: GoogleFonts.poppins(
                      color: isCheckInActive
                          ? Colors.white // White text when active
                          : const Color(0xFF6D6767), // Gray text when inactive
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: const Color(0xFFA4A4A4),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

