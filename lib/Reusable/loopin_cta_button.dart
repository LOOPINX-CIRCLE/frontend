import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum LoopinButtonVariant { primary }

class LoopinCtaButton extends StatelessWidget {
  const LoopinCtaButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = LoopinButtonVariant.primary,
    this.width = 250,
    this.height = 56,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderWidth,
    this.padding,
  });

  final String label;
  final VoidCallback? onPressed;
  final LoopinButtonVariant variant;
  final width;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? borderWidth;
  final EdgeInsetsGeometry? padding;

  Color get _buttonColor => backgroundColor ?? const Color(0xFF9355F0);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _buttonColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor ?? Colors.white.withOpacity(0.3),
            width: borderWidth ?? 0.5,
          ),
        
          
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onPressed,
            child: Padding(
              padding:
                  padding ?? const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'ClashDisplay',
                        color: textColor ?? Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500, // Medium
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



