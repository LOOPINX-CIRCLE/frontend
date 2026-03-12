import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/HostManagement/bankDetails/allbanks.dart';

class EventAnalyticsScreen {
  static void show(
    BuildContext context, {
    required int confirmedGuests,
    required String eventPrice,
    required bool isCheckInActive, // Whether start check-in is active
    required String eventStatus, // Event status to control bank account button
    String? payoutStatus, // Payout status for showing payout state
    VoidCallback? onRefreshCounts, // Callback to refresh counts in parent
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EventAnalyticsContent(
        confirmedGuests: confirmedGuests,
        eventPrice: eventPrice,
        isCheckInActive: isCheckInActive,
        eventStatus: eventStatus,
        payoutStatus: payoutStatus,
        onRefreshCounts: onRefreshCounts,
      ),
    );
  }
}

class _EventAnalyticsContent extends StatelessWidget {
  final int confirmedGuests;
  final String eventPrice;
  final bool isCheckInActive;
  final String eventStatus;
  final String? payoutStatus;
  final VoidCallback? onRefreshCounts;

  const _EventAnalyticsContent({
    required this.confirmedGuests,
    required this.eventPrice,
    required this.isCheckInActive,
    required this.eventStatus,
    this.payoutStatus,
    this.onRefreshCounts,
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
          // Add bank account button - show active if completed AND paid event, locked if not
          GestureDetector(
            onTap: (eventStatus.toLowerCase() == 'completed' && ticketPrice > 0 && (payoutStatus == null || payoutStatus!.isEmpty))
                ? () async {
                    final selectedBank = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllBanksScreen(),
                      ),
                    );
                    if (selectedBank != null) {
                      // Handle selected bank
                      onRefreshCounts?.call();
                    }
                  }
                : null, // No action if not completed or free event or payout exists
            child: _buildPayoutButton(_parsePrice(eventPrice)),
          ),
        ],
      ),
    );
  }

  /// Build the appropriate payout button based on status
  Widget _buildPayoutButton(double ticketPrice) {
    // Check if payout exists
    if (payoutStatus != null && payoutStatus!.isNotEmpty) {
      return _buildPayoutStatusButton();
    }

    // Check if button should be unlocked
    final isUnlocked = eventStatus.toLowerCase() == 'completed' && ticketPrice > 0;
    
    if (isUnlocked) {
      return Image.asset(
        'assets/images/button (3).png', // Active button
        height: 52,
      );
    } else {
      return Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: const Color(0xFF3A3A3A),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock,
              color: Color(0xFF999999),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Add bank account',
              style: GoogleFonts.poppins(
                color: const Color(0xFF999999),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
  }

  /// Build payout status button
  Widget _buildPayoutStatusButton() {
    final status = payoutStatus?.toLowerCase() ?? '';
    
    late String buttonText;
    late Color backgroundColor;
    late Color textColor;
    late IconData? iconData;

    switch (status) {
      case 'pending':
      case 'approved':
      case 'processing':
        buttonText = 'Payout Processing';
        backgroundColor = const Color(0xFFF59E0B); // Amber for processing
        textColor = Colors.white;
        iconData = Icons.hourglass_bottom;
        break;
      case 'completed':
        buttonText = 'Payout Successful ✓';
        backgroundColor = const Color(0xFF10B981); // Green for success
        textColor = Colors.white;
        iconData = Icons.check_circle;
        break;
      case 'rejected':
      case 'cancelled':
        buttonText = status == 'rejected' ? 'Rejected ✗' : 'Cancelled';
        backgroundColor = const Color(0xFFEF4444); // Red for error
        textColor = Colors.white;
        iconData = Icons.cancel;
        break;
      default:
        buttonText = 'Payout Status';
        backgroundColor = const Color(0xFF6366F1); // Indigo default
        textColor = Colors.white;
        iconData = null;
    }

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: backgroundColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconData != null) ...[
            Icon(
              iconData,
              color: textColor,
              size: 20,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            buttonText,
            style: GoogleFonts.poppins(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
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

