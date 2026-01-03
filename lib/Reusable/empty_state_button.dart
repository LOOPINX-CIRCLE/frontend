import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyStateButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const EmptyStateButton({
    super.key,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Set width to 213 for empty state buttons: "Sent Invites", "Send Invites", "View Guest List"
    final String lowerText = text.toLowerCase().trim();
    final bool isEmptyStateButton = lowerText == 'sent invites' || 
                                    lowerText == 'send invites' || 
                                    lowerText == 'view guest list';
    
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: IntrinsicWidth(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: const Color(0xFF9355F0), // --Colors-Primary-200
            ),
            child: Text(
              text,
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
    );
  }
}




