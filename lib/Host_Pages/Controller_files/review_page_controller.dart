import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class CoverImageController extends GetxController {
  // Use XFile for web compatibility
  RxList<XFile> images = <XFile>[].obs;
  final ImagePicker _picker = ImagePicker();
  var currentImageIndex = 0.obs;
  final PageController pageController = PageController();

  // Field to store event ID
  int? eventId;

  final String defaultAssetImage = "assets/images/Frame 1410136456.png";

  Future<void> pickImage(int index) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (picked != null) {
        if (images.length > index) {
          images[index] = picked;
        } else {
          while (images.length < index) {
            // Create empty XFile placeholder for web compatibility
            images.add(XFile(''));
          }
          images.add(picked);
        }
        
        if (kDebugMode) {
          print('Image picked successfully: ${picked.name}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
      Get.snackbar(
        'Error', 
        'Failed to pick image. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  var count = 0.obs;

  void increment() => count.value++;
  void decrement() {
    if (count.value > 0) count.value--;
  }

  var selectedGender = "All genders".obs;
  var isDropdownOpen = false.obs;
  List<String> genders = ["All genders", "Male", "Female", "Non Binary"];

  OverlayEntry? _overlayEntry;

  void toggleDropdown(BuildContext context, GlobalKey key) {
    if (isDropdownOpen.value) {
      closeDropdown();
    } else {
      openDropdown(context, key);
    }
  }

  void openDropdown(BuildContext context, GlobalKey key) {
    final renderBox = key.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx + 30,
        top: offset.dy + size.height,
        right: 40, // 👈 screen ke right side se gap
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade700),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: genders.map((gender) {
                final isSelected =
                    gender == selectedGender.value; // 👈 check karo

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setSelectedGender(gender);
                      closeDropdown();
                    },
                    child: Container(
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 8,
                        top: 4,
                        bottom: 4,
                      ),
                      decoration: isSelected
                          ? BoxDecoration(
                              color: Colors
                                  .grey
                                  .shade700, // 👈 selected ka background
                              borderRadius: BorderRadius.circular(12),
                            )
                          : null,

                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              gender,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    isDropdownOpen.value = true;
  }

  void closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    isDropdownOpen.value = false;
  }

  void setSelectedGender(String value) {
    selectedGender.value = value;
  }
}
