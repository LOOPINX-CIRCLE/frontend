import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({super.key});

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
          "Terms of Conditions",
          style: GoogleFonts.bricolageGrotesque(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w400,
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
                "Loopinx Circle Private Limited",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Effective Date: October 24, 2025",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Loopinx Circle Private Limited ("Loopinx Circle," "we," "us," or "our") operates an invite-only platform that connects individuals and entities ("Hosts") who organize curated offline experiences with registered attendees ("Members"). These Terms govern your access to and use of our platform, whether you are a Host or a Member.',
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                "By accessing, browsing, registering for, or using the Loopinx Circle platform, you agree to be bound by these Terms and Conditions",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "1. General Terms and Eligibility (Applies to ALL Users)",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white70,
                  fontSize: 16,
                 fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Eligibility: You must be at least 18 years old and capable of forming a binding contract under Indian law to use the platform. /n Invite-Only Status: Loopinx Circle is an exclusive platform. We reserve the right to grant, revoke, or deny access to any Host or Member at our sole discretion, without providing a reason, to maintain the integrity and quality of the Circle./n Acceptable Use: You agree not to use the platform for any unlawful purpose, fraud, harassment, or to post content that is defamatory, obscene, or violates any third-party rights./nGoverning Law: These Terms shall be governed by and construed in accordance with the laws of India, and the courts in Bangalore, Karnataka shall have exclusive jurisdiction over any disputes.)",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "2. Terms Specific to HOSTS (Brands & Influencers)",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "In addition to the General Terms, Hosts agree to the following:",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "A. Event Responsibility and Liability",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white70,
                  fontSize: 16,
                 fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "1.Host Responsibility: The Host is the sole organizer and producer of the event. Loopinx Circle acts only as a technology platform and ticketing intermediary. The Host bears exclusive legal and financial responsibility for all aspects of the event, including, but not limited to:",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Securing all necessary permits, licenses, and insurance (e.g., venue, food service, music rights)\n Ensuring the safety and conduct of attendees and staff \n The accuracy of all event descriptions, times, and pricing.",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white70,
                  fontSize: 16,
                   fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "2.Indemnification: The Host agrees to indemnify and hold harmless Loopinx Circle against any claims, losses, or liabilities arising out of or related to their hosted event.",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              
              const SizedBox(height: 12),
              Text(
                "B. Monetization and Fees",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 12),
              Text(
                "1. Host Fees: Hosts agree to pay all applicable subscription fees (e.g., the ₹4,000 Premium Host Fee) and/or transaction commissions levied by Loopinx Circle, as specified on the platform's pricing page.\n 2. Taxes (GST/TDS): Hosts are responsible for their own tax obligations, including the collection and remittance of GST where applicable, and compliance with all TDS regulations related to earnings remitted by Loopinx Circle.",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 12),
              Text(
                "3. Terms Specific to MEMBERS (Attendees)",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 12),
              Text(
                "1. Ticket is a License: A ticket purchased grants a revocable license to attend the event. Hosts and/or the venue reserve the right to refuse entry or remove any Member whose conduct is deemed disruptive, non-compliant, or unsafe, without refund. \n 2. Assumption of Risk: Members acknowledge that attending offline events carries inherent risks. Loopinx Circle is not liable for any injury, loss, or damage to personal property incurred during attendance at an event hosted by a third party.",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white70,
                  fontSize: 16,
                 fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 12),
              Text(
                "B. Ticketing, Refunds, and Cancellations",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 12),
              Text(
                "Transaction Finality: All ticket sales are final unless otherwise stated by the specific Host or required by law.\n Refund Policy: Refunds are determined and processed by the Host in accordance with their event-specific refund policy, which must be clearly stated on the event page. Loopinx Circle will only process the refund on the Host's instruction.\nEvent Cancellation: In the event of a cancellation by the Host, the Host is solely responsible for initiating all refunds for the full face value of the ticket price. Loopinx Circle will process the refund but is not liable for the Host's failure to do so.",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 12),
              Text(
                "4. Disclaimers and Limitation of Liability",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white70,
                  fontSize: 16,
                 fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 12),
              Text(
                "Loopinx Circle is a technology service provider and ticketing platform only. We do not guarantee the quality, safety, or legality of any event or the conduct of any user. In no event shall Loopinx Circle be liable for any indirect, incidental, special, or consequential damages arising from the use of our service or attendance at any event. Our total liability to any user for any claim is limited to the greater of ₹500(Five Hundred Rupees) or the amount of fees paid to us by the user in the preceding six months.",
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.white70,
                  fontSize: 16,
                 fontWeight: FontWeight.w400,
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


