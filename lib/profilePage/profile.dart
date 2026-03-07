import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'profile_controller.dart';
import 'termsCondition.dart';
import 'PrivacyPolicy.dart';
import 'package:text_code/core/services/notification_service.dart';
import 'package:text_code/core/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_code/core/utils/image_url_helper.dart';

class ProfilePage extends StatefulWidget {
  final bool hasHomePagesAccess;
  const ProfilePage({super.key, this.hasHomePagesAccess = true});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  final ProfileController _profileController = Get.find<ProfileController>();

  // Remove hardcoded user data

  @override
  void initState() {
    super.initState();
    // Show cached profile instantly; fetch only on manual refresh or update
  }

  // Check if user has uploaded exactly 6 images
  bool get hasMaxImages => _profileController.hasAllImages;

  // Check if user has some images but less than 6
  bool get canAddImages => _profileController.canAddImages;

  // Check if user has any images
  bool get hasImages => _profileController.uploadedImageCount > 0;

  Future<void> _pickAndAddImage(int? index) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        if (index != null) {
          // Replace existing image at specific index
          _profileController.setImage(index, File(pickedFile.path), bytes);
          // ScaffoldMessenger.of(context)
        } else {
          // Add new image to first available slot
          bool added = false;
          for (int i = 0; i < _profileController.uploadedImages.length; i++) {
            if (_profileController.uploadedImages[i] == null) {
              _profileController.setImage(i, File(pickedFile.path), bytes);
              added = true;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Image uploaded to slot ${i + 1}'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
              break;
            }
          }
          if (!added) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'All 6 slots are full. Delete an image to add new ones.',
                ),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _deleteImage(int index) {
    _profileController.setImage(index, null, null);
  }

  void _editPhotos() {
    if (hasMaxImages) {
      // Show message that they can't edit when max images reached
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Maximum 6 images reached. Delete an image to add new ones.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      // Show image picker
      _pickAndAddImage(null);
    }
  }

  

  Widget _buildProfileImage() {
    // First check if there are server profile pictures
    final serverImages = _profileController.profilePictureUrls;
    if (serverImages.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Image.network(
          imageUrl(serverImages.first), // Use helper to resolve URL
          width: 116,
          height: 112,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            if (kDebugMode) {
              print('Error loading profile image from server: $error');
            }
            // Fallback to local image if network image fails
            return _buildLocalProfileImage();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 116,
              height: 112,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
        ),
      );
    }
    
