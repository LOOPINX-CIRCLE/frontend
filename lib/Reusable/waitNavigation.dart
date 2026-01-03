// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class WaitNavigationBar extends StatefulWidget {
  final int initialIndex;
  final Function(int)? onTap;
  const WaitNavigationBar({super.key, this.initialIndex = 0, this.onTap});

  @override
  _WaitNavigationBarState createState() => _WaitNavigationBarState();
}

class _WaitNavigationBarState extends State<WaitNavigationBar> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _selectedIndex = widget.initialIndex;
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  final List<String> _icons = [
    'assets/icons/Homes.png',
    'assets/icons/Stars.png',
    "assets/icons/User.png",
  ];

  final List<String> _labels = ["Home", "Wall", "Profile"];

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 24,
      child: Center(
        child: Container(
          height: 65,
          width: 239,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(16, 16, 16, 0.80),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: Color.fromRGBO(255, 255, 255, 0.07),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_icons.length, (index) {
            final bool isSelected = _selectedIndex == index;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
                if (widget.onTap != null) {
                  widget.onTap!(index);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 12 : 0,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  border: isSelected
                      ? Border.all(
                          color: Color.fromRGBO(255, 255, 255, 0.07),
                          width: 1.5,
                        )
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      _icons[index],
                      width: 24,
                      height: 24,
                      color: Colors.white,
                    ),
                    if (isSelected)
                      Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        child: Text(
                          _labels[index],
                          style: GoogleFonts.bricolageGrotesque(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
      ),
    );
  }
}


