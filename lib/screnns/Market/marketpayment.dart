import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
<<<<<<< HEAD
import 'package:eventory/helpers/theme_helper.dart'; // Added import
=======
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f

class MarketPayment extends StatefulWidget {
  final String userId;
  final String ticketId;
  final String eventName;
  final int currentPrice;

  const MarketPayment({
    Key? key,
    required this.userId,
    required this.ticketId,
    required this.eventName,
    required this.currentPrice,
  }) : super(key: key);

  @override
  MarketPaymentState createState() => MarketPaymentState();
}

class MarketPaymentState extends State<MarketPayment> {
  final _cardNumberController = TextEditingController();
  final _expiryMonthController = TextEditingController();
  final _expiryYearController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isProcessing = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
          content: Row(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(width: 16),
<<<<<<< HEAD
              Text(
                'Processing payment...',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ],
          ),
          duration: Duration(seconds: 5),
          backgroundColor: AppColors.orangePrimary,
=======
              Text('Processing payment...'),
            ],
          ),
          duration: Duration(seconds: 5),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
        ),
      );

      // Simulate payment processing delay
      await Future.delayed(Duration(seconds: 2));

      // Update Firestore
      await _updateFirestore();

      // Show success message
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
<<<<<<< HEAD
          content: Text(
            'Payment successful!',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
=======
          content: Text('Payment successful!'),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate back after success
      await Future.delayed(Duration(seconds: 1));
      if (mounted) Navigator.of(context).pop();

    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
<<<<<<< HEAD
          content: Text(
            'Error: ${e.toString()}',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
=======
          content: Text('Error: ${e.toString()}'),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _updateFirestore() async {
    try {
      final int ticketId = int.parse(widget.ticketId);
      final marketQuery = await _firestore
          .collection('market')
          .where('ticketId', isEqualTo: ticketId)
          .limit(1)
          .get();

      if (marketQuery.docs.isEmpty) {
        throw Exception("Market document not found");
      }

      final marketDoc = marketQuery.docs.first;
      final ticketDoc = await _firestore.collection('Tickets').doc(widget.ticketId).get();
      if (!ticketDoc.exists) throw Exception("Ticket document not found");

      await _firestore.collection('market').doc(marketDoc.id).update({
        'buyerId': widget.userId,
        'isListed': false,
        'isSold': true,
      });

      await _firestore.collection('Tickets').doc(widget.ticketId).update({
        'userId': widget.userId,
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
        systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
=======
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
        title: Text(
          'Complete Payment',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
<<<<<<< HEAD
        backgroundColor: AppColors.orangePrimary,
=======
        backgroundColor: Color(0xffFF611A),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
<<<<<<< HEAD
        color: AppColors.scaffoldBackground(context),
=======
        color: Colors.grey[50],
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
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
<<<<<<< HEAD
              color: AppColors.cardColor(context),
=======
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
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
<<<<<<< HEAD
                        color: AppColors.textColor(context),
=======
                        color: Colors.black87,
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildSummaryRow('Ticket ID', widget.ticketId),
                    _buildSummaryRow('Event Name', widget.eventName),
<<<<<<< HEAD
                    Divider(height: 24, color: Theme.of(context).dividerColor),
=======
                    Divider(height: 24),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                    _buildSummaryRow(
                      'Total Amount',
                      'LKR ${NumberFormat('#,###').format(widget.currentPrice)}',
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Payment Details',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
<<<<<<< HEAD
                color: AppColors.textColor(context),
=======
                color: Colors.black87,
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
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
<<<<<<< HEAD
                context,
                label: 'Card Number',
                icon: Icons.credit_card,
              ),
              style: GoogleFonts.poppins(
                color: AppColors.textColor(context),
              ),
=======
                label: 'Card Number',
                icon: Icons.credit_card,
              ),
              style: GoogleFonts.poppins(),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
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
<<<<<<< HEAD
                    decoration: _buildInputDecoration(context, label: 'MM'),
                    style: GoogleFonts.poppins(
                      color: AppColors.textColor(context),
                    ),
=======
                    decoration: _buildInputDecoration(label: 'MM'),
                    style: GoogleFonts.poppins(),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
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
<<<<<<< HEAD
                    decoration: _buildInputDecoration(context, label: 'YY'),
                    style: GoogleFonts.poppins(
                      color: AppColors.textColor(context),
                    ),
=======
                    decoration: _buildInputDecoration(label: 'YY'),
                    style: GoogleFonts.poppins(),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
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
<<<<<<< HEAD
                      context,
                      label: 'CVV',
                      icon: Icons.lock_outline,
                    ),
                    style: GoogleFonts.poppins(
                      color: AppColors.textColor(context),
                    ),
=======
                      label: 'CVV',
                      icon: Icons.lock_outline,
                    ),
                    style: GoogleFonts.poppins(),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                  ),
                ),
              ],
            ),
            Spacer(),
            // Pay Now Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : () => _payWithCard(context),
                style: ElevatedButton.styleFrom(
<<<<<<< HEAD
                  backgroundColor: AppColors.orangePrimary,
=======
                  backgroundColor: Color(0xffFF611A),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
<<<<<<< HEAD
                  shadowColor: AppColors.orangePrimary.withOpacity(0.3),
=======
                  shadowColor: Color(0xffFF611A).withOpacity(0.3),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
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
<<<<<<< HEAD
              color: Theme.of(context).hintColor,
=======
              color: Colors.grey[600],
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
<<<<<<< HEAD
              color: isBold ? AppColors.orangePrimary : AppColors.textColor(context),
=======
              color: isBold ? Color(0xffFF611A) : Colors.black87,
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
            ),
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  InputDecoration _buildInputDecoration(BuildContext context, {required String label, IconData? icon}) {
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
        borderSide: BorderSide(
          color: AppColors.orangePrimary,
          width: 1.5,
        ),
=======
  InputDecoration _buildInputDecoration({required String label, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: icon != null ? Icon(icon, color: Colors.grey[600]) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xffFF611A), width: 1.5),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
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