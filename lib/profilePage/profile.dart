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
    final image = _profileController.uploadedImages[index];
    final bytes = _profileController.imageBytes[index];

    if (!isVisible) {
      return Container(); // Empty container for non-visible items
    }

    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: image != null
                ? (kIsWeb && bytes != null
                      ? Image.memory(
                          bytes!,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          image,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ))
                : Container(width: 200, height: 200, color: Colors.black),
          ),

          if (image != null && !hasMaxImages)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
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

                    // Edit Photos Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: _editPhotos,
                            child: Row(
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
                                    // optional tint, similar to icon color
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
                        itemCount:
                            5, // Show only 5 slots (excluding profile image)
                        itemBuilder: (context, index) {
                          return Obx(() {
                            // Skip index 0 (profile image), start from index 1
                            final actualIndex = index + 1;
                            final image =
                                _profileController.uploadedImages[actualIndex];
                            final bytes =
                                _profileController.imageBytes[actualIndex];

                            return Padding(
                              padding: EdgeInsets.only(
                                right: index < 4 ? 12 : 0,
                              ),
                              child: GestureDetector(
                                onTap: () => _pickAndAddImage(actualIndex),
                                child: SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: image != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(28),
                                          child: kIsWeb && bytes != null
                                              ? Image.memory(
                                                  bytes!,
                                                  width: 200,
                                                  height: 200,
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.file(
                                                  image,
                                                  width: 200,
                                                  height: 200,
                                                  fit: BoxFit.cover,
                                                ),
                                        )
                                      : DottedBorder(
                                          borderType: BorderType.RRect,
                                          radius: const Radius.circular(28),
                                          dashPattern: const [8, 6],
                                          color: const Color(0xFFAEAEAE),
                                          strokeWidth: 2,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF0A0909),
                                              borderRadius:
                                                  BorderRadius.circular(28),
                                            ),
                                            alignment: Alignment.center,
                                            child: Image.asset(
                                              'assets/icons/galleryadd.png',
                                              width: 60,
                                              height: 60,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            );
                          });
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
      ),
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
    ),
  );
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
            onPressed: () {
              // Handle logout
              Navigator.pop(context);
              Navigator.pop(context);
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
