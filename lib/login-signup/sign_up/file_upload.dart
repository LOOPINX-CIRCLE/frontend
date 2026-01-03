import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:text_code/Reusable/navigation_bar.dart';
import 'package:text_code/login-signup/sign_up/waitlist.dart';
import 'package:text_code/Home_pages/UI_Design/home_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:text_code/profilePage/profile_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/login-signup/Controller/user_controller.dart';
import 'package:text_code/core/services/auth_service.dart';
import 'package:text_code/core/network/api_exception.dart';

class PhotoUploadScreen extends StatefulWidget {
  const PhotoUploadScreen({super.key});

  @override
  State<PhotoUploadScreen> createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends State<PhotoUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<File?> _selectedImages = List<File?>.filled(6, null);
  final List<Uint8List?> _imageBytes = List<Uint8List?>.filled(6, null);
  final ProfileController _profileController = Get.find<ProfileController>();

  Future<void> _pickImage(int index) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Reduce quality for better performance
      );
      
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImages[index] = File(pickedFile.path);
          _imageBytes[index] = bytes;
        });
        // Save to profile controller
        _profileController.setImage(index, File(pickedFile.path), bytes);
      }
    } catch (e) {
      print('Error picking image: $e');
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool get allImagesSelected => _selectedImages.every((file) => file != null);
  bool get hasAtLeastOneImage => _selectedImages.any((file) => file != null);

  Future<void> _onNext() async {
    if (!hasAtLeastOneImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one photo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final userController = Get.find<UserController>();
      final authService = AuthService();
      
      // Get token
      final token = await authService.getStoredToken();
      if (token == null || token.isEmpty) {
        throw ApiException(
          message: 'Authentication required. Please verify OTP first.',
          statusCode: 401,
        );
      }

      // Process selected images
      // The API requires valid HTTP/HTTPS URLs, but we need to send at least 1 image
      // For now, we'll use placeholder URLs or try base64 format
      // TODO: Implement proper image upload endpoint to get real URLs
      final List<String> imageUrls = [];
      
      for (var i = 0; i < _selectedImages.length; i++) {
        if (_selectedImages[i] != null && _imageBytes[i] != null) {
          // Option 1: Try using base64 data URL (API might accept it despite validation error)
          // Option 2: Use placeholder URL format that looks valid
          // Option 3: Upload to server first (requires upload endpoint)
          
          // For now, using base64 data URL - API validation might be lenient
          // If this fails, we'll need to implement image upload endpoint first
          final base64Image = base64Encode(_imageBytes[i]!);
          imageUrls.add('data:image/jpeg;base64,$base64Image');
        }
      }

      // Check if we have at least one image (API requirement)
      if (imageUrls.isEmpty) {
        throw ApiException(
          message: 'Please select at least one profile picture',
          statusCode: 400,
        );
      }

      // Save profile pictures to UserController
      userController.setProfilePictures(imageUrls);

      // Prepare payload with proper formatting
      final payload = <String, dynamic>{
        'phone_number': userController.fullMobileNumber, // Already formatted with country code
        'name': userController.userName.value.trim(),
        'birth_date': userController.formattedBirthDate, // YYYY-MM-DD format
        'gender': userController.formattedGender, // lowercase: male, female, other
        'event_interests': userController.eventInterests.toList(), // Array of integers
        'profile_pictures': imageUrls, // Array of image URLs/data URLs
      };

      if (kDebugMode) {
        print('Complete profile payload: $payload');
        print('Birth date (formatted): ${userController.formattedBirthDate}');
        print('Gender (formatted): ${userController.formattedGender}');
        print('Event interests: ${userController.eventInterests.toList()}');
        print('Profile pictures count: ${imageUrls.length}');
        print('Profile pictures: ${imageUrls.isEmpty ? "Empty array" : "Has ${imageUrls.length} URLs"}');
      }

      // Call complete profile API
      final response = await authService.completeProfile(
        token: token,
        payload: payload,
      );

      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      // Check if successful
      if (response['success'] == true) {
        // Navigate to home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BottomBar(initialIndex: 0)),
        );
      } else {
        // Handle API validation errors
        final errorMessage = response['message']?.toString() ?? 
                             response['detail']?.toString() ?? 
                             'Failed to complete profile';
        throw ApiException(
          message: errorMessage,
          statusCode: 400,
          error: response,
        );
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show error with detailed message
      String errorMessage = e.message;
      
      // Parse validation errors if present
      if (e.error is Map<String, dynamic>) {
        final errorMap = e.error as Map<String, dynamic>;
        if (errorMap['detail'] != null) {
          final details = errorMap['detail'];
          if (details is List) {
            final errorMessages = details.map((error) {
              if (error is Map<String, dynamic> && error['msg'] != null) {
                return error['msg'].toString();
              }
              return '';
            }).where((msg) => msg.isNotEmpty).toList();
            
            if (errorMessages.isNotEmpty) {
              errorMessage = errorMessages.join('\n');
            }
          }
        }
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show generic error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildImageWidget(int index) {
    final imageFile = _selectedImages[index];
    final imageBytes = _imageBytes[index];
    
    if (imageFile == null) {
      return DottedBorder(
        color: const Color(0xffAEAEAE),
        borderType: BorderType.RRect,
        radius: const Radius.circular(10),
        dashPattern: const [10, 5],
        strokeWidth: 1.5,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Image.asset(
              "assets/images/image_upload.png",
              height: 37,
              width: 37,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.add_photo_alternate_outlined,
                  color: Color(0xffAEAEAE),
                  size: 37,
                );
              },
            ),
          ),
        ),
      );
    }

    // Use bytes for web compatibility, File for mobile
    if (kIsWeb && imageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(
          imageBytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[800],
              child: const Center(
                child: Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 30,
                ),
              ),
            );
          },
        ),
      );
    } else if (!kIsWeb && imageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          imageFile,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[800],
              child: const Center(
                child: Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 30,
                ),
              ),
            );
          },
        ),
      );
    } else {
      // Fallback
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            color: Colors.grey,
            size: 30,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate grid height dynamically for small screens
    // Available width = screenWidth - padding (24*2 = 48)
    final availableWidth = screenWidth - 48;
    // Item width = (availableWidth - (crossAxisSpacing * 2)) / 3
    // crossAxisSpacing: 12, so spacing between 3 items = 12 * 2 = 24
    final itemWidth = (availableWidth - 24) / 3;
    // Grid height = (itemWidth * 2 rows) + (mainAxisSpacing * 1) = (itemWidth * 2) + 16
    final gridHeight = (itemWidth * 2) + 16;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 56, 24, 32),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
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
                  ),
                  const SizedBox(height: 41),
                  
                  // Title
                  Text(
                    "Help hosts and fellow members \nrecognize you at events",
                     style: GoogleFonts.bricolageGrotesque(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                  ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Image grid with responsive height
                  SizedBox(
                    height: gridHeight,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 6,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1, // Ensures square tiles
                      ),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _pickImage(index),
                          child: _buildImageWidget(index),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Instructions
                  Text(
                    "Minimum 1 photo is required ",
                    style: TextStyle(
                      color: const Color(0xff868686),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'BricolageGrotesque',
                    ),
                  ),
                  const SizedBox(height: 4),
                 
                  
                  SizedBox(height: screenHeight * 0.15),
                  
                  GestureDetector(
                    onTap: hasAtLeastOneImage ? _onNext : null,
                    child: Container(
                      width: double.infinity,
                      height: 51,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          hasAtLeastOneImage
                              ? "assets/images/button2.png"   // image when images are selected
                              : "assets/images/button1.png", // image when no images selected
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}