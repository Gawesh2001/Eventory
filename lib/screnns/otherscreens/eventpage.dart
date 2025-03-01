// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:eventory/screnns/otherscreens/payments.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class EventPage extends StatefulWidget {
  final String eventId;

  const EventPage({super.key, required this.eventId});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  Map<String, dynamic>? eventData;
  Map<String, int> ticketCounts = {}; // Stores selected ticket counts

  @override
  void initState() {
    super.initState();
    fetchEventData();
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

  void proceedToPayment() async {
    double totalPrice = calculateTotalPrice();
    if (totalPrice == 0) return;

    // Fetch last booking ID from Firestore
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .orderBy('bookingId', descending: true)
        .limit(1)
        .get();

    DocumentSnapshot? lastBooking =
        snapshot.docs.isNotEmpty ? snapshot.docs.first : null;

    // Generate new booking ID (starting from 100001)
    int newBookingId =
        lastBooking == null ? 100001 : (lastBooking['bookingId'] as int) + 1;

    // Get user's email from Firestore
    String userEmail =
        "user@example.com"; // Use actual user's email from authentication

    // Send email to user about the booking
    await _sendConfirmationEmail(userEmail, newBookingId, totalPrice);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentsPage(
          bookingId: newBookingId,
          totalPrice: totalPrice.toInt(), // Ensure integer type for totalPrice
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
      recipients: [userEmail], // Send the email to the user
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
          title: Text("Event Details", style: TextStyle(color: Colors.orange)),
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.orange),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(eventData!['eventName'] ?? "Event Details",
            style: TextStyle(color: Colors.orange)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.orange),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
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
                )),
            SizedBox(height: 16),
            Text(eventData!['eventName'] ?? "No Event Name",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            SizedBox(height: 8),
            Text("Venue: ${eventData!['eventVenue'] ?? 'Unknown'}",
                style: TextStyle(fontSize: 18, color: Colors.grey)),
            Text("Location: ${eventData!['location'] ?? 'Unknown'}",
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 16),
            Text("Select Tickets",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            SizedBox(height: 10),
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
            SizedBox(height: 16),
            Text("Total Tickets: ${calculateTotalTickets()}",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Text("Total Price: LKR ${calculateTotalPrice().toStringAsFixed(2)}",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: proceedToPayment,
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  textStyle: TextStyle(fontSize: 18, color: Colors.white),
                  backgroundColor: Colors.orange),
              child: Center(
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
              style: TextStyle(fontSize: 16, color: Colors.white)),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () => updateTicketCount(key, -1),
              ),
              Text("${ticketCounts[key] ?? 0}",
                  style: TextStyle(fontSize: 16, color: Colors.white)),
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: Colors.green),
                onPressed: () => updateTicketCount(key, 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
