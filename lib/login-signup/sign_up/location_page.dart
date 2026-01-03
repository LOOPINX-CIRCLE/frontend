// // ignore_for_file: unused_field, library_private_types_in_public_api, use_full_hex_values_for_flutter_colors

// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// // import 'package:flutter_svg/svg.dart';
// import 'package:geocoding/geocoding.dart';
// // import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;

// class LocationSearchPage extends StatefulWidget {
//   const LocationSearchPage({super.key});

//   @override
//   _LocationSearchPageState createState() => _LocationSearchPageState();
// }

// class _LocationSearchPageState extends State<LocationSearchPage> {
//   final TextEditingController _searchController = TextEditingController();
//   final FocusNode _focusNode = FocusNode();
//   bool _isKeyboardOpen = false;
//   Timer? _debounce;
//   List<String> _suggestions = [];
//   String _currentAddress = '';
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(_onSearchChanged);
//     _focusNode.addListener(() {
//       setState(() {
//         _isKeyboardOpen = _focusNode.hasFocus;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.removeListener(_onSearchChanged);
//     _searchController.dispose();
//     _debounce?.cancel();
//     super.dispose();
//   }

//   void _onSearchChanged() {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();
//     _debounce = Timer(const Duration(milliseconds: 500), () {
//       if (_searchController.text.isNotEmpty) {
//         _fetchSuggestions(_searchController.text);
//       } else {
//         setState(() => _suggestions = []);
//       }
//     });
//   }

