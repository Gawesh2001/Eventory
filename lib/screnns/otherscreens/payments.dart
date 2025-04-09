// ignore_for_file: use_build_context_synchronously, unnecessary_import, library_private_types_in_public_api, depend_on_referenced_packages

import 'dart:typed_data';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
<<<<<<< HEAD
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:eventory/helpers/theme_helper.dart'; // Added import
=======
import 'package:qr_flutter/qr_flutter.dart'; // Import qr_flutter package
import 'package:path_provider/path_provider.dart'; // Required for saving files locally
import 'package:pdf/widgets.dart' as pw; // For PDF generation
import 'package:open_file/open_file.dart'; // For opening the downloaded PDF
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore
import 'package:mailer/mailer.dart'; // For sending emails
import 'package:mailer/smtp_server.dart'; // For SMTP server configuration
import 'package:flutter_dotenv/flutter_dotenv.dart'; // For loading .env file
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f

class PaymentsPage extends StatefulWidget {
  final int totalPrice;
  final String eventId;
  final int totalTickets;
<<<<<<< HEAD
  final List<Map<String, dynamic>> tickets;
=======
  final List<Map<String, dynamic>>
      tickets; // List of tickets with IDs and names
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
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
<<<<<<< HEAD
  bool _isProcessing = false;
=======
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f

  User? _user;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
<<<<<<< HEAD
    dotenv.load();
  }

  Future<void> _getCurrentUser() async {
=======
    dotenv.load(); // Load .env file
  }

  Future<void> _getCurrentUser() async {
    // Get current user from Firebase Authentication
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
    _user = FirebaseAuth.instance.currentUser;
    setState(() {});
  }

