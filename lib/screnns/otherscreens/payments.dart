// ignore_for_file: use_build_context_synchronously, unnecessary_import, library_private_types_in_public_api, depend_on_referenced_packages

import 'dart:typed_data';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:eventory/helpers/theme_helper.dart';

class PaymentsPage extends StatefulWidget {
  final int totalPrice;
  final String eventId;
  final int totalTickets;
  final List<Map<String, dynamic>> tickets;
  final int bookingId;
  final Map<String, int> ticketCounts; // Added ticket counts map

  const PaymentsPage({
    super.key,
    required this.totalPrice,
    required this.eventId,
    required this.totalTickets,
    required this.tickets,
    required this.bookingId,
    required this.ticketCounts, // Added to constructor
  });

  @override
  _PaymentsPageState createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final _cardNumberController = TextEditingController();
  final _expiryMonthController = TextEditingController();
  final _expiryYearController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isProcessing = false;

  User? _user;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    dotenv.load();
  }

  Future<void> _getCurrentUser() async {
    _user = FirebaseAuth.instance.currentUser;
    setState(() {});
  }

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
      final qrCodeBytes =
          await _generateQRCode(widget.bookingId, widget.eventId);

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
    }
  }

  Future<void> _storeBookingDetails() async {
    if (_user == null) throw Exception("User is not authenticated.");

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
      'ticketCounts': widget.ticketCounts, // Store ticket counts
    });
  }

  Future<void> _uploadTickets() async {
    if (_user == null) throw Exception("User is not authenticated.");

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
        'ticketCount': ticket['ticketCount'], // Store ticket count
      });
    }
  }

  Future<Uint8List> _generateQRCode(int bookingId, String eventId) async {
    final qrData = "Booking ID: $bookingId, Event ID: $eventId";
    final qrPainter = QrPainter(
      data: qrData,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );

    final recorder = PictureRecorder();
    final canvas =
        Canvas(recorder, Rect.fromPoints(Offset(0, 0), Offset(200, 200)));
    qrPainter.paint(canvas, Size(200.0, 200.0));

    final picture = recorder.endRecording();
    final img = await picture.toImage(200, 200);
    final byteData = await img.toByteData(format: ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _showQRCodeDialog(
      BuildContext context, Uint8List qrCodeBytes) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardColor(context),
          title: Text(
            "Payment Successful!",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: AppColors.textColor(context),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data:
                    "Booking ID: ${widget.bookingId}, Event ID: ${widget.eventId}",
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
              ),
              SizedBox(height: 20),
              // Display ticket counts summary
              ...widget.ticketCounts.entries.map((entry) {
                if (entry.value > 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${entry.key} Tickets:',
                          style: GoogleFonts.poppins(
                            color: AppColors.textColor(context),
                          ),
                        ),
                        Text(
                          '${entry.value}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: AppColors.orangePrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return SizedBox.shrink();
              }).toList(),
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
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _sendEmail(Uint8List qrCodeBytes, String email) async {
    try {
      final qrCodePath = await _saveQRCode(qrCodeBytes);
      final eventDoc =
          await _firestore.collection('events').doc(widget.eventId).get();
      if (!eventDoc.exists) throw Exception("Event not found.");

      final eventData = eventDoc.data() as Map<String, dynamic>;
      final eventName = eventData['eventName'];
      final eventVenue = eventData['eventVenue'];
      final imageUrl = eventData['imageUrl'];

      final emailAddress = dotenv.get('EMAIL');
      final emailPassword = dotenv.get('EMAIL_PASSWORD');
      final smtpServer = dotenv.get('SMTP_SERVER');
      final smtpPort = int.parse(dotenv.get('SMTP_PORT'));

      final smtp = SmtpServer(
        smtpServer,
        port: smtpPort,
        username: emailAddress,
        password: emailPassword,
      );

      // Build ticket counts HTML
      String ticketCountsHtml = '';
      widget.ticketCounts.forEach((type, count) {
        if (count > 0) {
          ticketCountsHtml += '<p><strong>$type Tickets:</strong> $count</p>';
        }
      });

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
          $ticketCountsHtml
          <p><strong>Total Tickets:</strong> ${widget.totalTickets}</p>
          <p><strong>Total Price:</strong> LKR ${widget.totalPrice}.00</p>
          <p><strong>Booking ID:</strong> ${widget.bookingId}</p>
          <p>Here is your QR code for the event:</p>
          <img src="cid:qrCode" alt="QR Code" width="200" height="200">
        '''
        ..attachments = [
          FileAttachment(File(qrCodePath))..cid = 'qrCode',
        ];

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
      );
    }
  }

  Future<void> _downloadQRCodeAsPDF(Uint8List qrCodeBytes) async {
    try {
      final pdf = pw.Document();

      // Add ticket counts to the PDF
      final ticketCountsText = widget.ticketCounts.entries
          .where((entry) => entry.value > 0)
          .map((entry) => '${entry.key}: ${entry.value}')
          .join('\n');

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Center(
                  child: pw.Image(pw.MemoryImage(qrCodeBytes)),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Booking ID: ${widget.bookingId}',
                  style: pw.TextStyle(fontSize: 16),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Ticket Counts:',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(ticketCountsText),
              ],
            );
          },
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/booking_${widget.bookingId}_qr.pdf');
      await file.writeAsBytes(await pdf.save());

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
      );
    }
  }

  Future<String> _saveQRCode(Uint8List qrCodeBytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/booking_${widget.bookingId}_qr.png');
    await file.writeAsBytes(qrCodeBytes);
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                    // Display ticket counts in summary
                    ...widget.ticketCounts.entries.map((entry) {
                      if (entry.value > 0) {
                        return _buildSummaryRow(
                          '${entry.key} Tickets',
                          entry.value.toString(),
                        );
                      }
                      return SizedBox.shrink();
                    }).toList(),
                    _buildSummaryRow(
                        'Total Tickets', widget.totalTickets.toString()),
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
            Expanded(
              child: ListView.builder(
                itemCount: widget.tickets.length,
                itemBuilder: (context, index) {
                  final ticket = widget.tickets[index];
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
                        'ID: ${ticket['ticketId']} (Qty: ${ticket['ticketCount']})',
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
                    ),
                  );
                },
              ),
            ),
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
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
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
                    controller: _expiryMonthController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
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
                    controller: _expiryYearController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
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
                    ),
                  ),
                ),
              ],
            ),
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
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              color: isBold
                  ? AppColors.orangePrimary
                  : AppColors.textColor(context),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(
      {required String label, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: Theme.of(context).hintColor),
      filled: true,
      fillColor: AppColors.cardColor(context),
      prefixIcon:
          icon != null ? Icon(icon, color: Theme.of(context).hintColor) : null,
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
