import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bank_submit_success.dart';

class BankFormScreen extends StatefulWidget {
  final String bankName;
  final String? bankLogoPath; // Optional logo path for popular banks

  const BankFormScreen({
    super.key,
    required this.bankName,
    this.bankLogoPath,
  });

  @override
  State<BankFormScreen> createState() => _BankFormScreenState();
}

class _BankFormScreenState extends State<BankFormScreen> {
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _confirmAccountNumberController = TextEditingController();
  final TextEditingController _accountHolderNameController = TextEditingController();
  final FocusNode _accountNumberFocus = FocusNode();
  final FocusNode _ifscFocus = FocusNode();
  final FocusNode _confirmAccountNumberFocus = FocusNode();
  final FocusNode _accountHolderNameFocus = FocusNode();

  @override
  void dispose() {
    _accountNumberController.dispose();
    _ifscController.dispose();
    _confirmAccountNumberController.dispose();
    _accountHolderNameController.dispose();
    _accountNumberFocus.dispose();
    _ifscFocus.dispose();
    _confirmAccountNumberFocus.dispose();
    _accountHolderNameFocus.dispose();
    super.dispose();
  }

  bool get _isBasicFormFilled {
    return _accountNumberController.text.trim().isNotEmpty &&
        _ifscController.text.trim().isNotEmpty;
  }

  bool get _isAccountNumberMatching {
    return _accountNumberController.text.trim() ==
        _confirmAccountNumberController.text.trim();
  }