//   Future<void> _fetchSuggestions(String input) async {
//     setState(() => _isLoading = true);
//     final String url =
//         'https://nominatim.openstreetmap.org/search?q=$input&format=json&limit=5';
//     final response = await http.get(
//       Uri.parse(url),
//       headers: {'User-Agent': 'Flutter App'},
//     );
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       setState(() {
//         _suggestions = List<String>.from(
//           data.map((item) => item['display_name']),
//         );
//         _isLoading = false;
//       });
//     } else {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _setCurrentLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) return;

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) return;
//     }
//     if (permission == LocationPermission.deniedForever) return;

//     Position pos = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//     List<Placemark> placemarks = await placemarkFromCoordinates(
//       pos.latitude,
//       pos.longitude,
//     );
//     if (placemarks.isNotEmpty) {
//       final place = placemarks.first;
//       setState(() {
//         _currentAddress =
//             '${place.locality}, ${place.administrativeArea}, ${place.country}';
//         _searchController.text = _currentAddress;
//         _suggestions.clear();
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       body: Stack(
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage('assets/images/locationp.png'),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),

//           SafeArea(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(top: 45, left: 24),
//                   child: GestureDetector(
//                     onTap: () {
//                       Navigator.pop(context);
//                     },
//                     child: Image.asset('assets/images/check.png', height: 44),
//                   ),
//                 ),

//                 SizedBox(height: 230),
//                 Expanded(
//                   child: Container(
//                     width: 410,
//                     height: 45,
//                     padding: const EdgeInsets.only(top: 20),
//                     decoration: BoxDecoration(
//                       // color: Color(0x10ffffff),
//                       border: Border.all(color: Colors.white54, width: 1),
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(16),
//                         topRight: Radius.circular(16),
//                       ),
//                     ),
//                     child: SingleChildScrollView(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 20.0,
//                             ),
//                             child: Center(
//                               child: Container(
//                                 height: 45,
//                                 width: 410,
//                                 decoration: BoxDecoration(
//                                   color: Color(0x10fffff),
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(color: Colors.white30),
//                                 ),

//                                 child: Center(
//                                   child: TextField(
//                                     textAlignVertical: TextAlignVertical.bottom,

//                                     showCursor: false,
//                                     controller: _searchController,
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 20,
//                                       fontFamily: 'BricolageGrotesque',

//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                     decoration: InputDecoration(
//                                       isDense: true,
//                                       hintText: 'Search',
//                                       hintStyle: TextStyle(
//                                         color: Color(0x80ffffff),
//                                         fontSize: 20,
//                                         fontFamily: 'BricolageGrotesque',

//                                         fontWeight: FontWeight.w500,
//                                       ),

//                                       prefixIcon: Padding(
//                                         padding: const EdgeInsets.only(
//                                           left: 15,
//                                         ),
//                                         child: Padding(
//                                           padding: const EdgeInsets.only(
//                                             right: 20,
//                                           ),
//                                           child: SvgPicture.asset(
//                                             'assets/images/search.svg',
//                                           ),
//                                         ),
//                                       ),

//                                       filled: true,
//                                       fillColor: Color(0x40A4A4A4),
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                         borderSide: BorderSide.none,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: 20),
//                           if (_searchController.text.isEmpty) ...[
//                             Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 20,
//                               ),
//                               child: Text(
//                                 "Top results",
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 14,
//                                   fontFamily: 'BricolageGrotesque',
//                                   height: 1.2,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                             SizedBox(height: 10),
//                             _buildCityRow(
//                               'Bangalore, Karnataka',
//                               'assets/images/bang.png',
//                             ),
//                             SizedBox(height: 20),
//                             _buildCityRow('Mumbai', 'assets/images/mumbai.png'),
//                             SizedBox(height: 20),
//                             _buildCityRow('Delhi', 'assets/images/delhi.png'),
//                             SizedBox(height: 20),
//                           ] else if (_suggestions.isNotEmpty) ...[
//                             Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 10,
//                               ),
//                               child: Text(
//                                 "Search Results",
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 20,
//                                   fontFamily: 'BricolageGrotesque',
//                                   height: 1.2,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                             SizedBox(height: 5),
//                             ..._suggestions.map((s) => _buildListTile(s)),
//                           ],
//                           Padding(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16.0,
//                             ),
//                             child: Divider(
//                               color: Colors.white30, // Light divider color
//                               thickness: 0.8,
//                               indent: 110,
//                               endIndent: 110,
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16.0,
//                               vertical: 12.0,
//                             ),
//                             child: InkWell(
//                               onTap: _setCurrentLocation,
//                               borderRadius: BorderRadius.circular(16),
//                               child: Container(
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: 16.0,
//                                   vertical: 14.0,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Color(0x20A4A4A4),
//                                   borderRadius: BorderRadius.circular(10),
//                                   border: Border.all(color: Colors.white30),
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     SvgPicture.asset(
//                                       'assets/images/location.svg',
//                                     ),
//                                     SizedBox(width: 12),
//                                     Expanded(
//                                       child: Text(
//                                         _currentAddress.isEmpty
//                                             ? 'Select my current location'
//                                             : _currentAddress,
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 13,
//                                           fontFamily: 'BricolageGrotesque',
//                                           //height: 0.07,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),

//                           Padding(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16.0,
//                             ),
//                             child: Divider(
//                               color: Colors.white30, // Light divider color
//                               thickness: 0.8,
//                               indent: 110,
//                               endIndent: 110,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildListTile(String text) {
//     return ListTile(
//       title: Text(text, style: TextStyle(color: Colors.white)),
//       trailing: Icon(Icons.chevron_right, color: Colors.white54),
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => BottomAppBar()),
//         );
//       },
//     );
//   }

//   Widget _buildCityRow(String city, String imagePath) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder:
//                 (context) =>
//                     BottomAppBar(), // or pass city: city if HomeScreen accepts it
//           ),
//         );
//       },
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: Image.asset(
//                 imagePath,
//                 width: 32,
//                 height: 32,
//                 fit: BoxFit.cover,
//               ),
//             ),
//             SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 city,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 17,
//                   fontFamily: 'BricolageGrotesque',
//                   height: 0.07,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//             Icon(Icons.chevron_right, color: Colors.white54),
//           ],
//         ),
//       ),
//     );
//   }
// }