<<<<<<< HEAD
  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _payWithCard(BuildContext context) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.orangePrimary,
          content: Row(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(width: 16),
              Text(
                'Processing payment...',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ],
          ),
          duration: Duration(seconds: 5),
        ),
      );

      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Store booking details
      await _storeBookingDetails();
      await _uploadTickets();

      // Generate QR code
      final qrCodeBytes = await _generateQRCode(widget.bookingId, widget.eventId);

      // Hide loading indicator
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Show success and QR code
      await _showQRCodeDialog(context, qrCodeBytes);
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${e.toString()}',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
=======
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
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
    }
  }

  Future<void> _storeBookingDetails() async {
<<<<<<< HEAD
    if (_user == null) throw Exception("User is not authenticated.");

    await _firestore.collection('Bookings').doc(widget.bookingId.toString()).set({
=======
    if (_user == null) {
      throw Exception("User is not authenticated.");
    }

    // Store booking details in Firestore
    await _firestore
        .collection('Bookings')
        .doc(widget.bookingId.toString())
        .set({
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
      'bookingId': widget.bookingId,
      'eventId': widget.eventId,
      'totalTickets': widget.totalTickets,
      'totalPriceLKR': widget.totalPrice,
      'userId': _user!.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _uploadTickets() async {
<<<<<<< HEAD
    if (_user == null) throw Exception("User is not authenticated.");

    for (var ticket in widget.tickets) {
      await _firestore.collection('Tickets').doc(ticket['ticketId'].toString()).set({
=======
    if (_user == null) {
      throw Exception("User is not authenticated.");
    }

    // Upload each ticket to the Tickets collection
    for (var ticket in widget.tickets) {
      await _firestore
          .collection('Tickets')
          .doc(ticket['ticketId'].toString())
          .set({
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
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
<<<<<<< HEAD
    final qrData = "Booking ID: $bookingId, Event ID: $eventId";
=======
    // Combine bookingId and eventId into a single string for the QR code
    final qrData = "Booking ID: $bookingId, Event ID: $eventId";

    // Create a QrPainter instance for the QR code
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
    final qrPainter = QrPainter(
      data: qrData,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );

<<<<<<< HEAD
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromPoints(Offset(0, 0), Offset(200, 200)));
    qrPainter.paint(canvas, Size(200.0, 200.0));

    final picture = recorder.endRecording();
    final img = await picture.toImage(200, 200);
=======
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
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
    final byteData = await img.toByteData(format: ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

<<<<<<< HEAD
  Future<void> _showQRCodeDialog(BuildContext context, Uint8List qrCodeBytes) async {
=======
  Future<void> _showQRCodeDialog(
      BuildContext context, Uint8List qrCodeBytes) async {
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
<<<<<<< HEAD
          backgroundColor: AppColors.cardColor(context),
          title: Text(
            "Payment Successful!",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: AppColors.textColor(context),
            ),
          ),
=======
          title: const Text("QR Code Generated"),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
<<<<<<< HEAD
                data: "Booking ID: ${widget.bookingId}, Event ID: ${widget.eventId}",
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
              ),
              SizedBox(height: 20),
              Text(
                "Your booking is confirmed",
                style: GoogleFonts.poppins(
                  color: AppColors.textColor(context),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (_user != null) {
                        await _sendEmail(qrCodeBytes, _user!.email!);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "User is not authenticated.",
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orangePrimary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      "Send Email",
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await _downloadQRCodeAsPDF(qrCodeBytes);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).hintColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      "Download",
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                ],
=======
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
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _sendEmail(Uint8List qrCodeBytes, String email) async {
    try {
<<<<<<< HEAD
      final qrCodePath = await _saveQRCode(qrCodeBytes);
      final eventDoc = await _firestore.collection('events').doc(widget.eventId).get();
      if (!eventDoc.exists) throw Exception("Event not found.");
=======
      // Save the QR code and get the file path
      final qrCodePath = await _saveQRCode(qrCodeBytes);

      // Fetch event details from Firestore
      final eventDoc =
          await _firestore.collection('events').doc(widget.eventId).get();
      if (!eventDoc.exists) {
        throw Exception("Event not found.");
      }
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f

      final eventData = eventDoc.data() as Map<String, dynamic>;
      final eventName = eventData['eventName'];
      final eventVenue = eventData['eventVenue'];
      final imageUrl = eventData['imageUrl'];

<<<<<<< HEAD
=======
      // Load email credentials from .env
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
      final emailAddress = dotenv.get('EMAIL');
      final emailPassword = dotenv.get('EMAIL_PASSWORD');
      final smtpServer = dotenv.get('SMTP_SERVER');
      final smtpPort = int.parse(dotenv.get('SMTP_PORT'));

<<<<<<< HEAD
=======
      // Configure SMTP server
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
      final smtp = SmtpServer(
        smtpServer,
        port: smtpPort,
        username: emailAddress,
        password: emailPassword,
      );

<<<<<<< HEAD
=======
      // Create the email message
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
      final message = Message()
        ..from = Address(emailAddress, 'Event Booking System')
        ..recipients.add(email)
        ..subject = 'Booking Confirmation - ${widget.bookingId}'
        ..html = '''
          <h1>Booking Confirmation</h1>
          <p>Thank you for booking with us! Here are your booking details:</p>
<<<<<<< HEAD
          <p><img src="$imageUrl" alt="Event Image" width="200"></p>
=======
           <p><img src="$imageUrl" alt="Event Image" width="200"></p>
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
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

<<<<<<< HEAD
      await send(message, smtp);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Email sent to $email",
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error sending email: $e",
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
=======
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
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
      );
    }
  }

  Future<void> _downloadQRCodeAsPDF(Uint8List qrCodeBytes) async {
    try {
<<<<<<< HEAD
      final pdf = pw.Document();
=======
      // Create a PDF document
      final pdf = pw.Document();

      // Add a page with the QR code image
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
<<<<<<< HEAD
              child: pw.Image(pw.MemoryImage(qrCodeBytes)),
=======
              child: pw.Image(
                pw.MemoryImage(qrCodeBytes),
              ),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
            );
          },
        ),
      );

<<<<<<< HEAD
=======
      // Save the PDF to a file
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/booking_${widget.bookingId}_qr.pdf');
      await file.writeAsBytes(await pdf.save());

<<<<<<< HEAD
      OpenFile.open(file.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "QR code downloaded as PDF.",
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error downloading QR code: $e",
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
=======
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
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
      );
    }
  }

  Future<String> _saveQRCode(Uint8List qrCodeBytes) async {
<<<<<<< HEAD
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/booking_${widget.bookingId}_qr.png');
    await file.writeAsBytes(qrCodeBytes);
=======
    // Get the app's documents directory
    final directory = await getApplicationDocumentsDirectory();

    // Create a file and write the QR code bytes
    final file = File('${directory.path}/booking_${widget.bookingId}_qr.png');
    await file.writeAsBytes(qrCodeBytes);

    // Return the file path for email attachment
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
        systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        title: Text(
          'Complete Payment',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.orangePrimary,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: AppColors.scaffoldBackground(context),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: AppColors.cardColor(context),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor(context),
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildSummaryRow('Booking ID', widget.bookingId.toString()),
                    _buildSummaryRow('Total Tickets', widget.totalTickets.toString()),
                    Divider(height: 24, color: Theme.of(context).dividerColor),
                    _buildSummaryRow(
                      'Total Amount',
                      'LKR ${NumberFormat('#,###').format(widget.totalPrice)}',
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            // Tickets List
            Text(
              'Ticket Details',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor(context),
              ),
            ),
            SizedBox(height: 8),
=======
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
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
            Expanded(
              child: ListView.builder(
                itemCount: widget.tickets.length,
                itemBuilder: (context, index) {
                  final ticket = widget.tickets[index];
<<<<<<< HEAD
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    color: AppColors.cardColor(context),
                    child: ListTile(
                      title: Text(
                        ticket['ticketName'],
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColor(context),
                        ),
                      ),
                      subtitle: Text(
                        'ID: ${ticket['ticketId']}',
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      trailing: Text(
                        'LKR ${NumberFormat('#,###').format(ticket['ticketPrice'])}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: AppColors.orangePrimary,
                        ),
                      ),
=======
                  return ListTile(
                    title: Text(
                      "Ticket ID: ${ticket['ticketId']}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "Type: ${ticket['ticketName']}, Price: LKR ${ticket['ticketPrice']}",
                      style: const TextStyle(color: Colors.white70),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                    ),
                  );
                },
              ),
            ),
<<<<<<< HEAD
            SizedBox(height: 16),
            // Payment Details
            Text(
              'Payment Details',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor(context),
              ),
            ),
            SizedBox(height: 16),
            // Card Number Field
            TextFormField(
=======
            const SizedBox(height: 30),
            // Card Number Field
            TextField(
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
<<<<<<< HEAD
                CardNumberInputFormatter(),
              ],
              decoration: _buildInputDecoration(
                label: 'Card Number',
                icon: Icons.credit_card,
              ),
              style: GoogleFonts.poppins(
                color: AppColors.textColor(context),
              ),
            ),
            SizedBox(height: 16),
            // Expiry Date and CVV
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
=======
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
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                    controller: _expiryMonthController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
<<<<<<< HEAD
                    decoration: _buildInputDecoration(label: 'MM'),
                    style: GoogleFonts.poppins(
                      color: AppColors.textColor(context),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextFormField(
=======
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
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                    controller: _expiryYearController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
<<<<<<< HEAD
                    decoration: _buildInputDecoration(label: 'YY'),
                    style: GoogleFonts.poppins(
                      color: AppColors.textColor(context),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _cvvController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    decoration: _buildInputDecoration(
                      label: 'CVV',
                      icon: Icons.lock_outline,
                    ),
                    style: GoogleFonts.poppins(
                      color: AppColors.textColor(context),
=======
                    decoration: InputDecoration(
                      labelText: 'YY',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                    ),
                  ),
                ),
              ],
            ),
<<<<<<< HEAD
            SizedBox(height: 24),
            // Pay Now Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : () => _payWithCard(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orangePrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.orangePrimary.withOpacity(0.3),
                ),
                child: _isProcessing
                    ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    : Text(
                  'PAY NOW',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
=======
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
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
<<<<<<< HEAD

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Theme.of(context).hintColor,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              color: isBold ? AppColors.orangePrimary : AppColors.textColor(context),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String label, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: Theme.of(context).hintColor),
      filled: true,
      fillColor: AppColors.cardColor(context),
      prefixIcon: icon != null
          ? Icon(icon, color: Theme.of(context).hintColor)
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.orangePrimary, width: 1.5),
      ),
    );
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    var text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
=======
}
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
