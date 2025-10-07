import 'package:flutter/material.dart';
import 'package:text_code/Reusable/customer_appbar.dart';
import 'package:text_code/Reusable/text_Bricolage%20Grotesque_reusable.dart';
import 'package:text_code/Reusable/text_reusable.dart';

class PaymentStatusScreen extends StatelessWidget {
  final String appBarTitle;
  final String imagePath;
  final String message;
  final String primaryButtonText;
  final VoidCallback onPrimaryPressed;
  final String secondaryButtonText;
  final VoidCallback? onSecondaryPressed;

  const PaymentStatusScreen({
    super.key,
    required this.appBarTitle,
    required this.imagePath,
    required this.message,
    required this.primaryButtonText,
    required this.onPrimaryPressed,
    required this.secondaryButtonText,
    this.onSecondaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(
        leadingIcon: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Image.asset("assets/icons/Back Icon.png", height: 60),
        ),
        titleWidget: FormLabel(appBarTitle, fontSize: 22),
      ),
      body: Column(
        children: [
          const SizedBox(height: 100),
          Image.asset(imagePath, height: 200, width: 200),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: TextBricolage(
                FontWeight.w500,
                message,
                26,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: onPrimaryPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.grey, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              child: TextBricolage(FontWeight.w500, primaryButtonText, 18),
            ),
          ),
          TextButton(
            onPressed: onSecondaryPressed,
            child: FormLabel(
              secondaryButtonText,
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
