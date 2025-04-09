<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:eventory/screnns/otherscreens/payments.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:eventory/helpers/theme_helper.dart'; // Added import
=======
// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:eventory/screnns/otherscreens/payments.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f

class EventPage extends StatefulWidget {
  final String eventId;

  const EventPage({super.key, required this.eventId});

  @override
  State<EventPage> createState() => _EventPageState();
}

<<<<<<< HEAD
class _EventPageState extends State<EventPage> with SingleTickerProviderStateMixin {
=======
class _EventPageState extends State<EventPage> {
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
  Map<String, dynamic>? eventData;
  Map<String, int> ticketCounts = {};
  String? userEmail;
  String? userId;
  bool isLoading = true;
<<<<<<< HEAD
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
=======
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );
=======
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
    fetchEventData();
    fetchUserDetails();
  }

<<<<<<< HEAD
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

=======
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
  Future<void> fetchEventData() async {
    try {
      DocumentSnapshot eventDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .get();

      if (eventDoc.exists) {
        setState(() {
          eventData = eventDoc.data() as Map<String, dynamic>;
<<<<<<< HEAD
=======
          isLoading = false;
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
        });
      }
    } catch (e) {
      print("Error fetching event data: $e");
<<<<<<< HEAD
    } finally {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading
      if (mounted) {
        setState(() => isLoading = false);
        _animationController.forward();
      }
=======
      setState(() => isLoading = false);
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
    }
  }

  Future<void> fetchUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email;
        userId = user.uid;
      });
    }
  }

  double calculateTotalPrice() {
    double total = 0;
    eventData?.forEach((key, value) {
      if (key.contains("TicketPrice") && value != null) {
        total += (value is int ? value.toDouble() : value) *
            (ticketCounts[key] ?? 0);
      }
    });
    return total;
  }

  int calculateTotalTickets() {
    return ticketCounts.values.fold(0, (prev, curr) => prev + curr);
  }

  void updateTicketCount(String ticketType, int change) {
    setState(() {
      ticketCounts[ticketType] = (ticketCounts[ticketType] ?? 0) + change;
      if (ticketCounts[ticketType]! < 0) {
        ticketCounts[ticketType] = 0;
      }
    });
  }

  Future<int> getLastTicketId() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Tickets')
        .orderBy('ticketId', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final lastTicketId = snapshot.docs.first['ticketId'];
      if (lastTicketId is int) return lastTicketId;
<<<<<<< HEAD
      if (lastTicketId is String) {
        final parsedId = int.tryParse(lastTicketId);
        if (parsedId != null) return parsedId;
      }
=======
      if (lastTicketId is String) return int.tryParse(lastTicketId) ?? 1000;
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
    }
    return 1000;
  }

  void proceedToPayment() async {
<<<<<<< HEAD
    if (calculateTotalTickets() == 0) return;

    // Animation feedback
    _animationController.reset();
    await _animationController.forward();

    // Payment processing logic...
    double totalPrice = calculateTotalPrice();

=======
    if (calculateTotalPrice() == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one ticket')),
      );
      return;
    }

    // Generate booking ID
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
    QuerySnapshot bookingSnapshot = await FirebaseFirestore.instance
        .collection('Bookings')
        .orderBy('bookingId', descending: true)
        .limit(1)
        .get();

<<<<<<< HEAD
    DocumentSnapshot? lastBooking =
    bookingSnapshot.docs.isNotEmpty ? bookingSnapshot.docs.first : null;

    int newBookingId =
    lastBooking == null ? 100001 : (lastBooking['bookingId'] as int) + 1;

