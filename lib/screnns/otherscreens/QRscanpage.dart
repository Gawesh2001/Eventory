// ignore_for_file: file_names, library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  String? qrCodeResult;
  Map<String, dynamic>? bookingDetails;
  Map<String, dynamic>? eventDetails;
  bool isLoading = false;

  // Function to handle the detection of QR code
  void _onQRCodeDetect(Barcode barcode) {
    String? code = barcode.rawValue;
    if (code != null) {
      setState(() {
        qrCodeResult = code; // Store the detected QR code value
      });
      _fetchBookingAndEventDetails(
          code); // Fetch the details based on the QR code
    }
  }

  // Function to fetch details from Firestore
  Future<void> _fetchBookingAndEventDetails(String code) async {
    setState(() {
      isLoading = true; // Set loading state to true
    });

    try {
      // Split the QR code result into bookingId and eventId
      List<String> ids = code.split(',');
      if (ids.length < 2) {
        print("Invalid QR code format");
        return;
      }
      String bookingId = ids[0];
      String eventId = ids[1];

      // Fetch booking details from Firestore
      DocumentSnapshot bookingSnapshot = await FirebaseFirestore.instance
          .collection('Bookings')
          .doc(bookingId)
          .get();

      if (bookingSnapshot.exists) {
        bookingDetails = bookingSnapshot.data() as Map<String, dynamic>;

        // Fetch event details from Firestore
        DocumentSnapshot eventSnapshot = await FirebaseFirestore.instance
            .collection('Events')
            .doc(eventId)
            .get();

        if (eventSnapshot.exists) {
          eventDetails = eventSnapshot.data() as Map<String, dynamic>;
        }
      }
    } catch (e) {
      print("Error fetching details: $e");
    } finally {
      setState(() {
        isLoading = false; // Set loading state to false after fetching the data
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Scanner'),
      ),
      body: Column(
        children: [
          // MobileScanner to scan QR code
          Expanded(
            flex: 4,
            child: MobileScanner(
              controller: cameraController,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  _onQRCodeDetect(barcode); // Detect the QR code and process it
                }
              },
            ),
          ),
          // Show loading indicator or display booking & event details
          Expanded(
            flex: 3,
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : bookingDetails != null && eventDetails != null
                    ? _buildDetailsContainer()
                    : Center(child: Text('Scan a QR code to get details')),
          ),
        ],
      ),
    );
  }

  // Widget to build the details container with fetched information
  Widget _buildDetailsContainer() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Booking ID: ${bookingDetails!['bookingId']}'),
          Text('Event ID: ${bookingDetails!['eventId']}'),
          Text('Total Price LKR: ${bookingDetails!['totalPriceLKR']}'),
          Text('Total Tickets: ${bookingDetails!['totalTickets']}'),
          Text('User ID: ${bookingDetails!['userId']}'),
          SizedBox(height: 16),
          Text('Event Name: ${eventDetails!['eventName']}'),
          Image.network(eventDetails!['imageUrl']),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Handle the "GO IN" button press
              print("GO IN button pressed");
            },
            child: Text('GO IN'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose(); // Dispose the camera controller
    super.dispose();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Scanner App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QRScannerScreen(),
    );
  }
}

void main() {
  runApp(MyApp());
}
