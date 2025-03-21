// ignore_for_file: use_build_context_synchronously, unnecessary_import, library_private_types_in_public_api, depend_on_referenced_packages

import 'dart:typed_data';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Import qr_flutter package
import 'package:path_provider/path_provider.dart'; // Required for saving files locally
import 'package:pdf/widgets.dart' as pw; // For PDF generation
import 'package:open_file/open_file.dart'; // For opening the downloaded PDF
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore
import 'package:mailer/mailer.dart'; // For sending emails
import 'package:mailer/smtp_server.dart'; // For SMTP server configuration
import 'package:flutter_dotenv/flutter_dotenv.dart'; // For loading .env file

class PaymentsPage extends StatefulWidget {
  final int totalPrice;
  final String eventId;
  final int totalTickets;
  final List<Map<String, dynamic>>
      tickets; // List of tickets with IDs and names
  final int bookingId;

  const PaymentsPage({
    super.key,
    required this.totalPrice,
    required this.eventId,
    required this.totalTickets,
    required this.tickets,
    required this.bookingId,
  });

  @override
  _PaymentsPageState createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final _cardNumberController = TextEditingController();
  final _expiryMonthController = TextEditingController();
  final _expiryYearController = TextEditingController();
  final _cvvController = TextEditingController();

  User? _user;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    dotenv.load(); // Load .env file
  }

  Future<void> _getCurrentUser() async {
    // Get current user from Firebase Authentication
    _user = FirebaseAuth.instance.currentUser;
    setState(() {});
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

      // Store booking details in Firestore
      await _storeBookingDetails();

      // Upload tickets to Firestore
      await _uploadTickets();

      // Generate QR code with eventId and bookingId
      final qrCodeBytes =
          await _generateQRCode(widget.bookingId, widget.eventId);

      // Close loading indicator
      Navigator.of(context).pop();

      // Show dialog to display QR code and send email
      await _showQRCodeDialog(context, qrCodeBytes);
    } catch (e) {
      // Close loading indicator
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _storeBookingDetails() async {
    if (_user == null) {
      throw Exception("User is not authenticated.");
    }

    // Store booking details in Firestore
    await _firestore
        .collection('Bookings')
        .doc(widget.bookingId.toString())
        .set({
      'bookingId': widget.bookingId,
      'eventId': widget.eventId,
      'totalTickets': widget.totalTickets,
      'totalPriceLKR': widget.totalPrice,
      'userId': _user!.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _uploadTickets() async {
    if (_user == null) {
      throw Exception("User is not authenticated.");
    }

    // Upload each ticket to the Tickets collection
    for (var ticket in widget.tickets) {
      await _firestore
          .collection('Tickets')
          .doc(ticket['ticketId'].toString())
          .set({
        'ticketId': ticket['ticketId'],
        'ticketName': ticket['ticketName'],
        'ticketPrice': ticket['ticketPrice'],
        'bookingId': widget.bookingId,
        'eventId': widget.eventId,
        'userId': _user!.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<Uint8List> _generateQRCode(int bookingId, String eventId) async {
    // Combine bookingId and eventId into a single string for the QR code
    final qrData = "Booking ID: $bookingId, Event ID: $eventId";

    // Create a QrPainter instance for the QR code
    final qrPainter = QrPainter(
      data: qrData,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );

    // Create a PictureRecorder to record the drawing
    final recorder = PictureRecorder();
    final canvas =
        Canvas(recorder, Rect.fromPoints(Offset(0, 0), Offset(200, 200)));

    // Paint the QR code
    qrPainter.paint(canvas, Size(200.0, 200.0));

    // End the recording and convert to an image
    final picture = recorder.endRecording();
    final img = await picture.toImage(200, 200);

    // Convert the image to bytes
    final byteData = await img.toByteData(format: ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _showQRCodeDialog(
      BuildContext context, Uint8List qrCodeBytes) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("QR Code Generated"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data:
                    "Booking ID: ${widget.bookingId}, Event ID: ${widget.eventId}",
                version: QrVersions.auto,
                size: 200,
              ),
              const SizedBox(height: 20),
              const Text("Screenshot this or download."),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_user != null) {
                    await _sendEmail(qrCodeBytes, _user!.email!);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("User is not authenticated.")),
                    );
                  }
                },
                child: const Text("Send Email"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _downloadQRCodeAsPDF(qrCodeBytes);
                },
                child: const Text("Download QR Code"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _sendEmail(Uint8List qrCodeBytes, String email) async {
    try {
      // Save the QR code and get the file path
      final qrCodePath = await _saveQRCode(qrCodeBytes);

      // Fetch event details from Firestore
      final eventDoc =
          await _firestore.collection('events').doc(widget.eventId).get();
      if (!eventDoc.exists) {
        throw Exception("Event not found.");
      }

      final eventData = eventDoc.data() as Map<String, dynamic>;
      final eventName = eventData['eventName'];
      final eventVenue = eventData['eventVenue'];
      final imageUrl = eventData['imageUrl'];

      // Load email credentials from .env
      final emailAddress = dotenv.get('EMAIL');
      final emailPassword = dotenv.get('EMAIL_PASSWORD');
      final smtpServer = dotenv.get('SMTP_SERVER');
      final smtpPort = int.parse(dotenv.get('SMTP_PORT'));

      // Configure SMTP server
      final smtp = SmtpServer(
        smtpServer,
        port: smtpPort,
        username: emailAddress,
        password: emailPassword,
      );

      // Create the email message
      final message = Message()
        ..from = Address(emailAddress, 'Event Booking System')
        ..recipients.add(email)
        ..subject = 'Booking Confirmation - ${widget.bookingId}'
        ..html = '''
          <h1>Booking Confirmation</h1>
          <p>Thank you for booking with us! Here are your booking details:</p>
           <p><img src="$imageUrl" alt="Event Image" width="200"></p>
          <p><strong>Event Name:</strong> $eventName</p>
          <p><strong>Event Venue:</strong> $eventVenue</p>
          <p><strong>Total Tickets:</strong> ${widget.totalTickets}</p>
          <p><strong>Total Price:</strong> LKR ${widget.totalPrice}.00</p>
          <p><strong>Booking ID:</strong> ${widget.bookingId}</p>
          <p>Here is your QR code for the event:</p>
          <img src="cid:qrCode" alt="QR Code" width="200" height="200">
        '''
        ..attachments = [
          FileAttachment(File(qrCodePath))..cid = 'qrCode',
        ];

      // Send the email
      await send(message, smtp);

      // Show confirmation message after email is sent
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email sent to $email")),
      );
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending email: $e")),
      );
    }
  }

  Future<void> _downloadQRCodeAsPDF(Uint8List qrCodeBytes) async {
    try {
      // Create a PDF document
      final pdf = pw.Document();

      // Add a page with the QR code image
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(
                pw.MemoryImage(qrCodeBytes),
              ),
            );
          },
        ),
      );

      // Save the PDF to a file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/booking_${widget.bookingId}_qr.pdf');
      await file.writeAsBytes(await pdf.save());

      // Open the PDF file
      OpenFile.open(file.path);

      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("QR code downloaded as PDF.")),
      );
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error downloading QR code: $e")),
      );
    }
  }

  Future<String> _saveQRCode(Uint8List qrCodeBytes) async {
    // Get the app's documents directory
    final directory = await getApplicationDocumentsDirectory();

    // Create a file and write the QR code bytes
    final file = File('${directory.path}/booking_${widget.bookingId}_qr.png');
    await file.writeAsBytes(qrCodeBytes);

    // Return the file path for email attachment
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.grey[900],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking ID and Total Amount
            Text(
              "Booking ID: ${widget.bookingId}",
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              "Total Amount: LKR ${widget.totalPrice}.00",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            // Display Ticket IDs
            const Text(
              "Ticket IDs:",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.tickets.length,
                itemBuilder: (context, index) {
                  final ticket = widget.tickets[index];
                  return ListTile(
                    title: Text(
                      "Ticket ID: ${ticket['ticketId']}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "Type: ${ticket['ticketName']}, Price: LKR ${ticket['ticketPrice']}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            // Card Number Field
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
                prefixIcon: const Icon(Icons.credit_card,
                    color: Color.fromARGB(255, 255, 255, 255)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Expiry Date Fields
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
            // CVV Field
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
            // Pay Button
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
