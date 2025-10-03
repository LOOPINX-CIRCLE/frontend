// // ignore_for_file: deprecated_member_use

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';

// class InviteEventCards extends StatelessWidget {
//   final String badgeText;
//   final List<String> imageUrls;
//   final String title;
//   final String dateLocation;
//   final String hostName;
//   final bool isEnded;
//   final String imagePath;
//   final void Function(int index) onAddImage;

//   const InviteEventCards({
//     super.key,
//     required this.badgeText,
//     required this.imageUrls,
//     required this.title,
//     required this.dateLocation,
//     required this.hostName,
//     required this.isEnded,
//     required this.imagePath,
//     required this.onAddImage,
//   });

//   Widget buildImage(String path) {
//     if (path.startsWith('/')) {
//       // Local file
//       return Image.file(File(path), width: 360, height: 200, fit: BoxFit.cover);
//     } else {
//       // Asset
//       return Image.asset(path, width: 360, height: 200, fit: BoxFit.cover);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 350,
//       margin: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.red, width: 1),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // 🔹 Image Carousel
//           SizedBox(
//             height: 220,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: 3,
//               itemBuilder: (context, index) {
//                 String path = index < imageUrls.length
//                     ? imageUrls[index]
//                     : "assets/images/placeholder.png"; // fallback
//                 return Stack(
//                   children: [
//                     // 🔹 Background Image
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(16),
//                       child: Positioned(top: 20, child: buildImage(path)),
//                     ),

//                     // 🔹 Top Overlay Bar
//                     Positioned(
//                       top: 0,
//                       left: 0,
//                       right: 0,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 8,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.black.withOpacity(
//                             0.5,
//                           ), // transparent color overlay
//                           borderRadius: const BorderRadius.only(
//                             topLeft: Radius.circular(16),
//                             topRight: Radius.circular(16),
//                           ),
//                         ),
//                         child: Row(
//                           children: const [
//                             Icon(Icons.star, color: Colors.white, size: 18),
//                             SizedBox(width: 6),
//                             Text(
//                               "Featured Event",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),

//           const SizedBox(height: 8),
//           // 🔹 Badge
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: Text(
//               badgeText,
//               style: const TextStyle(
//                 fontSize: 12,
//                 color: Colors.red,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),

//           const SizedBox(height: 4),
//           // 🔹 Title
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: Text(
//               title,
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//             ),
//           ),

//           const SizedBox(height: 4),
//           // 🔹 Date & Location
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: Text(
//               dateLocation,
//               style: const TextStyle(fontSize: 14, color: Colors.grey),
//             ),
//           ),

//           const SizedBox(height: 4),
//           // 🔹 Host Name
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: Text(
//               "Hosted by $hostName",
//               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//             ),
//           ),

//           const SizedBox(height: 12),
//         ],
//       ),
//     );
//   }
// }

// class EventControllers extends GetxController {
//   final RxList<File> images = <File>[].obs;
//   final ImagePicker _picker = ImagePicker();

//   // Pick image for specific index
//   Future<void> pickImage(int index) async {
//     final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       final file = File(picked.path);
//       if (images.length > index) {
//         images[index] = file;
//       } else {
//         while (images.length < index) {
//           images.add(File('')); // placeholder
//         }
//         images.add(file);
//       }
//     }
//   }
// }

// class Eventpagescard extends StatelessWidget {
//   Eventpagescard({super.key});
//   final EventControllers controller = Get.put(EventControllers());

//   final String defaultAssetImage = "assets/images/Frame 1410136456.png";

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Event Example")),
//       body: Obx(() {
//         return InviteEventCards(
//           badgeText: "You're Invited",
//           imageUrls: controller.images.isNotEmpty
//               ? controller.images
//                     .map(
//                       (file) =>
//                           file.path.isNotEmpty ? file.path : defaultAssetImage,
//                     )
//                     .toList()
//               : [defaultAssetImage],
//           title: "F1 night",
//           dateLocation: "7 Jun 25, Bastian garden city",
//           hostName: "Anya",
//           isEnded: true,
//           imagePath: 'assets/images/button.png',
//           onAddImage: (index) {
//             controller.pickImage(index);
//           },
//         );
//       }),
//     );
//   }
// }
