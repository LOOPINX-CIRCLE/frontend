// ignore_for_file: must_be_immutable, file_names

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextBricolage extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight? fontWeight;
  final TextAlign? textAlign; // 👈 added

  TextBricolage(
    this.fontWeight,
    this.text,
    this.fontSize, {
    this.textAlign, // 👈 default start
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign, // 👈 use here
      style: GoogleFonts.bricolageGrotesque(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }
}
