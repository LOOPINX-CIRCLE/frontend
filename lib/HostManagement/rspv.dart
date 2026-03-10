import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/core/services/event_service.dart';
import 'package:flutter/foundation.dart';

class RspvScreen {
  static Future<String?> show(BuildContext context, {int? eventId}) {
    if (kDebugMode) {
      print('🎯 RspvScreen.show() called with eventId: $eventId');
    }
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.35,
            bottom: bottomPadding + 20,
            left: 42,
            right: 42,
          ),
          child: RspvDeadlineModal(eventId: eventId),
        );
      },
    );
  }
}

class RspvDeadlineModal extends StatefulWidget {
  final int? eventId;

  const RspvDeadlineModal({super.key, this.eventId});

  @override
  State<RspvDeadlineModal> createState() => _RspvDeadlineModalState();
}

class _RspvDeadlineModalState extends State<RspvDeadlineModal> {
  String? selectedOption;
  bool _isLoading = false;
  String? _errorMessage;
  final EventService _eventService = EventService();

  @override
  void initState() {
    super.initState();
    // Default selection: "7 Days"
    selectedOption = '7 Days';
    if (kDebugMode) {
      print('🎪 RspvDeadlineModal initState:');
      print('   widget.eventId = ${widget.eventId}');
      print('   selectedOption = $selectedOption');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1C1C),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF4F4F4F),
          width: 2,
        ),
      ),
      child: SingleChildScrollView(
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
            const SizedBox(height: 12),
            
            // Error message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            
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
      ),
    );
  }

  Widget _buildRadioOption(String option) {
    final isSelected = selectedOption == option;
    
    return GestureDetector(
      onTap: () {
        if (kDebugMode) {
          print('🔘 Radio option tapped: $option');
        }
        setState(() {
          selectedOption = option;
          if (kDebugMode) {
            print('   selectedOption updated to: $selectedOption');
          }
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
      onTap: _isLoading ? null : _handleSave,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: _isLoading 
              ? const Color(0xFF9355F0).withOpacity(0.6)
              : const Color(0xFF9355F0), // Primary purple
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
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

  Future<void> _handleSave() async {
    if (selectedOption == null) return;

    if (kDebugMode) {
      print('\n🔍 ========== RSVP SAVE DEBUG ==========');
      print('🔍 _handleSave() called');
      print('   selectedOption = "$selectedOption"');
      print('   widget.eventId = ${widget.eventId}');
      print('   _eventService instance = $_eventService');
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.eventId != null) {
        // Call API to update RSVP deadline
        if (kDebugMode) {
          print('📤 Making API call to EventService.updateRsvpDeadline');
          print('   Parameters:');
          print('      eventId: ${widget.eventId!}');
          print('      rsvpOption: "$selectedOption"');
        }

        final response = await _eventService.updateRsvpDeadline(
          eventId: widget.eventId!,
          rsvpOption: selectedOption!,
        );

        if (kDebugMode) {
          print('✅ API Response received:');
          print('   Response: $response');
        }

        if (mounted && response['success'] == true) {
          // Show success message
          if (kDebugMode) {
            print('✅ Success! Closing modal...');
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'RSVP deadline updated successfully'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // Close dialog and return selected option
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.pop(context, selectedOption);
          }
        }
      } else {
        // No eventId provided, just return the selection
        if (kDebugMode) {
          print('⚠️ No eventId provided, just returning selection');
        }
        Navigator.pop(context, selectedOption);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in _handleSave: $e');
        print('   Error type: ${e.runtimeType}');
      }

      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to save RSVP deadline: $e';
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'Error saving RSVP deadline'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
