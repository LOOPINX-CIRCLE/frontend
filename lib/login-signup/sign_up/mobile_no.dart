import 'dart:ui';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:text_code/login-signup/sign_up/otp_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/core/services/auth_service.dart';
import 'package:text_code/core/network/api_exception.dart';
import 'package:text_code/login-signup/Controller/user_controller.dart';
import 'package:get/get.dart';

class MobileNo extends StatefulWidget {
  const MobileNo({super.key});

  @override
  State<MobileNo> createState() => _MobileNoState();
}

class _MobileNoState extends State<MobileNo> {
  final TextEditingController _phoneController = TextEditingController();
  final AuthService _authService = AuthService();
  Country _selectedCountry = Country.tryParse('IN')!;
  bool _isButtonEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhoneNumber);
  }

  void _validatePhoneNumber() {
    final digitsOnly = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final isValid = digitsOnly.length == 10;
    if (_isButtonEnabled != isValid) {
      setState(() {
        _isButtonEnabled = isValid;
      });
    }
  }

  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = country;
        });
      },
    );
  }

  Future<void> _handleContinue() async {
    if (!_isButtonEnabled || _isLoading) return; // Don't proceed if button is disabled or loading
    
    FocusScope.of(context).unfocus();
    final digitsOnly = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (!mounted || digitsOnly.length != 10) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Clear any existing token before starting new signup flow
      // This ensures we don't use stale tokens from previous sessions
      await _authService.logout();
      
      // Call send OTP API
      await _authService.sendOTP(
        phoneNumber: digitsOnly,
        countryCode: _selectedCountry.phoneCode, // Use phone code (e.g., "91") not country code (e.g., "IN")
      );

      if (!mounted) return;

      // Show success message (optional)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Save phone number to UserController
      final userController = Get.put(UserController());
      userController.setMobileNumber(digitsOnly, code: '+${_selectedCountry.phoneCode}');

      // Navigate to OTP page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPPage(
            phoneNumber: digitsOnly,
            countryCode: _selectedCountry.phoneCode, // Use phone code (e.g., "91") not country code (e.g., "IN")
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      // Show generic error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _authService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset('assets/images/bg.png', fit: BoxFit.cover),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenW * 0.065),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: keyboardVisible ? screenH * 0.15 : screenH * 0.25,
                          ),

        
                  ClipRRect(
  borderRadius: BorderRadius.circular(8), // must match container radius
  child: BackdropFilter(
    filter: ImageFilter.blur(
      sigmaX: 10.0, // horizontal blur intensity
      sigmaY: 10.0, // vertical blur intensity
    ),
    child: Container(
      width: screenW * 0.9,
      padding: EdgeInsets.all(screenW * 0.045),
      decoration: ShapeDecoration(
        color: const Color(0xB21F1F1F), // translucent overlay
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // First block
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: Text(
              'The invite you\'ve been \nwaitingfor',
              textAlign: TextAlign.center,
              // softWrap: true,
              style: GoogleFonts.bricolageGrotesque(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w400,
                                  ),
            ),
          ),

          SizedBox(height: screenH * 0.02),

          // Country picker + phone field
          Row(
            children: [
              GestureDetector(
                onTap: _showCountryPicker,
                child: Container(
                  height: screenH * 0.065,
                  padding: EdgeInsets.symmetric(horizontal: screenW * 0.03),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _selectedCountry.flagEmoji,
                        style: TextStyle(fontSize: screenW * 0.05),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+${_selectedCountry.phoneCode}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'BricolageGrotesque',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Image.asset(
                        "assets/images/arrow.png",
                        width: screenW * 0.045,
                        height: screenW * 0.025,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: screenH * 0.065,
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _phoneController,
                    style: const TextStyle(
                      fontFamily: 'BricolageGrotesqueRegular',
                      color: Colors.white,
                      height: 1.3,
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: screenH * 0.015,
                        horizontal: screenW * 0.04,
                      ),
                      hintText: '0000000000',
                      hintStyle: const TextStyle(
                        color: Color(0xFF868686),
                        fontFamily: 'BricolageGrotesque',
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: screenH * 0.01),

          const Text(
            "By continuing you are to receive SMS messages from Loopinx Circle for phone verification",
            style: TextStyle(
              fontFamily: 'BricolageGrotesque',
              fontWeight: FontWeight.w400,
              fontSize: 8,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  ),
),

        
                   
                          SizedBox(height: keyboardVisible ? 16 : screenH * 0.27),

                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: (_isButtonEnabled && !_isLoading) ? _handleContinue : null,
                                child: Container(
                                  width: screenW * 0.9,
                                  height: screenH * 0.065,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: _isLoading
                                        ? Container(
                                            color: const Color(0xFF1F1F21),
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            ),
                                          )
                                        : Image.asset(
                                            _isButtonEnabled
                                                ? 'assets/images/button2.png'
                                                : 'assets/images/button1.png',
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                              ),
                          
                              const SizedBox(height: 9),
                              const Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "By tapping Continue, you are agreeing to\n our ",
                                      style: TextStyle(
                                        fontFamily: 'BricolageGrotesque',
                                        fontSize: 10,
                                        color: Color(0xff868686),
                                      ),
                                    ),
                                    TextSpan(
                                      text: " Terms of Service",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xffD7D7D7),
                                      ),
                                    ),
                                    TextSpan(
                                      text: " and ",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xff868686),
                                      ),
                                    ),
                                    TextSpan(
                                      text: "Privacy Policy",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xffD7D7D7),
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
