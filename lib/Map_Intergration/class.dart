// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:text_code/Host_Pages/Controller_files/event_cntroller.dart';
// import 'package:text_code/Host_Pages/Map_integration/map_implemtation.dart';
// import 'package:text_code/Map_Intergration/api_function.dart';

// class MApcontrollerimage extends StatefulWidget {
//   const MApcontrollerimage({super.key});

//   @override
//   State<MApcontrollerimage> createState() => _MApcontrollerimageState();
// }

// class _MApcontrollerimageState extends State<MApcontrollerimage> {
//   final TextEditingController _controller = TextEditingController();
//   final FocusNode _focusNode = FocusNode();
//   final ApiServices _apiServices = ApiServices();
//   final EventController eventController = Get.find<EventController>();

//   List<String> _suggestions = [];

//   bool get isActive => _focusNode.hasFocus || _controller.text.isNotEmpty;

//   void _onSearchChanged(String input) async {
//     if (input.isEmpty) {
//       setState(() => _suggestions = []);
//       return;
//     }

//     final results = await _apiServices.fetchPlaceSuggestions(input);
//     setState(() {
//       _suggestions = results;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     _focusNode.addListener(() {
//       setState(() {});
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _focusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFF1E1E1E),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Image.asset(
//                 "assets/icons/Map Point.png",
//                 width: 24,
//                 height: 24,
//                 color: isActive ? Colors.white : Colors.grey,
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: TextField(
//                   controller: _controller,
//                   focusNode: _focusNode,
//                   style: GoogleFonts.poppins(color: Colors.white),
//                   onChanged: (value) {
//                     _onSearchChanged(value);
//                     setState(() {});
//                   },
//                   decoration: InputDecoration(
//                     hintText: 'Add venue',
//                     hintStyle: GoogleFonts.poppins(
//                       color: Colors.grey,
//                       fontSize: 14,
//                     ),
//                     filled: true,
//                     fillColor: const Color(0xFF1E1E1E),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 10,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),

//           // 📍 Suggestions list
//           if (_suggestions.isNotEmpty)
//             ..._suggestions.map(
//               (suggestion) => ListTile(
//                 title: Text(
//                   suggestion,
//                   style: const TextStyle(color: Colors.white),
//                 ),
//                 onTap: () {
//                   _controller.text = suggestion;
//                   FocusScope.of(context).unfocus();

//                   // ✅ update EventController
//                   eventController.loaction.value = suggestion;
//                   eventController.mainLocationName.value = suggestion
//                       .split(",")
//                       .first;

//                   setState(() {
//                     _suggestions = [];
//                   });
//                 },
//               ),
//             ),

//           // ✅ Map Preview after selection
//           if (_controller.text.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.only(top: 12),
//               child: MapPreview(
//                 _controller
//                     .text, // Pass the selected location/address as the first positional argument
//                 apiKey:
//                     "AIzaSyBAAPv0Z6CZUdjnphbj9XH7YR1Z2jOS684", // yaha apna API key lagao
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
