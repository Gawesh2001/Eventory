// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:eventory/screnns/otherscreens/payments.dart'; // Adjust the import path as needed
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventPage extends StatefulWidget {
  final String eventId;

  const EventPage({super.key, required this.eventId});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  Map<String, dynamic>? eventData;
  Map<String, int> ticketCounts = {}; // Stores selected ticket counts
  String? userEmail;
  String? userId; // Store the user ID

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
        });
      }
    } catch (e) {
      print("Error fetching event data: $e");
    }
  }

  Future<void> fetchUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email; // Fetch the user's email
        userId = user.uid; // Fetch the user ID
      });
    } else {
      print("No user is logged in.");
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

      // Handle both int and String types for ticketId
      if (lastTicketId is int) {
        return lastTicketId; // Return the last ticket ID
      } else if (lastTicketId is String) {
        // If ticketId is stored as a String, parse it to int
        final parsedId = int.tryParse(lastTicketId);
        if (parsedId != null) {
          return parsedId; // Return the parsed ticket ID
        }
      }
    }

    // Default starting ticket ID if no tickets exist
    return 1000;
  }

  void proceedToPayment() async {
    double totalPrice = calculateTotalPrice();
    if (totalPrice == 0) return;

    // Fetch last booking ID from Firestore
    QuerySnapshot bookingSnapshot = await FirebaseFirestore.instance
        .collection('Bookings')
        .orderBy('bookingId', descending: true)
        .limit(1)
        .get();

    DocumentSnapshot? lastBooking =
        bookingSnapshot.docs.isNotEmpty ? bookingSnapshot.docs.first : null;

    // Generate new booking ID (starting from 100001)
    int newBookingId =
        lastBooking == null ? 100001 : (lastBooking['bookingId'] as int) + 1;

    // Fetch last ticket ID from Firestore
    int lastTicketId = await getLastTicketId();
    List<Map<String, dynamic>> tickets = [];

    // Generate ticket IDs and store them in a list
    for (var entry in ticketCounts.entries) {
      if (entry.value > 0) {
        for (int i = 0; i < entry.value; i++) {
          lastTicketId++;
          tickets.add({
            'ticketId': lastTicketId, // Use the incremented ticket ID
            'ticketName':
                entry.key.replaceAll("TicketPrice", ""), // Add ticket name
            'ticketPrice': eventData![entry.key], // Add ticket price
            'bookingId': newBookingId,
            'eventId': widget.eventId,
            'userId': userId,
          });
        }
      }
    }

    if (userEmail != null) {
      // Send email to user about the booking
      await _sendConfirmationEmail(userEmail!, newBookingId, totalPrice);
    }

    // Pass the booking ID, tickets, and other details to the PaymentsPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentsPage(
          totalPrice: totalPrice.toInt(),
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

  @override
  Widget build(BuildContext context) {
    if (eventData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Event Details",
              style: TextStyle(color: Colors.orange)),
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.orange),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(eventData!['eventName'] ?? "Event Details",
            style: const TextStyle(color: Colors.orange)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.orange),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                eventData!['imageUrl'] ?? "",
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(eventData!['eventName'] ?? "No Event Name",
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 8),
            Text("Venue: ${eventData!['eventVenue'] ?? 'Unknown'}",
                style: const TextStyle(fontSize: 18, color: Colors.grey)),
            Text("Location: ${eventData!['location'] ?? 'Unknown'}",
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 16),
            const Text("Select Tickets",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 10),
            Column(
              children: [
                if (eventData!['normalTicketPrice'] != null)
                  ticketSelector("Normal Ticket", "normalTicketPrice"),
                if (eventData!['otherTicketPrice'] != null)
                  ticketSelector("Other Ticket", "otherTicketPrice"),
                if (eventData!['specialTicketPrice'] != null)
                  ticketSelector("Special Ticket", "specialTicketPrice"),
                if (eventData!['vipTicketPrice'] != null)
                  ticketSelector("VIP Ticket", "vipTicketPrice"),
              ],
            ),
            const SizedBox(height: 16),
            Text("Total Tickets: ${calculateTotalTickets()}",
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Text("Total Price: LKR ${calculateTotalPrice().toStringAsFixed(2)}",
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green)),
            const SizedBox(height: 20),
            if (userId != null)
              Text(
                "User ID: $userId",
                style: const TextStyle(color: Colors.white),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: proceedToPayment,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 18, color: Colors.white),
                  backgroundColor: Colors.orange),
              child: const Center(
                  child: Text(
                "Book Ticket",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget ticketSelector(String label, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$label (LKR ${eventData![key]})",
              style: const TextStyle(fontSize: 16, color: Colors.white)),
          Row(
            children: [
              IconButton(
                icon:
                    const Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () => updateTicketCount(key, -1),
              ),
              Text("${ticketCounts[key] ?? 0}",
                  style: const TextStyle(fontSize: 16, color: Colors.white)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                onPressed: () => updateTicketCount(key, 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