    // Fallback to local image
    return _buildLocalProfileImage();
  }

  Widget _buildLocalProfileImage() {
    final firstImage = _profileController.uploadedImages.firstWhere(
      (img) => img != null,
      orElse: () => null,
    );
    int imageIndex = _profileController.uploadedImages.indexOf(
      firstImage ?? File(''),
    );
    final firstImageBytes = imageIndex >= 0
        ? _profileController.imageBytes[imageIndex]
        : null;

    if (firstImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: kIsWeb && firstImageBytes != null
            ? Image.memory(
                firstImageBytes,
                width: 116,
                height: 112,
                fit: BoxFit.cover,
              )
            : Image.file(
                firstImage,
                width: 116,
                height: 112,
                fit: BoxFit.cover,
              ),
      );
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 9, 9, 9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.person, size: 40, color: Colors.grey),
    );
  }

  Widget _buildImageItem(int index, bool isVisible) {
    if (!isVisible) {
      return Container(); // Empty container for non-visible items
    }

    // Get server images and local images
    final serverImages = _profileController.profilePictureUrls;
    final localImage = _profileController.uploadedImages[index];
    final localBytes = _profileController.imageBytes[index];
    
    // Determine what to show
    Widget imageWidget;
    bool showDeleteButton = false;
    
    // Skip the first server image since it's used as profile picture
    final adjustedServerImageIndex = index + 1;
    
    if (adjustedServerImageIndex < serverImages.length) {
      // Show server image (starting from index 1, skipping the profile pic)
      imageWidget = Image.network(
        imageUrl(serverImages[adjustedServerImageIndex]), // Use helper to resolve URL
        width: 200,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          if (kDebugMode) {
            print('Error loading server image at index $adjustedServerImageIndex: $error');
          }
          return _buildEmptyImageSlot();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      );
      showDeleteButton = false;
    } else {
      // Show empty slot
      imageWidget = _buildEmptyImageSlot();
      showDeleteButton = false;
    }

    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: imageWidget,
          ),
          // Show delete button only for local images
          if (showDeleteButton)
            Positioned(
              top: 8,
              right: 12,
              child: GestureDetector(
                onTap: () => _deleteImage(index),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGalleryImageItem(int serverImageIndex) {
    final serverImages = _profileController.profilePictureUrls;
    
    // Show server image at the given index
    if (serverImageIndex < serverImages.length) {
      return Container(
        margin: const EdgeInsets.only(right: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Image.network(
            imageUrl(serverImages[serverImageIndex]), // Use helper to resolve URL
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              if (kDebugMode) {
                print('Error loading gallery image at index $serverImageIndex: $error');
              }
              return _buildEmptyImageSlot();
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
          ),
        ),
      );
    }
    
    // Show empty slot if image doesn't exist
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: _buildEmptyImageSlot(),
      ),
    );
  }

  Widget _buildLocalImageWidget(File localImage, Uint8List? localBytes) {
    return kIsWeb && localBytes != null
        ? Image.memory(
            localBytes,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          )
        : Image.file(
            localImage,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          );
  }

  Widget _buildEmptyImageSlot() {
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: const Radius.circular(28),
      dashPattern: const [8, 6],
      color: const Color(0xFFAEAEAE),
      strokeWidth: 2,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFF0A0909),
          borderRadius: BorderRadius.circular(28),
        ),
        alignment: Alignment.center,
        child: Image.asset(
          'assets/icons/galleryadd.png',
          width: 60,
          height: 60,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        // Debug: Print server images info
        if (kDebugMode) {
          final serverImages = _profileController.profilePictureUrls;
          print('🖼️ Building profile page with ${serverImages.length} server images:');
          for (int i = 0; i < serverImages.length; i++) {
            print('   Image $i: ${serverImages[i]}');
          }
        }
        
        return Stack(
        children: [
          // Scrollable content
          SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Reduced top padding since no AppBar
                    const SizedBox(height: 20),
                    // Profile Section - No background container
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Obx(() {
                        if (_profileController.isLoading.value) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (_profileController.errorMessage.value != null && _profileController.errorMessage.value!.isNotEmpty) {
                          return Center(child: Text(_profileController.errorMessage.value!, style: TextStyle(color: Colors.red)));
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile Image
                            _buildProfileImage(),
                            const SizedBox(width: 16),
                            // User Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _profileController.userName,
                                    style: GoogleFonts.bricolageGrotesque(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${_profileController.userAge} yr, ${_profileController.userGender}",
                                    style: GoogleFonts.bricolageGrotesque(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Show verified tag if user has HomePages access, otherwise show badge
                                  widget.hasHomePagesAccess
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 15,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[800],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.verified,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                "Verified",
                                                style: GoogleFonts.bricolageGrotesque(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Image.asset(
                                          'assets/images/Badge (1).png',
                                          width: 100,
                                          height: 50,
                                          fit: BoxFit.contain,
                                        ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ),

                    const SizedBox(height: 16),

                    // Edit Photos Section (disabled - button visible but no function)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Image.asset(
                                  'assets/icons/Gallery Edit.png',
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Edit photos",
                                style: GoogleFonts.bricolageGrotesque(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: 6, // Show 6 gallery slots with empty ones
                        itemBuilder: (context, index) {
                          // Map to server images starting from index 1 (skip profile pic at 0)
                          int serverImageIndex = index + 1;
                          return Padding(
                            padding: EdgeInsets.only(
                              right: index < 5 ? 12 : 0,
                            ),
                            child: _buildGalleryImageItem(serverImageIndex),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Menu Items
                    _buildMenuSection(
                      items: [
                        _MenuItem(
                          "Edit Details",
                          imagePath: "assets/icons/User Circle.png",
                        ),
                        _MenuItem(
                          "Your Interests",
                          imagePath: "assets/icons/Stars.png",
                        ),
                        _MenuItem(
                          "Manage Invites",
                          imagePath: "assets/icons/Mailbox.png",
                        ),
                      ],
                    ),

                    _buildSectionHeader("Need Help?"),
                    _buildMenuSection(
                      items: [
                        _MenuItem(
                          "Report an Issue",
                          imagePath: "assets/icons/Flag 2.png",
                        ),
                        _MenuItem(
                          "Contact Support",
                          imagePath: "assets/icons/Vector.png",
                        ),
                        _MenuItem(
                          "Host Guide & Resources",
                          imagePath: "assets/icons/Hearts.png",
                        ),
                      ],
                    ),

                    _buildSectionHeader("The Loopinx Community"),
                    _buildMenuSection(
                      items: [
                        _MenuItem(
                          "Instagram",
                          imagePath: "assets/icons/instagram.png",
                          showExternalLink: true,
                        ),
                        _MenuItem(
                          "Youtube",
                          imagePath: "assets/icons/youtube.png",
                          showExternalLink: true,
                        ),
                        _MenuItem(
                          "Bluesky",
                          imagePath: "assets/icons/bluesky.png",
                          showExternalLink: true,
                        ),
                        _MenuItem(
                          "Share Your Feedback",
                          imagePath: "assets/icons/Star .png",
                          showExternalLink: true,
                        ),
                        _MenuItem(
                          "Invite a Member",
                          imagePath: "assets/icons/Users Group Rounded.png",
                        ),
                      ],
                    ),

                    _buildSectionHeader("Legal"),
                    _buildMenuSection(
                      items: [
                        _MenuItem(
                          "Terms of Use",
                          imagePath: "assets/icons/Document.png",
                        ),
                        _MenuItem(
                          "Privacy Policy",
                          imagePath: "assets/icons/Shield.png",
                        ),
                      ],
                    ),

                    _buildSectionHeader("Log out"),
                    _buildMenuSection(
                      items: [
                        _MenuItem(
                          "Log out",
                          imagePath: "assets/icons/Square Arrow Right.png",
                          isDestructive: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 2),

                    // Footer
                    Image.asset(
                      "assets/images/Logo and text (1).png",
                     
                     
                    ),
            

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
        ],
        );
      }), // Close Obx wrapper
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          textAlign: TextAlign.left,
          style: GoogleFonts.poppins(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection({required List<_MenuItem> items}) {
    return Container(
      margin: const EdgeInsets.only(
        left: 14,
        right: 14,
        top: 6,
        bottom: 6,
      ),
      decoration: BoxDecoration(
        color: Color(0xFF1E1C1C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: items.asMap().entries.map((entry) {
          int index = entry.key;
          _MenuItem item = entry.value;
          bool isLast = index == items.length - 1;
          return _buildMenuItem(item, isLast);
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item, bool isLast) {
    return InkWell(
      onTap: () {
        // Handle menu item tap
        if (item.title == "Log out") {
          // Show logout confirmation
          _showLogoutDialog();
        } else if (item.title == "Terms of Use") {
          // Navigate to Terms and Conditions
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TermsAndConditions()),
          );
        } else if (item.title == "Privacy Policy") {
          // Navigate to Privacy Policy
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PrivacyPolicy()),
          );
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 16,
              bottom: 16,
              left: 16,
              right: 16,
            ),
            child: Row(
          children: [
            if (item.imagePath != null)
              Image.asset(
                item.imagePath!,
                width: 24,
                height: 24,
                color: item.isDestructive ? Colors.white : Colors.white,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.image,
                    color: item.isDestructive ? Colors.red : Colors.white,
                    size: 24,
                  );
                },
              )
            else if (item.icon != null)
              Icon(
                item.icon,
                color: item.isDestructive ? Colors.white : Colors.white,
                size: 24,
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.title,
                style: GoogleFonts.poppins(
                  color: item.isDestructive ? Colors.white : Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            if (item.showExternalLink)
              const Icon(Icons.open_in_new, color: Colors.grey, size: 18)
            else
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
        if (!isLast)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 0.5,
            color: Colors.grey[800],
          ),
      ],
    ));
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          "Log out",
          style: GoogleFonts.bricolageGrotesque(color: Colors.white),
        ),
        content: Text(
          "Are you sure you want to log out?",
          style: GoogleFonts.bricolageGrotesque(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.bricolageGrotesque(color: Colors.blue),
            ),
          ),
          TextButton(
            onPressed: () async {
              // Dismiss the dialog
              Navigator.pop(context);
              
              try {
                // Deactivate device for push notifications
                final prefs = await SharedPreferences.getInstance();
                final playerId = prefs.getString('onesignal_player_id');
                
                if (playerId != null && playerId.isNotEmpty) {
                  if (kDebugMode) {
                    print('📱 Deactivating push notification device...');
                  }
                  final notificationService = NotificationDeviceService();
                  await notificationService.deactivateDevice(oneSignalPlayerId: playerId);
                }
                
                // Clear stored player ID
                await prefs.remove('onesignal_player_id');
                
                // Clear auth token
                final authService = AuthService();
                await authService.logout();
                
                if (kDebugMode) {
                  print('✅ Device deactivated and user logged out');
                }
                
                // Navigate to phone number page
                // Adjust route name based on your app's navigation
                Get.offAllNamed('/login'); // or your phone number page route
                
              } catch (e) {
                if (kDebugMode) {
                  print('❌ Error during logout: $e');
                }
                // Still proceed with logout even if deactivation fails
                final authService = AuthService();
                await authService.logout();
                Get.offAllNamed('/login');
              }
            },
            child: Text(
              "Log out",
              style: GoogleFonts.bricolageGrotesque(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final IconData? icon;
  final String? imagePath;
  final bool showExternalLink;
  final bool isDestructive;

  _MenuItem(
    this.title, {
    this.icon,
    this.imagePath,
    this.showExternalLink = false,
    this.isDestructive = false,
  });
}
