import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'orders.dart';
import 'package:eventory/helpers/theme_helper.dart'; // Added import

class Sell extends StatefulWidget {
  final String userId;

  const Sell({Key? key, required this.userId}) : super(key: key);

  @override
  _SellState createState() => _SellState();
}

class _SellState extends State<Sell> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _sellPriceController = TextEditingController();
  List<Map<String, dynamic>> tickets = [];
  String? errorMessage;
  String selectedTicketType = "All";
  final List<String> ticketTypes = ["All", "normal", "vip", "special", "other"];
  bool isLoading = false;
  bool _priceError = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showWelcomeInfo = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTime();
    });
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final bool? seenBefore = prefs.getBool('seenSellPageInfo');

    if (seenBefore == null || !seenBefore) {
      await prefs.setBool('seenSellPageInfo', true);
      if (mounted) {
        setState(() {
          _showWelcomeInfo = true;
        });
        _showWelcomeDialog();
      }
    }
  }

  void _showWelcomeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: AppColors.cardColor(context),
          title: Text(
            'Welcome to Ticket Marketplace',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.orangePrimary,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Important Information:',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColor(context),
                  ),
                ),
                const SizedBox(height: 10),
                _buildInfoPoint(Icons.info_outline, 'Listing a ticket doesn\'t guarantee a sale'),
                _buildInfoPoint(Icons.schedule, 'If sold, payment will be processed within 5 business days'),
                _buildInfoPoint(Icons.event_busy, 'Tickets cannot be sold after the event date'),
                const SizedBox(height: 15),
                Text(
                  'By using this service, you agree to our Terms and Conditions.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Theme.of(context).hintColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'I UNDERSTAND',
                style: GoogleFonts.poppins(
                  color: AppColors.orangePrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoPoint(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.orangePrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  _searchTickets() async {
    setState(() {
      isLoading = true;
      tickets = [];
      errorMessage = null;
    });

    String searchText = _searchController.text.trim();
    if (searchText.isEmpty) {
      setState(() {
        errorMessage = "Please enter a booking ID or ticket ID";
        isLoading = false;
      });
      return;
    }

    int? searchId = int.tryParse(searchText);
    if (searchId == null) {
      setState(() {
        errorMessage = "Invalid ID. Please enter a number";
        isLoading = false;
      });
      return;
    }

    try {
      QuerySnapshot ticketDocs = await FirebaseFirestore.instance
          .collection('Tickets')
          .where('userId', isEqualTo: widget.userId)
          .where('bookingId', isEqualTo: searchId)
          .get();

      if (ticketDocs.docs.isEmpty) {
        ticketDocs = await FirebaseFirestore.instance
            .collection('Tickets')
            .where('userId', isEqualTo: widget.userId)
            .where('ticketId', isEqualTo: searchId)
            .get();
      }

      if (ticketDocs.docs.isNotEmpty) {
        List<Map<String, dynamic>> ticketList = [];
        for (var doc in ticketDocs.docs) {
          var ticket = doc.data() as Map<String, dynamic>;
          DocumentSnapshot eventDoc = await FirebaseFirestore.instance
              .collection('events')
              .doc(ticket['eventId'])
              .get();

          if (eventDoc.exists) {
            DateTime eventDate = eventDoc['selectedDateTime'].toDate();
            ticket['eventName'] = eventDoc['eventName'];
            ticket['eventDateTime'] = eventDate;
            ticket['isExpired'] = eventDate.isBefore(DateTime.now());

            // Check if ticket is already listed
            QuerySnapshot marketDocs = await FirebaseFirestore.instance
                .collection('market')
                .where('ticketId', isEqualTo: ticket['ticketId'])
                .get();

            if (marketDocs.docs.isNotEmpty) {
              var marketData = marketDocs.docs.first.data() as Map<String, dynamic>;
              ticket['isListed'] = marketData['isListed'] ?? false;
              ticket['isSold'] = marketData['isSold'] ?? false;
            } else {
              ticket['isListed'] = false;
              ticket['isSold'] = false;
            }

            ticketList.add(ticket);
          }
        }

        setState(() {
          tickets = ticketList;
          selectedTicketType = "All";
        });
      } else {
        setState(() {
          errorMessage = "No tickets found for this ID";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching ticket details";
      });
      print("Error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSellPopup(Map<String, dynamic> ticket) async {
    if (ticket['isExpired']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Cannot sell expired tickets"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _sellPriceController.clear();
    _priceError = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cardColor(context),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "List Ticket for Sale",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.orangePrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.confirmation_number, 'Ticket ID', ticket['ticketId'].toString()),
                    _buildInfoRow(Icons.event, 'Event', ticket['eventName']),
                    _buildInfoRow(Icons.calendar_today, 'Date', DateFormat('EEE, MMM d, y').format(ticket['eventDateTime'])),
                    _buildInfoRow(Icons.access_time, 'Time', DateFormat('h:mm a').format(ticket['eventDateTime'])),
                    const SizedBox(height: 16),
                    Divider(color: Theme.of(context).dividerColor),
                    const SizedBox(height: 16),
                    Text(
                      "Original Price: LKR ${NumberFormat('#,###').format(ticket['ticketPrice'])}",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor(context),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _sellPriceController,
                      decoration: InputDecoration(
                        labelText: "Your Selling Price",
                        labelStyle: GoogleFonts.poppins(
                          color: Theme.of(context).hintColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorText: _priceError ? "Price cannot exceed original" : null,
                        prefixText: "LKR ",
                        prefixStyle: GoogleFonts.poppins(
                          color: AppColors.textColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textColor(context),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        double? sellPrice = double.tryParse(value);
                        if (sellPrice != null && sellPrice > ticket['ticketPrice']) {
                          setState(() => _priceError = true);
                        } else {
                          setState(() => _priceError = false);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Note: Payment will be processed within 5 business days after sale",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Theme.of(context).hintColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "CANCEL",
                            style: GoogleFonts.poppins(
                              color: Theme.of(context).hintColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () async {
                            double sellPrice = double.tryParse(_sellPriceController.text) ?? 0;
                            if (sellPrice > ticket['ticketPrice']) {
                              setState(() => _priceError = true);
                              return;
                            }

                            if (sellPrice <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Please enter a valid price"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            await FirebaseFirestore.instance.collection('market').add({
                              'buyerId': null,
                              'currentPrice': sellPrice,
                              'eventId': ticket['eventId'],
                              'expiryDate': ticket['eventDateTime'],
                              'isListed': true,
                              'isSold': false,
                              'originalPrice': ticket['ticketPrice'],
                              'ticketId': ticket['ticketId'],
                              'userId': widget.userId,
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Ticket listed for sale!"),
                                backgroundColor: Colors.green,
                              ),
                            );

                            Navigator.pop(context);
                            _searchTickets();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orangePrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: Text(
                            "LIST TICKET",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.orangePrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _cancelListing(int ticketId) async {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: AppColors.cardColor(context),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 60,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                Text(
                  "Cancel Listing?",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor(context),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Are you sure you want to remove this ticket from the marketplace?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "NO",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () async {
                        QuerySnapshot marketDocs = await FirebaseFirestore.instance
                            .collection('market')
                            .where('ticketId', isEqualTo: ticketId)
                            .get();

                        if (marketDocs.docs.isNotEmpty) {
                          await FirebaseFirestore.instance
                              .collection('market')
                              .doc(marketDocs.docs.first.id)
                              .delete();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Listing canceled"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }

                        Navigator.pop(context);
                        _searchTickets();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orangePrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        "YES",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket, int index) {
    bool isExpired = ticket['isExpired'] ?? false;
    bool isListed = ticket['isListed'] ?? false;
    bool isSold = ticket['isSold'] ?? false;
    int hoursRemaining = ticket['eventDateTime'].difference(DateTime.now()).inHours;
    bool isUrgent = hoursRemaining < 24 && !isExpired;

    return AnimatedBuilder(
      animation: CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.1 * index, 1.0, curve: Curves.easeOut),
      ),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _animationController.value)),
          child: Opacity(
            opacity: _animationController.value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardColor(context),
              gradient: isUrgent
                  ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.cardColor(context),
                  AppColors.orangePrimary.withOpacity(0.1),
                ],
              )
                  : null,
              border: Border.all(
                color: isUrgent
                    ? AppColors.orangePrimary.withOpacity(0.2)
                    : isExpired
                    ? Colors.grey.withOpacity(0.2)
                    : Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            ticket['eventName'],
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: isExpired
                                  ? Theme.of(context).hintColor
                                  : AppColors.textColor(context),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isExpired)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[700],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'EXPIRED',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.confirmation_number, 'Ticket ID', ticket['ticketId'].toString()),
                    _buildInfoRow(Icons.category, 'Ticket Type', ticket['ticketName'] ?? 'General'),
                    _buildInfoRow(Icons.calendar_today, 'Date', DateFormat('EEE, MMM d, y').format(ticket['eventDateTime'])),
                    _buildInfoRow(Icons.access_time, 'Time', DateFormat('h:mm a').format(ticket['eventDateTime'])),
                    _buildInfoRow(Icons.attach_money, 'Price', 'LKR ${NumberFormat('#,###').format(ticket['ticketPrice'])}'),
                    const SizedBox(height: 12),
                    if (isExpired)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).hoverColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Event Expired',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                      )
                    else if (isSold)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green[400]!,
                              Colors.green[600]!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'SOLD',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    else if (isListed)
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {}, // Just for visual, no action
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal[600],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: Text(
                                  'LISTED',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _cancelListing(ticket['ticketId']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[600],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: Text(
                                  'CANCEL',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _showSellPopup(ticket),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.orangePrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              'SELL TICKET',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Shimmer.fromColors(
            baseColor: Theme.of(context).hoverColor!,
            highlightColor: Theme.of(context).highlightColor!,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.cardColor(context),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredTickets = selectedTicketType == "All"
        ? tickets
        : tickets.where((ticket) => ticket['ticketName'] == selectedTicketType).toList();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground(context),
      appBar: AppBar(
        systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        title: Text(
          'Sell Tickets',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor(context),
          ),
        ),
        backgroundColor: AppColors.cardColor(context),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.orangePrimary),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, size: 28),
            color: AppColors.orangePrimary,
            onPressed: () {
              _animationController.reset();
              _searchTickets().then((_) {
                _animationController.forward();
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.receipt_long, size: 28),
            color: AppColors.orangePrimary,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Orders(userId: widget.userId)),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(30),
              shadowColor: AppColors.orangePrimary.withOpacity(0.2),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: AppColors.cardColor(context),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: _searchController,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppColors.textColor(context),
                          ),
                          decoration: InputDecoration(
                            hintText: "Enter Ticket ID or Booking Id",
                            hintStyle: GoogleFonts.poppins(
                              color: Theme.of(context).hintColor,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.orangePrimary,
                            Color(0xffFF9349),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: _searchTickets,
                          child: Center(
                            child: Icon(Icons.search, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ticketTypes
                    .map((filter) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      filter,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: selectedTicketType == filter
                            ? Colors.white
                            : AppColors.orangePrimary,
                      ),
                    ),
                    selected: selectedTicketType == filter,
                    selectedColor: AppColors.orangePrimary,
                    backgroundColor: AppColors.cardColor(context),
                    shape: StadiumBorder(
                      side: BorderSide(color: AppColors.orangePrimary),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        selectedTicketType = selected ? filter : 'All';
                      });
                    },
                  ),
                ))
                    .toList(),
              ),
            ),
          ),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: GoogleFonts.poppins(
                          color: Colors.red[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: isLoading
                ? _buildShimmerLoading()
                : filteredTickets.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    size: 80,
                    color: Theme.of(context).hintColor,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No tickets found',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Try searching with a different ID',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: filteredTickets.length,
              itemBuilder: (context, index) {
                return _buildTicketCard(filteredTickets[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }
}