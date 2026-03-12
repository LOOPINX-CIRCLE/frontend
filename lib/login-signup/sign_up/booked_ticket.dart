
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:text_code/login-signup/sign_up/share_invite.dart';
import 'package:text_code/Reusable/navigation_bar.dart';
import 'package:text_code/Home_pages/Controller/ticket_controller.dart';
import 'package:text_code/Reusable/smart_image.dart';
import 'package:text_code/core/services/ticket_service.dart';
import 'package:text_code/core/network/api_exception.dart';
import 'package:text_code/core/utils/image_utils.dart';
import 'package:text_code/Home_pages/Controller/home_page.dart';
import 'package:text_code/core/models/event.dart';

class BookedTicket extends StatefulWidget {
  const BookedTicket({super.key, this.showTabs = true});

  final bool showTabs;

  @override
  State<BookedTicket> createState() => _BookedTicketState();
}

class _BookedTicketState extends State<BookedTicket> {
  final UserTicketController ticketController = Get.put(UserTicketController());
  final TicketService _ticketService = TicketService();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  /// Format date from API response (ISO 8601 format)
  String _formatDate(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return '';
    }
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('EEEE d, MMMM yyyy').format(dateTime);
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing date: $e');
      }
      return '';
    }
  }

  /// Format time from API response (ISO 8601 format)
  String _formatTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return '';
    }
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('h:mm a').format(dateTime);
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing time: $e');
      }
      return '';
    }
  }

  /// Get first non-null string from map for given keys (API may use different names).
  String? _stringFromKeys(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final v = map[key]?.toString();
      if (v != null && v.isNotEmpty) return v;
    }
    return null;
  }

  /// Extract venue from my-tickets item (flat or nested under event/location).
  String _venueFromTicketData(Map<String, dynamic> ticketData) {
    // Flat keys
    final flat = _stringFromKeys(ticketData, ['venue_name', 'venue', 'location_name']);
    if (flat != null && flat.isNotEmpty) return flat;
    final locVal = ticketData['location'];
    if (locVal is String && locVal.isNotEmpty) return locVal;
    // Nested: event.venue_name, event.location.name, event.location_name, location.name
    final event = ticketData['event'];
    if (event is Map<String, dynamic>) {
      final fromEvent = _stringFromKeys(event, ['venue_name', 'venue', 'location_name']);
      if (fromEvent != null && fromEvent.isNotEmpty) return fromEvent;
      final loc = event['location'];
      if (loc is Map<String, dynamic>) {
        final name = _stringFromKeys(loc, ['name', 'venue_name', 'address']);
        if (name != null && name.isNotEmpty) return name;
      }
    }
    final loc = ticketData['location'];
    if (loc is Map<String, dynamic>) {
      final name = _stringFromKeys(loc, ['name', 'venue_name', 'address']);
      if (name != null && name.isNotEmpty) return name;
    }
    return '';
  }

  /// Extract cover image URL from my-tickets item (flat or nested under event).
  String _coverImageFromTicketData(Map<String, dynamic> ticketData) {
    // Flat keys
    final flat = _stringFromKeys(ticketData, [
      'cover_image_url', 'cover_image', 'image_url', 'event_cover_image',
      'event_image', 'image', 'cover_image_path',
    ]);
    if (flat != null && flat.isNotEmpty) return flat;
    // Nested: event.cover_image_url, event.cover_images[0], event.cover_image
    final event = ticketData['event'];
    if (event is Map<String, dynamic>) {
      final fromEvent = _stringFromKeys(event, [
        'cover_image_url', 'cover_image', 'image_url', 'event_cover_image',
        'event_image', 'image',
      ]);
      if (fromEvent != null && fromEvent.isNotEmpty) return fromEvent;
      final covers = event['cover_images'];
      if (covers is List && covers.isNotEmpty) {
        final first = covers.first;
        if (first is String) return first;
        if (first is Map && first['url'] != null) return first['url'].toString();
      }
    }
    return '';
  }

  /// Extract event ID from my-tickets item (flat or nested under event).
  int? _eventIdFromTicketData(Map<String, dynamic> ticketData) {
    final id = ticketData['event_id'];
    if (id != null) {
      if (id is int) return id;
      final parsed = int.tryParse(id.toString());
      if (parsed != null) return parsed;
    }
    final event = ticketData['event'];
    if (event is Map<String, dynamic>) {
      final eid = event['id'];
      if (eid != null) {
        if (eid is int) return eid;
        final parsed = int.tryParse(eid.toString());
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  /// Find event from home page list by ID (for cover image and venue).
  Event? _eventFromHomePage(int? eventId) {
    if (eventId == null) return null;
    try {
      if (!Get.isRegistered<HomePageController>()) return null;
      final controller = Get.find<HomePageController>();
      for (final event in controller.events) {
        if (event.id == eventId) return event;
      }
    } catch (_) {}
    return null;
  }

  /// Fetch all tickets from API
  Future<void> _fetchTickets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (kDebugMode) {
        print('Fetching all user tickets...');
      }

      // Fetch tickets from API
      final ticketsData = await _ticketService.getAllUserTickets();

      if (kDebugMode) {
        print('Fetched ${ticketsData.length} tickets from API');
      }

      // Clear existing tickets
      ticketController.tickets.clear();

      // Convert API response to UserTicket objects
      for (final ticketData in ticketsData) {
        if (kDebugMode) {
          print('Processing ticket data: $ticketData');
        }

        final eventTitle = _stringFromKeys(ticketData, ['event_title', 'event_name', 'title']) ?? '';
        final venueName = _venueFromTicketData(ticketData);
        final startTime = ticketData['event_start_time']?.toString() ??
            ticketData['start_time']?.toString() ??
            (ticketData['event'] != null
                ? (ticketData['event'] as Map<String, dynamic>)['start_time']?.toString()
                : null);
        final ticketSecret = ticketData['ticket_secret']?.toString() ??
            ticketData['secret']?.toString() ??
            '';

        final coverImageUrlRaw = _coverImageFromTicketData(ticketData);

        // Resolve image URL from API (handles relative paths)
        String coverImageUrl = coverImageUrlRaw.isNotEmpty
            ? resolveImageUrl(coverImageUrlRaw)
            : '';

        // Prefer cover image and venue from home page event if available
        String displayVenue = venueName;
        final eventId = _eventIdFromTicketData(ticketData);
        final homeEvent = _eventFromHomePage(eventId);
        if (homeEvent != null) {
          if (homeEvent.location.name.isNotEmpty) {
            displayVenue = homeEvent.location.name;
          }
          if (homeEvent.coverImages.isNotEmpty) {
            final first = homeEvent.coverImages.first;
            coverImageUrl = first.startsWith('http') ? first : resolveImageUrl(first);
          }
        }

        if (kDebugMode) {
          print('Ticket details:');
          print('  Event Title: $eventTitle');
          print('  Venue Name: $displayVenue (from ${homeEvent != null ? "home" : "API"})');
          print('  Cover Image URL (raw): $coverImageUrlRaw');
          print('  Ticket Secret: $ticketSecret');
          print('  Cover Image URL (resolved): $coverImageUrl');
        }

        // Format date and time
        final formattedDate = _formatDate(startTime);
        final formattedTime = _formatTime(startTime);
        final dateTimeString = formattedDate.isNotEmpty && formattedTime.isNotEmpty
            ? '$formattedDate, $formattedTime'
            : formattedDate.isNotEmpty
                ? formattedDate
                : '';

        // Create UserTicket object (include eventId so Home page can
        // mark these events as "You're going" with View ticket button).
        final ticket = UserTicket(
          title: eventTitle,
          date: dateTimeString,
          location: displayVenue.isNotEmpty ? displayVenue : 'Venue TBD',
          code: ticketSecret,
          eventImage: coverImageUrl.isNotEmpty
              ? coverImageUrl
              : "assets/images/image (1).png",
          eventId: eventId,
        );

        // Add to controller
        ticketController.addTicket(ticket);
      }

      setState(() {
        _isLoading = false;
      });

      if (kDebugMode) {
        print('Successfully loaded ${ticketController.tickets.length} tickets');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching tickets: $e');
      }

      String errorMessage = 'Failed to load tickets. Please try again.';
      if (e is ApiException) {
        errorMessage = e.message;
        if (e.statusCode == 401) {
          errorMessage = 'Please log in to view your tickets.';
        } else if (e.statusCode == 408) {
          errorMessage = 'Request timed out. Please check your connection.';
        }
      }

      setState(() {
        _isLoading = false;
        _errorMessage = errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showTabs) ...[
                const SizedBox(height: 8),
                // Top tabs like on Home_pages, with My tickets highlighted
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, bottom: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const BottomBar(initialIndex: 0),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(21),
                            border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.07)),
                          ),
                          child: const Text(
                            "Discover",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(21),
                          border: Border.all(color: Colors.white),
                        ),
                        child: const Text(
                          "My tickets",
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else
                const SizedBox(height: 8),
              // Loading state
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              // Error state
              else if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchTickets,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              // Tickets list
              else
                Obx(() {
                  if (ticketController.tickets.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(
                        child: Text(
                          'No tickets yet',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: ticketController.tickets.map((ticket) => TicketCard(
                      image: ticket.eventImage,
                      title: ticket.title,
                      date: ticket.date,
                      location: ticket.location,
                      code: ticket.code,
                      invites: ticket.invites,
                      buttonImage: ticket.buttonImage,
                    )).toList(),
                  );
                }),
              const SizedBox(height: 24),
            ],
          ),
    );

    if (widget.showTabs) {
      return Scaffold(
        backgroundColor: const Color(0xFF000000),
        body: SafeArea(
          child: content,
        ),
      );
    } else {
      return content;
    }
  }
}


