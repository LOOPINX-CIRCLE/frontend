import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:text_code/core/services/auth_service.dart';
import 'package:text_code/core/models/user_profile.dart';
import 'package:text_code/core/network/api_exception.dart';
import 'package:flutter/foundation.dart';

class ProfileController extends GetxController {
  final AuthService _authService = AuthService();
  
  // Store uploaded images
  RxList<File?> uploadedImages = <File?>[].obs;
  RxList<Uint8List?> imageBytes = <Uint8List?>[].obs;
  
  // Store user profile data
  var userProfile = Rxn<UserProfile>();
  var isLoading = false.obs;
  var errorMessage = Rxn<String>();
  
  // Initialize with empty slots for 6 images
  @override
  void onInit() {
    super.onInit();
    uploadedImages.assignAll(List<File?>.filled(6, null));
    imageBytes.assignAll(List<Uint8List?>.filled(6, null));
    fetchProfile();
  }
  
  /// Fetch user profile from API
  Future<void> fetchProfile() async {
    isLoading.value = true;
    errorMessage.value = null;
    
    try {
      final profile = await _authService.fetchProfile();
      userProfile.value = profile;
      
      // Load profile pictures if available
      if (profile.profilePictures.isNotEmpty) {
        // Note: Profile pictures from API are URLs, not local files
        // You may need to download them or handle them differently
        // For now, we'll keep the local image management separate
      }
      
      if (kDebugMode) {
        print('Profile loaded: ${profile.name}, Age: ${profile.age}, Gender: ${profile.gender}');
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      if (kDebugMode) {
        print('Error fetching profile: ${e.message}');
      }
    } catch (e) {
      errorMessage.value = 'Failed to load profile: ${e.toString()}';
      if (kDebugMode) {
        print('Unexpected error fetching profile: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }
  
  // Set image at specific index
  void setImage(int index, File? file, Uint8List? bytes) {
    if (index >= 0 && index < uploadedImages.length) {
      uploadedImages[index] = file;
      imageBytes[index] = bytes;
    }
  }
  
  // Clear all images
  void clearImages() {
    uploadedImages.assignAll(List<File?>.filled(6, null));
    imageBytes.assignAll(List<Uint8List?>.filled(6, null));
  }
  
  // Get count of uploaded images
  int get uploadedImageCount => uploadedImages.where((img) => img != null).length;
  
  // Check if all 6 images are uploaded
  bool get hasAllImages => uploadedImageCount == 6;
  
  // Check if user can add more images
  bool get canAddImages => uploadedImageCount < 6;
  
  // Get user name from profile
  String get userName => userProfile.value?.name ?? '';
  
  // Get user age from profile
  String get userAge => userProfile.value?.age?.toString() ?? '';
  
  // Get user gender from profile
  String get userGender {
    final gender = userProfile.value?.gender ?? '';
    if (gender.isEmpty) return '';
    // Capitalize first letter
    return gender[0].toUpperCase() + gender.substring(1).toLowerCase();
  }
  
  // Get birth date from profile
  String get birthDate => userProfile.value?.birthDate ?? '';
  
  // Get formatted birth date (DD/MM/YYYY)
  String get formattedBirthDate {
    final date = userProfile.value?.birthDate ?? '';
    if (date.isEmpty) return '';
    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}'; // DD/MM/YYYY
      }
    } catch (e) {
      return date;
    }
    return date;
  }
  
  // Get profile pictures URLs from API
  List<String> get profilePictureUrls => userProfile.value?.profilePictures ?? [];
  
  // Check if user is verified
  bool get isVerified => userProfile.value?.isVerified ?? false;
}