=======
    int newBookingId = bookingSnapshot.docs.isEmpty
        ? 100001
        : (bookingSnapshot.docs.first['bookingId'] as int) + 1;

    // Generate tickets
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
    int lastTicketId = await getLastTicketId();
    List<Map<String, dynamic>> tickets = [];

    for (var entry in ticketCounts.entries) {
      if (entry.value > 0) {
        for (int i = 0; i < entry.value; i++) {
          lastTicketId++;
          tickets.add({
            'ticketId': lastTicketId,
            'ticketName': entry.key.replaceAll("TicketPrice", ""),
            'ticketPrice': eventData![entry.key],
            'bookingId': newBookingId,
            'eventId': widget.eventId,
            'userId': userId,
          });
        }
      }
    }

    if (userEmail != null) {
<<<<<<< HEAD
      await _sendConfirmationEmail(userEmail!, newBookingId, totalPrice);
=======
      await _sendConfirmationEmail(
          userEmail!, newBookingId, calculateTotalPrice());
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
    }

    Navigator.push(
      context,
<<<<<<< HEAD
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => PaymentsPage(
          totalPrice: totalPrice.toInt(),
=======
      MaterialPageRoute(
        builder: (context) => PaymentsPage(
          totalPrice: calculateTotalPrice().toInt(),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
          eventId: widget.eventId,
          totalTickets: calculateTotalTickets(),
          tickets: tickets,
          bookingId: newBookingId,
        ),
<<<<<<< HEAD
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
=======
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
      ),
    );
  }

  Future<void> _sendConfirmationEmail(
      String userEmail, int bookingId, double totalPrice) async {
    final Email email = Email(
      body:
<<<<<<< HEAD
      'Thank you for booking! Your booking ID is: $bookingId\nTotal Price: LKR ${totalPrice.toStringAsFixed(2)}',
      subject: 'Booking Confirmation - $bookingId',
=======
          'Thank you for booking!\n\nBooking ID: $bookingId\nEvent: ${eventData!['eventName']}\nTotal: LKR ${totalPrice.toStringAsFixed(2)}',
      subject: 'Booking Confirmation - ${eventData!['eventName']}',
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
      recipients: [userEmail],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (e) {
      print("Error sending email: $e");
    }
  }

<<<<<<< HEAD
  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Shimmer.fromColors(
            baseColor: Theme.of(context).hoverColor!,
            highlightColor: Theme.of(context).highlightColor!,
            child: Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Title placeholder
          Shimmer.fromColors(
            baseColor: Theme.of(context).hoverColor!,
            highlightColor: Theme.of(context).highlightColor!,
            child: Container(
              width: 200,
              height: 30,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          // Info placeholders
          Shimmer.fromColors(
            baseColor: Theme.of(context).hoverColor!,
            highlightColor: Theme.of(context).highlightColor!,
            child: Column(
              children: List.generate(
                4,
                    (index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Container(
                    width: double.infinity,
                    height: 20,
=======
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Event Details",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (eventData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Event Details"),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0,
        ),
        body: const Center(child: Text("Event not found")),
      );
    }

    final dateTime = eventData!['selectedDateTime'] is Timestamp
        ? (eventData!['selectedDateTime'] as Timestamp).toDate()
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(eventData!['eventName'] ?? "Event Details",
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  eventData!['imageUrl'] ?? "",
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 220,
                    color: Colors.grey[200],
                    child:
                        const Icon(Icons.event, size: 60, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Event Details
            Text(
              eventData!['eventName'] ?? "Event Name",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),

            if (dateTime != null)
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('EEE, MMM d • h:mm a').format(dateTime),
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.location_on, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  "${eventData!['eventVenue'] ?? 'Venue'} • ${eventData!['location'] ?? 'Location'}",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Divider(height: 1, color: Colors.grey),
            const SizedBox(height: 16),

            // Ticket Selection
            const Text(
              "Select Tickets",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            Column(
              children: [
                if (eventData!['normalTicketPrice'] != null)
                  _buildTicketCard("Standard", "normalTicketPrice"),
                if (eventData!['otherTicketPrice'] != null)
                  _buildTicketCard("Other", "otherTicketPrice"),
                if (eventData!['specialTicketPrice'] != null)
                  _buildTicketCard("Premium", "specialTicketPrice"),
                if (eventData!['vipTicketPrice'] != null)
                  _buildTicketCard("VIP", "vipTicketPrice"),
              ],
            ),
            const SizedBox(height: 24),

            // Order Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    "Order Summary",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Tickets:",
                          style: TextStyle(color: Colors.grey)),
                      Text(calculateTotalTickets().toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total:",
                          style: TextStyle(color: Colors.grey)),
                      Text(
                        "LKR ${calculateTotalPrice().toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Book Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: proceedToPayment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Continue to Payment",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                    color: Colors.white,
                  ),
                ),
              ),
            ),
<<<<<<< HEAD
          ),
          const SizedBox(height: 20),
          // Ticket selectors placeholders
          Shimmer.fromColors(
            baseColor: Theme.of(context).hoverColor!,
            highlightColor: Theme.of(context).highlightColor!,
            child: Column(
              children: List.generate(
                3,
                    (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    height: 80,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
=======
          ],
        ),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildTicketSelector(String label, String key, int index) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 500),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardColor(context),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: AppColors.orangePrimary.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
=======
  Widget _buildTicketCard(String label, String key) {
    final price = eventData![key] is int
        ? eventData![key].toDouble()
        : eventData![key] ?? 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
<<<<<<< HEAD
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor(context),
=======
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
<<<<<<< HEAD
                      'LKR ${NumberFormat('#,###').format(eventData![key])}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.orangePrimary,
                        fontWeight: FontWeight.w700,
=======
                      "LKR ${price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
<<<<<<< HEAD
                      icon: const Icon(Icons.remove_circle_outline,
                          color: AppColors.orangePrimary, size: 28),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        updateTicketCount(key, -1);
                      },
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        '${ticketCounts[key] ?? 0}',
                        key: ValueKey<int>(ticketCounts[key] ?? 0),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor(context),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline,
                          color: AppColors.orangePrimary, size: 28),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        updateTicketCount(key, 1);
                      },
=======
                      icon: const Icon(Icons.remove_circle_outline),
                      color: Colors.grey,
                      onPressed: () => updateTicketCount(key, -1),
                    ),
                    Container(
                      width: 30,
                      alignment: Alignment.center,
                      child: Text(
                        "${ticketCounts[key] ?? 0}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      color: Colors.orange,
                      onPressed: () => updateTicketCount(key, 1),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                    ),
                  ],
                ),
              ],
            ),
