import 'dart:typed_data';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart'; // Required for saving files locally
import 'package:flutter_email_sender/flutter_email_sender.dart'; // Required for sending emails
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth to get the user email

class PaymentsPage extends StatefulWidget {
  final int bookingId;
  final int totalPrice;

  const PaymentsPage(
      {super.key, required this.bookingId, required this.totalPrice});

  @override
  _PaymentsPageState createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final _cardNumberController = TextEditingController();
  final _expiryMonthController = TextEditingController();
  final _expiryYearController = TextEditingController();
  final _cvvController = TextEditingController();
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    _getUserEmail();
  }

  Future<void> _getUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email ?? '';
      });
    }
  }

  Future<void> _payWithCard(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      // Simulate a delay for payment processing
      await Future.delayed(Duration(seconds: 2));

      // Close loading indicator
      Navigator.of(context).pop();

      // Generate QR code
      final qrCodeBytes = await _generateQRCode(widget.bookingId);

      // Send email with QR code as an attachment
      if (userEmail.isNotEmpty) {
        await _sendEmail(qrCodeBytes);
      } else {
        throw Exception("User email is not available.");
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment successful! Email sent to $userEmail")),
      );
    } catch (e) {
      // Close loading indicator
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<Uint8List> _generateQRCode(int bookingId) async {
    // Create a QrPainter instance for the QR code
    final qrPainter = QrPainter(
      data: bookingId.toString(),
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

  Future<String> _saveQRCode(Uint8List qrCodeBytes) async {
    // Get the app's documents directory
    final directory = await getApplicationDocumentsDirectory();

    // Create a file and write the QR code bytes
    final file = File('${directory.path}/booking_${widget.bookingId}_qr.png');
    await file.writeAsBytes(qrCodeBytes);

    // Return the file path for email attachment
    return file.path;
  }

  Future<void> _sendEmail(Uint8List qrCodeBytes) async {
    final Email email = Email(
      body: 'Here is your booking QR code.',
      subject: 'Booking Confirmation - ${widget.bookingId}',
      recipients: [userEmail], // Use dynamic user email
      attachmentPaths: [await _saveQRCode(qrCodeBytes)],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);

      // Show confirmation message after email is sent
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email sent to $userEmail")),
      );
    } catch (e) {
      // If sending email fails, show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending email: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.grey[900],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display user email at the top of the screen
            Text(
              "User Email: $userEmail",
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            SizedBox(height: 8),
            // Booking ID and Total Amount
            Text(
              "Booking ID: ${widget.bookingId}",
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            SizedBox(height: 8),
            Text(
              "Total Amount: \$${widget.totalPrice}",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 30),
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
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
                prefixIcon: Icon(Icons.credit_card,
                    color: const Color.fromARGB(255, 255, 255, 255)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),

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
                      labelStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 10),
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
                      labelStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

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
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
                prefixIcon: Icon(Icons.lock,
                    color: const Color.fromARGB(255, 241, 241, 241)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 30),

            // Spacer to push the button to the bottom
            Spacer(),

            // Proceed Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _payWithCard(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Proceed to Pay",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
