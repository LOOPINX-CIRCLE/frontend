import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RspvScreen {
  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          top: 303,
          bottom: 200,
          left: 42,
          right: 42,
        ),
        child: const RspvDeadlineModal(),
      ),
    );
  }
}

class RspvDeadlineModal extends StatefulWidget {
  const RspvDeadlineModal({super.key});

  @override
  State<RspvDeadlineModal> createState() => _RspvDeadlineModalState();
}

class _RspvDeadlineModalState extends State<RspvDeadlineModal> {
  String? selectedOption;

  @override
  void initState() {
    super.initState();
    // Default selection: "7 Days"
    selectedOption = '7 Days';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 305,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1C1C),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF4F4F4F),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 6),
          // Radio button options
          _buildRadioOption('48 Hours'),
          _buildDivider(),
          _buildRadioOption('7 Days'),
          _buildDivider(),
          _buildRadioOption('Before Event Day'),
          _buildDivider(),
          _buildRadioOption('At Event Start'),
          // const Spacer(),
          SizedBox(height: 4),
          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: _buildCancelButton(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSaveButton(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String option) {
    final isSelected = selectedOption == option;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOption = option;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              option,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected 
                      ? const Color(0xFF9355F0) 
                      : Colors.white,
                  width: 2,
                ),
                color: isSelected 
                    ? const Color(0xFF9355F0) 
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.circle,
                        size: 10,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white.withOpacity(0.1),
    );
  }

  Widget _buildCancelButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        height: 44,
       decoration: BoxDecoration(
  color: const Color(0xFF1E1C1C),
  borderRadius: BorderRadius.circular(12),
  border: Border.all(
    color: const Color.fromRGBO(255, 255, 255, 0.30),
    width: 0.5,
  ),

      
        ),
        child: Center(
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: () {
        // Return the selected option
        Navigator.pop(context, selectedOption);
      },
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF9355F0), // Primary purple
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Save',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
