// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:eventory/screnns/otherscreens/payments.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class EventPage extends StatefulWidget {
  final String eventId;

  const EventPage({super.key, required this.eventId});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  Map<String, dynamic>? eventData;
  Map<String, int> ticketCounts = {};
  String? userEmail;
  String? userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEventData();
    fetchUserDetails();
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
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching event data: $e");
      setState(() => isLoading = false);
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
      if (lastTicketId is String) return int.tryParse(lastTicketId) ?? 1000;
    }
    return 1000;
  }

  void proceedToPayment() async {
    if (calculateTotalPrice() == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one ticket')),
      );
      return;
    }

    // Generate booking ID
    QuerySnapshot bookingSnapshot = await FirebaseFirestore.instance
        .collection('Bookings')
        .orderBy('bookingId', descending: true)
        .limit(1)
        .get();

    int newBookingId = bookingSnapshot.docs.isEmpty
        ? 100001
        : (bookingSnapshot.docs.first['bookingId'] as int) + 1;

    // Generate tickets
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
      await _sendConfirmationEmail(
          userEmail!, newBookingId, calculateTotalPrice());
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentsPage(
          totalPrice: calculateTotalPrice().toInt(),
          eventId: widget.eventId,
          totalTickets: calculateTotalTickets(),
          tickets: tickets,
          bookingId: newBookingId,
        ),
      ),
    );
  }

  Future<void> _sendConfirmationEmail(
      String userEmail, int bookingId, double totalPrice) async {
    final Email email = Email(
      body:
          'Thank you for booking!\n\nBooking ID: $bookingId\nEvent: ${eventData!['eventName']}\nTotal: LKR ${totalPrice.toStringAsFixed(2)}',
      subject: 'Booking Confirmation - ${eventData!['eventName']}',
      recipients: [userEmail],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (e) {
      print("Error sending email: $e");
    }
  }

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
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "LKR ${price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
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
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
