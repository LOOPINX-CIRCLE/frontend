import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_code/HostManagement/bankDetails/bankform.dart';

class AllBanksScreen extends StatefulWidget {
  const AllBanksScreen({super.key});

  @override
  State<AllBanksScreen> createState() => _AllBanksScreenState();
}

class _AllBanksScreenState extends State<AllBanksScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<String> _filteredBanks = [];
  String _selectedLetter = '';

  // Popular banks with their logos
  final List<Map<String, String>> _popularBanks = [
    {'name': 'HDFC Bank', 'logo': 'assets/icons/Bank Logos (Small).png'},
    {'name': 'Axis Bank', 'logo': 'assets/icons/Bank Logos (Small) (1).png'},
    {'name': 'ICICI Bank', 'logo': 'assets/icons/Bank Logos (Small) (2).png'},
    {'name': 'State Bank of India', 'logo': 'assets/icons/Bank Logos (Small) (3).png'},
    {'name': 'Kotak Mahindra Bank', 'logo': 'assets/icons/Bank Logos (Small) (4).png'},
    {'name': 'IDFC FIRST Bank', 'logo': 'assets/icons/Bank Logos (Small) (5).png'},
    {'name': 'Canara Bank', 'logo': 'assets/icons/Bank Logos (Small) (6).png'},
    {'name': 'Bank of Baroda', 'logo': 'assets/icons/Bank Logos (Small) (7).png'},
    {'name': 'South Indian Bank', 'logo': 'assets/icons/Bank Logos (Small) (9).png'},
  ];

  // All banks list from JSON
  final List<String> _allBanks = [
    "State Bank of India",
    "Punjab National Bank",
    "Bank of Baroda",
    "Canara Bank",
    "Union Bank of India",
    "Indian Bank",
    "Indian Overseas Bank",
    "UCO Bank",
    "Bank of India",
    "Central Bank of India",
    "Punjab & Sind Bank",
    "Bank of Maharashtra",
    "HDFC Bank",
    "ICICI Bank",
    "Axis Bank",
    "Kotak Mahindra Bank",
    "IndusInd Bank",
    "IDFC FIRST Bank",
    "Federal Bank",
    "Yes Bank",
    "RBL Bank",
    "South Indian Bank",
    "Bandhan Bank",
    "IDBI Bank",
    "City Union Bank",
    "Karnataka Bank",
    "Karur Vysya Bank",
    "DCB Bank",
    "Tamilnad Mercantile Bank",
    "Nainital Bank",
    "Jammu & Kashmir Bank",
    "CSB Bank",
    "Dhanlaxmi Bank",
    "AU Small Finance Bank",
    "Equitas Small Finance Bank",
    "Ujjivan Small Finance Bank",
    "Jana Small Finance Bank",
    "ESAF Small Finance Bank",
    "Suryoday Small Finance Bank",
    "Fincare Small Finance Bank",
    "Utkarsh Small Finance Bank",
    "North East Small Finance Bank",
    "Capital Small Finance Bank",
    "Shivalik Small Finance Bank",
    "Unity Small Finance Bank",
    "Paytm Payments Bank",
    "Airtel Payments Bank",
    "India Post Payments Bank",
    "Fino Payments Bank",
    "Jio Payments Bank",
    "NSDL Payments Bank",
    "Kerala Gramin Bank",
    "Andhra Pradesh Grameena Vikas Bank",
    "Baroda UP Bank",
    "Baroda Rajasthan Kshetriya Gramin Bank",
    "Madhyanchal Gramin Bank",
    "Maharashtra Gramin Bank",
    "Prathama UP Gramin Bank",
    "Sarva UP Gramin Bank",
    "Karnataka Vikas Grameena Bank",
    "Kaveri Grameena Bank",
    "Arunachal Pradesh Rural Bank",
    "Assam Gramin Vikash Bank",
    "Chaitanya Godavari Grameena Bank",
    "Saptagiri Grameena Bank",
    "Dakshin Bihar Gramin Bank",
    "Paschim Banga Gramin Bank",
    "Vidarbha Konkan Gramin Bank",
    "Mizoram Rural Bank",
    "Meghalaya Rural Bank",
    "Tripura Gramin Bank",
    "Nagaland Rural Bank",
    "Manipur Rural Bank",
    "J&K Grameen Bank",
    "Ellaquai Dehati Bank",
    "Himachal Pradesh Gramin Bank",
    "Punjab Gramin Bank",
    "Rajasthan Marudhara Gramin Bank",
    "Madhya Pradesh Gramin Bank",
    "Uttarakhand Gramin Bank",
    "Odisha Gramya Bank",
    "Utkal Grameen Bank",
    "Aryavart Bank",
    "Madhya Bihar Gramin Bank",
    "Saurashtra Gramin Bank",
    "Tamil Nadu Grama Bank",
    "Andhra Pragathi Grameena Bank",
    "Telangana Grameena Bank",
    "Baroda Gujarat Gramin Bank",
    "Chhattisgarh Rajya Gramin Bank",
  ];

  // Alphabet letters for scroll index
  final List<String> _alphabet = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '#'
  ];

  @override
  void initState() {
    super.initState();
    // Remove popular banks from all banks list to avoid duplicates
    final popularBankNames = _popularBanks.map((b) => b['name']!).toSet();
    _allBanks.removeWhere((bank) => popularBankNames.contains(bank));
    _allBanks.sort(); // Sort alphabetically
    _filteredBanks = List.from(_allBanks);
    _searchController.addListener(_filterBanks);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _filterBanks() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      if (query.isEmpty) {
        _filteredBanks = List.from(_allBanks);
      } else {
        _filteredBanks = _allBanks
            .where((bank) => bank.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _scrollToLetter(String letter) {
    // Calculate the position to scroll to
    double scrollPosition = 0.0;
    bool found = false;
    
    for (int i = 0; i < _filteredBanks.length; i++) {
      final bank = _filteredBanks[i];
      final firstLetter = _getFirstLetter(bank);
      
      if (firstLetter == letter && !found) {
        // Account for Popular Banks section height (approximately)
        scrollPosition = (i * 60.0) + 300.0; // 300 for popular banks section
        found = true;
        break;
      }
    }
    
    if (found) {
      _scrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    
    setState(() {
      _selectedLetter = letter;
    });
    
    // Reset selection after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _selectedLetter = '';
        });
      }
    });
  }

  String _getFirstLetter(String bankName) {
    final firstChar = bankName.trim()[0].toUpperCase();
    return RegExp(r'[A-Z]').hasMatch(firstChar) ? firstChar : '#';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with back button and title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2C2C2E),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/arrowbackbutton.png',
                          width: 24,
                          height: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Title
                 
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Your Bank',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Search box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF171717),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by bank name',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
            // Content with scroll index
            Expanded(
              child: Row(
                children: [
                  // Main content
                  Expanded(
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        // Popular Banks section
                        Text(
                          'Popular Banks',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: _popularBanks.length,
                          itemBuilder: (context, index) {
                            final bank = _popularBanks[index];
                            return GestureDetector(
                              onTap: () {
                                // Navigate to bank form
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BankFormScreen(
                                      bankName: bank['name']!,
                                      bankLogoPath: bank['logo'],
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  Center(
                                    child: Image.asset(
                                      bank['logo']!,
                                      height: 47,
                                      width: 47,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    bank['name']!,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 15),
                        // All Banks section
                        Text(
                          'All Banks',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredBanks.length,
                          itemBuilder: (context, index) {
                            final bank = _filteredBanks[index];
                            final isFirstOfLetter = index == 0 ||
                                _getFirstLetter(_filteredBanks[index - 1]) !=
                                    _getFirstLetter(bank);
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isFirstOfLetter) ...[
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                                    child: Text(
                                      _getFirstLetter(bank),
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF9853FF),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                                 GestureDetector(
                                   onTap: () {
                                     // Navigate to bank form
                                     Navigator.push(
                                       context,
                                       MaterialPageRoute(
                                         builder: (context) => BankFormScreen(
                                           bankName: bank,
                                         ),
                                       ),
                                     );
                                   },
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.asset(
                                              'assets/icons/Bank.png',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            bank,
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // Alphabet scroll index
                  Container(
                    width: 30,
                    margin: const EdgeInsets.only(right: 8),
                    child: ListView.builder(
                      itemCount: _alphabet.length,
                      itemBuilder: (context, index) {
                        final letter = _alphabet[index];
                        final isSelected = _selectedLetter == letter;
                        return GestureDetector(
                          onTap: () => _scrollToLetter(letter),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              letter,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: isSelected
                                    ? const Color(0xFF9853FF)
                                    : const Color(0xFF9853FF).withValues(alpha: 0.6),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