class TicketCard extends StatelessWidget {
  final String image;
  final String title;
  final String date;
  final String location;
  final String code;
  final String? invites; // optional invite badge
  final String? buttonImage; // 👈 new param for button
  final int? eventId; // Event ID for share functionality

  const TicketCard({
    super.key,
    required this.image,
    required this.title,
    required this.date,
    required this.location,
    required this.code,
    this.invites,
    this.eventId,
    this.buttonImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      constraints: const BoxConstraints(minHeight: 120),
        decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment(-1.0, -0.5),
                    end: Alignment(1.0, 0.5),
                    colors: [
                      Color.fromRGBO(27, 27, 27, 0.6),
                      Color.fromRGBO(60, 60, 60, 0.42),
                      Color.fromRGBO(27, 27, 27, 0.6),
                    ],
                    stops: [0.2984, 0.5878, 0.9065],
                  ),
                  border: Border.all(
                    color: Color.fromRGBO(255, 255, 255, 0.13),
                    width: 1,
                  ),
                ),
      child: Stack(
        children: [
          Row(
            children: [
              // Event image with invite tag
              SizedBox(
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    if (invites != null)
                      Positioned(
                        bottom: -10,
                        left: 12,
                        right: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF8B5CF6),
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(12),
                            ),
                          ),
                          alignment: const Alignment(0, 0.8),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            invites!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SmartImage(
                          imagePath: image,
                          width: 82,
                          height: 82,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Event details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10, right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: "BricolageGrotesque",
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 8),
                      const Divider(
                        color: Colors.white24,
                        thickness: 1,
                        height: 1,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Image.asset('assets/images/Map Point.png', width: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.vpn_key_outlined,
                            size: 14,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            "Secret Code ",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              code,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 👇 Button in bottom-right corner
          if (buttonImage != null)
  Positioned(
    bottom: 7,
    right: 8,
    child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Invite(eventId: eventId ?? 0)),
        );
      },
      child: Image.asset(
        buttonImage!,
        width: 85,
      ),
    ),
  ),
        ],
      ),
    );
  }
}
