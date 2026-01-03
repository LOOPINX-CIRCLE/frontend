import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Privacy Policy",
          style: GoogleFonts.bricolageGrotesque(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "By using the Loopinx Circle platform, you agree to the collection and use of your information in accordance with this Policy.",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "We only collect data that is necessary to provide our core service and ensure platform security, adhering to Indian data protection laws.",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.grey,
                  fontSize: 14,
                   fontWeight: FontWeight.w500,
                ),
                ),
              

              const SizedBox(height: 24),
              Text(
                "1. The Data We Collect",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "We collect information that you provide directly to us, including your name, email address, profile pictures, and event preferences.",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Identity & Contact: Name, email, phone number (for account creation, vetting, and communication).Financial & Transaction: Payment details (processed securely by third parties like Stripe/Razorpay) and transaction history (for ticketing and host payments).Usage Data: Event history and platform activity (for service improvement and feed personalization).",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "We use the information we collect to provide, maintain, and improve our services, process transactions, send notifications, and personalize your experience.",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "2. Why We Use Your Data",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "We process your data for two main legal reasons",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Contractual Necessity: To provide the Loopinx Circle service you signed up for (e.g., selling/buying tickets, managing your Host account).Legal Compliance: To comply with Indian tax, GST, and regulatory requirements.",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "3. Sharing Your Data",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "We do not sell your Personal Data. We share it only in the following necessary circumstances:",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "With the Host: If you attend an event, your Name and Contact Information are shared with the specific Host for event management and communication.\nWith Payment Processors: Financial details are shared securely with established payment gateways (like Razorpay) to complete transactions.\nLegal Obligation: If required by Indian law enforcement or government authorities",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "4. Your Rights",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "You have the right, under law, to Access, Correct, and Request Erasure of your data, or Withdraw Consent at any time.",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white70,
                  fontSize: 14,
                 fontWeight: FontWeight.w400,
                ),
              ),

               Text(
                "5. Grievance Redressal",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

               Text(
                "For any privacy-related questions or concerns, please contact our designated Grievance Officer:",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
               Text(
                "Email: business@loopinsocial.in",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
