<<<<<<< HEAD
          ),
=======
          ],
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
        ),
      ),
    );
  }
<<<<<<< HEAD

  Widget _buildEventDetails() {
    DateTime eventDate = (eventData!['selectedDateTime'] as Timestamp).toDate();
    String formattedDate = DateFormat('EEE, MMM d • h:mm a').format(eventDate);
    int daysUntilEvent = eventDate.difference(DateTime.now()).inDays;

    return AnimationConfiguration.synchronized(
      child: FadeInAnimation(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Image
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: eventData!['imageUrl'] ?? '',
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: Theme.of(context).hoverColor,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(AppColors.orangePrimary),
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Theme.of(context).hoverColor,
                        child: Icon(Icons.error, color: Theme.of(context).hintColor),
                      ),
                    ),
                    if (daysUntilEvent < 7)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.orangePrimary,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'SOON: ${daysUntilEvent}d',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Event Title
              Text(
                eventData!['eventName'] ?? 'Event Name',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor(context),
                ),
              ),
              const SizedBox(height: 12),

              // Event Details
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 20, color: AppColors.orangePrimary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      eventData!['eventVenue'] ?? 'Venue not specified',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time,
                      size: 20, color: AppColors.orangePrimary),
                  const SizedBox(width: 8),
                  Text(
                    formattedDate,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Available Tickets
              Text(
                'Available Tickets',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor(context),
                ),
              ),
              const SizedBox(height: 12),

              // Ticket Selectors
              Column(
                children: [
                  if (eventData!['normalTicketPrice'] != null)
                    _buildTicketSelector("Standard Ticket", "normalTicketPrice", 0),
                  if (eventData!['vipTicketPrice'] != null)
                    _buildTicketSelector("VIP Ticket", "vipTicketPrice", 1),
                  if (eventData!['specialTicketPrice'] != null)
                    _buildTicketSelector("Special Ticket", "specialTicketPrice", 2),
                  if (eventData!['otherTicketPrice'] != null)
                    _buildTicketSelector("Other Ticket", "otherTicketPrice", 3),
                ],
              ),
              const SizedBox(height: 24),

              // Total Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardColor(context),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(
                    color: AppColors.orangePrimary.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Tickets',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            calculateTotalTickets().toString(),
                            key: ValueKey<int>(calculateTotalTickets()),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Price',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            'LKR ${NumberFormat('#,###').format(calculateTotalPrice())}',
                            key: ValueKey<double>(calculateTotalPrice()),
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.orangePrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Payment Button
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: calculateTotalTickets() > 0
                    ? ScaleTransition(
                  scale: _animationController,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: proceedToPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orangePrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                        shadowColor: AppColors.orangePrimary.withOpacity(0.3),
                      ),
                      child: Text(
                        'PROCEED TO PAYMENT',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                )
                    : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).hoverColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'SELECT TICKETS TO CONTINUE',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground(context),
      appBar: AppBar(
        systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        title: Text(
          'Event Details',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor(context),
          ),
        ),
        backgroundColor: AppColors.cardColor(context),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.orangePrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, size: 24),
            onPressed: () {
              // Share functionality
            },
          ),
        ],
      ),
      body: isLoading ? _buildShimmerLoading() : _buildEventDetails(),
    );
  }
}
=======
}
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
