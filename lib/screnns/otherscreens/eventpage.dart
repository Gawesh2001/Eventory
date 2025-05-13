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
import 'package:eventory/helpers/theme_helper.dart';

class EventPage extends StatefulWidget {
  final String eventId;

  const EventPage({super.key, required this.eventId});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? eventData;
  Map<String, int> ticketCounts = {};
  Map<String, int> availableTickets = {};
  String? userEmail;
  String? userId;
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
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
    fetchEventData();
    fetchUserDetails();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchEventData() async {
    try {
      DocumentSnapshot eventDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .get();

      if (eventDoc.exists) {
        setState(() {
          eventData = eventDoc.data() as Map<String, dynamic>;
          // Initialize available tickets from the event data
          if (eventData!.containsKey('availableTickets')) {
            availableTickets =
                Map<String, int>.from(eventData!['availableTickets']);
          } else {
            // Fallback to individual ticket count fields if availableTickets doesn't exist
            availableTickets = {
              'Normal': eventData!['normalTicketCount'] ?? 0,
              'VIP': eventData!['vipTicketCount'] ?? 0,
              'Special': eventData!['specialTicketCount'] ?? 0,
              'Other': eventData!['otherTicketCount'] ?? 0,
            };
          }
        });
      }
    } catch (e) {
      print("Error fetching event data: $e");
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() => isLoading = false);
        _animationController.forward();
      }
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
    ticketCounts.forEach((key, value) {
      String priceKey = '${key.toLowerCase()}TicketPrice';
      if (eventData!.containsKey(priceKey)) {
        total += (eventData![priceKey] is int
                ? eventData![priceKey].toDouble()
                : eventData![priceKey]) *
            value;
      }
    });
    return total;
  }

  int calculateTotalTickets() {
    return ticketCounts.values.fold(0, (prev, curr) => prev + curr);
  }

  void updateTicketCount(String ticketType, int change) {
    setState(() {
      final currentCount = ticketCounts[ticketType] ?? 0;
      final newCount = currentCount + change;
      final availableCount = availableTickets[ticketType] ?? 0;

      if (newCount >= 0 && newCount <= availableCount) {
        ticketCounts[ticketType] = newCount;
      } else if (newCount < 0) {
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
      if (lastTicketId is String) {
        final parsedId = int.tryParse(lastTicketId);
        if (parsedId != null) return parsedId;
      }
    }
    return 1000;
  }

  Future<void> updateAvailableTickets() async {
    try {
      // Create a map of the tickets being purchased
      Map<String, int> purchasedTickets = {};
      ticketCounts.forEach((type, count) {
        if (count > 0) {
          purchasedTickets[type] = count;
        }
      });

      // Update the available tickets in Firestore
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .update({
        'availableTickets': {
          'Normal': (availableTickets['Normal'] ?? 0) -
              (purchasedTickets['Normal'] ?? 0),
          'VIP':
              (availableTickets['VIP'] ?? 0) - (purchasedTickets['VIP'] ?? 0),
          'Special': (availableTickets['Special'] ?? 0) -
              (purchasedTickets['Special'] ?? 0),
          'Other': (availableTickets['Other'] ?? 0) -
              (purchasedTickets['Other'] ?? 0),
        }
      });
    } catch (e) {
      print("Error updating available tickets: $e");
      throw e;
    }
  }

  void proceedToPayment() async {
    if (calculateTotalTickets() == 0) return;

    // Animation feedback
    _animationController.reset();
    await _animationController.forward();

    // Payment processing logic...
    double totalPrice = calculateTotalPrice();

    QuerySnapshot bookingSnapshot = await FirebaseFirestore.instance
        .collection('Bookings')
        .orderBy('bookingId', descending: true)
        .limit(1)
        .get();

    DocumentSnapshot? lastBooking =
        bookingSnapshot.docs.isNotEmpty ? bookingSnapshot.docs.first : null;

    int newBookingId =
        lastBooking == null ? 100001 : (lastBooking['bookingId'] as int) + 1;

    int lastTicketId = await getLastTicketId();
    List<Map<String, dynamic>> tickets = [];

    // Create ticket entries for each ticket type and count
    for (var entry in ticketCounts.entries) {
      if (entry.value > 0) {
        for (int i = 0; i < entry.value; i++) {
          lastTicketId++;
          tickets.add({
            'ticketId': lastTicketId,
            'ticketName': entry.key,
            'ticketPrice': eventData!['${entry.key.toLowerCase()}TicketPrice'],
            'bookingId': newBookingId,
            'eventId': widget.eventId,
            'userId': userId,
            'ticketCount': entry.value, // Add ticket count to each ticket
          });
        }
      }
    }

    if (userEmail != null) {
      await _sendConfirmationEmail(userEmail!, newBookingId, totalPrice);
    }

    // Update available tickets before navigating to payment page
    await updateAvailableTickets();

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => PaymentsPage(
          totalPrice: totalPrice.toInt(),
          eventId: widget.eventId,
          totalTickets: calculateTotalTickets(),
          tickets: tickets,
          bookingId: newBookingId,
          ticketCounts: Map.from(ticketCounts), // Pass the ticket counts map
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  Future<void> _sendConfirmationEmail(
      String userEmail, int bookingId, double totalPrice) async {
    final Email email = Email(
      body:
          'Thank you for booking! Your booking ID is: $bookingId\nTotal Price: LKR ${totalPrice.toStringAsFixed(2)}',
      subject: 'Booking Confirmation - $bookingId',
      recipients: [userEmail],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (e) {
      print("Error sending email: $e");
    }
  }

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
                    color: Colors.white,
                  ),
                ),
              ),
            ),
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
      ),
    );
  }

  Widget _buildTicketSelector(String label, String ticketType, int index) {
    final priceKey = '${ticketType.toLowerCase()}TicketPrice';
    final availableCount = availableTickets[ticketType] ?? 0;
    final selectedCount = ticketCounts[ticketType] ?? 0;
    final isOutOfStock = availableCount <= 0;

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
              color: isOutOfStock
                  ? Theme.of(context).hoverColor!.withOpacity(0.5)
                  : AppColors.cardColor(context),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: isOutOfStock
                    ? Colors.grey.withOpacity(0.3)
                    : AppColors.orangePrimary.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isOutOfStock
                                ? Theme.of(context).hintColor
                                : AppColors.textColor(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'LKR ${NumberFormat('#,###').format(eventData![priceKey])}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: isOutOfStock
                                ? Colors.grey
                                : AppColors.orangePrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    if (!isOutOfStock)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: AppColors.orangePrimary, size: 28),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              updateTicketCount(ticketType, -1);
                            },
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              '$selectedCount',
                              key: ValueKey<int>(selectedCount),
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
                              updateTicketCount(ticketType, 1);
                            },
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isOutOfStock ? 'Sold Out' : 'Available: $availableCount',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color:
                        isOutOfStock ? Colors.red : Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
                            valueColor:
                                AlwaysStoppedAnimation(AppColors.orangePrimary),
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Theme.of(context).hoverColor,
                        child: Icon(Icons.error,
                            color: Theme.of(context).hintColor),
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
                    _buildTicketSelector("Standard Ticket", "Normal", 0),
                  if (eventData!['vipTicketPrice'] != null)
                    _buildTicketSelector("VIP Ticket", "VIP", 1),
                  if (eventData!['specialTicketPrice'] != null)
                    _buildTicketSelector("Special Ticket", "Special", 2),
                  if (eventData!['otherTicketPrice'] != null)
                    _buildTicketSelector("Other Ticket", "Other", 3),
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
                              shadowColor:
                                  AppColors.orangePrimary.withOpacity(0.3),
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
