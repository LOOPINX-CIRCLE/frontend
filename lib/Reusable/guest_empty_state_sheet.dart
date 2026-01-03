import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/Reusable/empty_state_button.dart';

class GuestEmptyStateSheet extends StatelessWidget {
  final String title;
  final String iconPath;
  final String mainText;
  final String subText;
  final String buttonText;
  final VoidCallback? onButtonTap;

  const GuestEmptyStateSheet({
    super.key,
    required this.title,
    required this.iconPath,
    required this.mainText,
    required this.subText,
    required this.buttonText,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 391,
      height: 690,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
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
          const SizedBox(height: 100),
          // Icon
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            child: Image.asset(
              iconPath,
              width: 54,
              height: 54,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 5),
          // Main text
          Text(
            mainText,
            textAlign: TextAlign.center,
            style: GoogleFonts.bricolageGrotesque(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              height: 1.0, // Remove default line height spacing
            ),
          ),
          const SizedBox(height: 12),
          // Sub text
          Text(
            subText,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 16 / 14, // line-height: 16px / font-size: 14px
            ),
          ),
          const Spacer(),
          // Divider line
          Container(
            width: double.infinity,
            height: 1,
            color: const Color(0xFF333333),
          ),
          const SizedBox(height: 25),
          // Button
          EmptyStateButton(
            text: buttonText,
            onTap: onButtonTap ?? () {},
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  static void show(
    BuildContext context, {
    required String title,
    required String iconPath,
    required String mainText,
    required String subText,
    required String buttonText,
    VoidCallback? onButtonTap,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GuestEmptyStateSheet(
        title: title,
        iconPath: iconPath,
        mainText: mainText,
        subText: subText,
        buttonText: buttonText,
        onButtonTap: onButtonTap,
      ),
    );
  }
}

