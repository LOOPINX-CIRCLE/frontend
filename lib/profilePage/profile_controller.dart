import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  // Store uploaded images
  RxList<File?> uploadedImages = <File?>[].obs;
  RxList<Uint8List?> imageBytes = <Uint8List?>[].obs;
  
  // Initialize with empty slots for 6 images
  @override
  void onInit() {
    super.onInit();
    uploadedImages.assignAll(List<File?>.filled(6, null));
    imageBytes.assignAll(List<Uint8List?>.filled(6, null));
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
}


