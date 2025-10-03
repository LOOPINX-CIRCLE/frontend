import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FormLabel extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final double topPadding;
  final double bottomPadding;

  const FormLabel(
    this.text, {
    super.key,
    required this.fontSize,
    this.color = Colors.white,
    this.fontWeight = FontWeight.w500,
    this.topPadding = 20,
    this.bottomPadding = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}
