import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart'; // Import for FilteringTextInputFormatter and LengthLimitingTextInputFormatter

class MarketPayment extends StatefulWidget {
  final String userId;
  final String ticketId; // Use ticketId instead of marketId
  final String eventId;
  final int currentPrice;

  const MarketPayment({
    Key? key,
    required this.userId,
    required this.ticketId, // Use ticketId instead of marketId
    required this.eventId,
    required this.currentPrice,
  }) : super(key: key);

  @override
  MarketPaymentState createState() => MarketPaymentState(); // Remove underscore to make it public
}

class MarketPaymentState extends State<MarketPayment> {
  final _cardNumberController = TextEditingController();
  final _expiryMonthController = TextEditingController();
  final _expiryYearController = TextEditingController();
  final _cvvController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _payWithCard(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Simulate a delay for payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Update Firestore
      await _updateFirestore(context);

      // Close loading indicator
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show success popup
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ticket Bought!")),
        );
      }
    } catch (e) {
      // Close loading indicator
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  Future<void> _updateFirestore(BuildContext context) async {
    try {
      debugPrint("Checking Firestore for ticketId: ${widget.ticketId}");

      // Convert ticketId from String to int
      final int ticketId = int.parse(widget.ticketId);

      // Query the market collection to find the document where ticketId matches
      final marketQuery = await _firestore
          .collection('market')
          .where('ticketId', isEqualTo: ticketId) // Use int for ticketId
          .limit(1) // Limit to 1 document since ticketId should be unique
          .get();

      // Check if the document exists
      if (marketQuery.docs.isEmpty) {
        throw Exception("Market document not found for ticketId: ${widget.ticketId}");
      }

      // Get the document reference
      final marketDoc = marketQuery.docs.first;
      final marketDocId = marketDoc.id; // Get the random document ID

      // Check if the ticketId exists in the Tickets collection
      final ticketDoc = await _firestore.collection('Tickets').doc(widget.ticketId).get();
      if (!ticketDoc.exists) {
        throw Exception("Ticket document not found for ticketId: ${widget.ticketId}");
      }

      // Check if the eventId exists in the events collection
      final eventDoc = await _firestore.collection('events').doc(widget.eventId).get();
      if (!eventDoc.exists) {
        throw Exception("Event document not found for eventId: ${widget.eventId}");
      }

      // Update market collection using the random document ID
      await _firestore.collection('market').doc(marketDocId).update({
        'buyerId': widget.userId,
        'isListed': false,
        'isSold': true,
      });

      // Update tickets collection using ticketId
      await _firestore.collection('Tickets').doc(widget.ticketId).update({
        'userId': widget.userId,
      });

      debugPrint("Database updates completed for ticketId: ${widget.ticketId}");
    } catch (e) {
      debugPrint("Error updating Firestore: $e");
      rethrow; // Rethrow the error to handle it in _payWithCard
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Market Payment", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.grey[900],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Ticket ID: ${widget.ticketId}", // Display ticketId
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              "Total Amount: LKR ${widget.currentPrice}.00", // Display total
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
              ],
              decoration: InputDecoration(
                labelText: 'Card Number',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
                prefixIcon: const Icon(Icons.credit_card, color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expiryMonthController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    decoration: InputDecoration(
                      labelText: 'MM',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _expiryYearController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    decoration: InputDecoration(
                      labelText: 'YY',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cvvController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              decoration: InputDecoration(
                labelText: 'CVV',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
                prefixIcon: const Icon(Icons.lock, color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () => _payWithCard(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Pay Now',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}