  bool get _isFormValid {
    return _isBasicFormFilled &&
        _confirmAccountNumberController.text.trim().isNotEmpty &&
        _accountHolderNameController.text.trim().isNotEmpty &&
        _isAccountNumberMatching;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 83),
                  child: Column(
                    children: [
                      // Back button row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2C2C2E),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/images/arrowbackbutton.png',
                                    width: 24,
                                    height: 24,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 40),
                            Text(
                              _isBasicFormFilled ? 'Proceed to submit' : 'Provide Details',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Form container
                      Container(
                        width: 340,
                        constraints: const BoxConstraints(
                          minHeight: 217,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF282828),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Bank icon and name row
                            Row(
                              children: [
                                if (widget.bankLogoPath != null) ...[
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        widget.bankLogoPath!,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ] else ...[
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        'assets/icons/Bank.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                Expanded(
                                  child: Text(
                                    widget.bankName,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            // Divider line
                            Container(
                              width: double.infinity,
                              height: 1,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                            const SizedBox(height: 2),
                            SizedBox(
                              height: _accountNumberController.text.isEmpty ? 24 : 16,
                            ),
                            // Account number input
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_accountNumberController.text.isNotEmpty) ...[
                                  Text(
                                    'Account number',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF9355F0),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                ],
                                TextField(
                                  controller: _accountNumberController,
                                  focusNode: _accountNumberFocus,
                                  onChanged: (_) => setState(() {}),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: _accountNumberController.text.isEmpty
                                        ? 'Account number'
                                        : null,
                                    hintStyle: GoogleFonts.poppins(
                                      color: Colors.grey.withValues(alpha: 0.5),
                                      fontSize: 14,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: _accountNumberFocus.hasFocus
                                            ? const Color(0xFF9355F0)
                                            : Colors.white.withValues(alpha: 0.3),
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xFF9355F0),
                                        width: 1,
                                      ),
                                    ),
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white.withValues(alpha: 0.3),
                                        width: 1,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: _ifscController.text.isEmpty ? 24 : 16,
                            ),
                            // IFSC input
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_ifscController.text.isNotEmpty) ...[
                                  Text(
                                    'IFSC',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF9355F0),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                ],
                                TextField(
                                  controller: _ifscController,
                                  focusNode: _ifscFocus,
                                  onChanged: (_) => setState(() {}),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  textCapitalization: TextCapitalization.characters,
                                  decoration: InputDecoration(
                                    hintText: _ifscController.text.isEmpty ? 'IFSC' : null,
                                    hintStyle: GoogleFonts.poppins(
                                      color: Colors.grey.withValues(alpha: 0.5),
                                      fontSize: 14,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: _ifscFocus.hasFocus
                                            ? const Color(0xFF9355F0)
                                            : Colors.white.withValues(alpha: 0.3),
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xFF9355F0),
                                        width: 1,
                                      ),
                                    ),
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white.withValues(alpha: 0.3),
                                        width: 1,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                  ),
                                ),
                              ],
                            ),
                            // Show additional fields when basic form is filled
                            if (_isBasicFormFilled) ...[
                              SizedBox(
                                height: _confirmAccountNumberController.text.isEmpty ? 24 : 16,
                              ),
                              // Confirm account number input
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_confirmAccountNumberController.text.isNotEmpty) ...[
                                    Text(
                                      'Confirm account number',
                                      style: GoogleFonts.poppins(
                                        color: _isAccountNumberMatching
                                            ? const Color(0xFF9355F0)
                                            : Colors.red,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                  ],
                                  TextField(
                                    controller: _confirmAccountNumberController,
                                    focusNode: _confirmAccountNumberFocus,
                                    onChanged: (_) => setState(() {}),
                                    style: GoogleFonts.poppins(
                                      color: _isAccountNumberMatching || _confirmAccountNumberController.text.isEmpty
                                          ? Colors.white
                                          : Colors.red,
                                      fontSize: 14,
                                    ),
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: _confirmAccountNumberController.text.isEmpty
                                          ? 'Confirm account number'
                                          : null,
                                      hintStyle: GoogleFonts.poppins(
                                        color: Colors.grey.withValues(alpha: 0.5),
                                        fontSize: 14,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: _confirmAccountNumberFocus.hasFocus
                                              ? (_isAccountNumberMatching
                                                  ? const Color(0xFF9355F0)
                                                  : Colors.red)
                                              : (_isAccountNumberMatching || _confirmAccountNumberController.text.isEmpty
                                                  ? Colors.white.withValues(alpha: 0.3)
                                                  : Colors.red),
                                          width: 1,
                                        ),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: _isAccountNumberMatching
                                              ? const Color(0xFF9355F0)
                                              : Colors.red,
                                          width: 1,
                                        ),
                                      ),
                                      border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: _isAccountNumberMatching || _confirmAccountNumberController.text.isEmpty
                                              ? Colors.white.withValues(alpha: 0.3)
                                              : Colors.red,
                                          width: 1,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.zero,
                                      isDense: true,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: _accountHolderNameController.text.isEmpty ? 24 : 16,
                              ),
                              // Account holder name input
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_accountHolderNameController.text.isNotEmpty) ...[
                                    Text(
                                      'Account holder\'s name',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF9355F0),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                  ],
                                  TextField(
                                    controller: _accountHolderNameController,
                                    focusNode: _accountHolderNameFocus,
                                    onChanged: (_) => setState(() {}),
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    textCapitalization: TextCapitalization.words,
                                    decoration: InputDecoration(
                                      hintText: _accountHolderNameController.text.isEmpty
                                          ? 'Account holder\'s name'
                                          : null,
                                      hintStyle: GoogleFonts.poppins(
                                        color: Colors.grey.withValues(alpha: 0.5),
                                        fontSize: 14,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: _accountHolderNameFocus.hasFocus
                                              ? const Color(0xFF9355F0)
                                              : Colors.white.withValues(alpha: 0.3),
                                          width: 1,
                                        ),
                                      ),
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFF9355F0),
                                          width: 1,
                                        ),
                                      ),
                                      border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.white.withValues(alpha: 0.3),
                                          width: 1,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.zero,
                                      isDense: true,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Next button at bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Center(
                child: GestureDetector(
                  onTap: _isFormValid
                      ? () {
                          // Navigate to success screen
                          Navigator.pop(context);
                          BankSubmitSuccessScreen.show(context);
                        }
                      : null,
                  child: Container(
                    width: _isBasicFormFilled ? 269 : 157,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    decoration: BoxDecoration(
                      color: _isFormValid
                          ? const Color(0xFF9355F0)
                          : const Color(0xFF2F2E2E),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: Text(
                        _isBasicFormFilled ? 'Proceed to submit' : 'Next',
                        style: GoogleFonts.poppins(
                          color: _isFormValid
                              ? Colors.white
                              : const Color(0xFF6D6767),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

