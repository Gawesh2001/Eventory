import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eventory/helpers/theme_helper.dart';

class Expired extends StatefulWidget {
  final String userId;

  const Expired({Key? key, required this.userId}) : super(key: key);

  @override
  _ExpiredState createState() => _ExpiredState();
}

class _ExpiredState extends State<Expired> with SingleTickerProviderStateMixin {
  bool isLoading = false;
  String? errorMessage;
  List<Map<String, dynamic>> expiredTickets = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _fetchExpiredTickets();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchExpiredTickets() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      QuerySnapshot ticketsSnapshot = await FirebaseFirestore.instance
          .collection('Tickets')
          .where('userId', isEqualTo: widget.userId)
          .get();

      List<Map<String, dynamic>> tickets = [];
      for (var doc in ticketsSnapshot.docs) {
        var ticketData = doc.data() as Map<String, dynamic>;
        DocumentSnapshot eventDoc = await FirebaseFirestore.instance
            .collection('events')
            .doc(ticketData['eventId'])
            .get();

        if (eventDoc.exists) {
          var eventData = eventDoc.data() as Map<String, dynamic>;
          bool isMarketplace = await _checkIfMarketplaceTicket(ticketData['ticketId'].toString());
          DateTime eventDateTime = eventData['selectedDateTime'].toDate();
          bool isExpired = eventDateTime.isBefore(DateTime.now());

          if (isExpired) {
            tickets.add({
              ...ticketData,
              'eventName': eventData['eventName'],
              'selectedDateTime': eventDateTime,
              'isMarketplace': isMarketplace,
            });
          }
        }
      }

      setState(() {
        expiredTickets = tickets;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching expired tickets: ${e.toString()}";
      });
      print("Error fetching expired tickets: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<bool> _checkIfMarketplaceTicket(String ticketId) async {
    try {
      num? ticketIdNum = num.tryParse(ticketId);
      if (ticketIdNum == null) return false;

      QuerySnapshot marketSnapshot = await FirebaseFirestore.instance
          .collection('market')
          .where('ticketId', isEqualTo: ticketIdNum)
          .where('buyerId', isEqualTo: widget.userId)
          .where('isSold', isEqualTo: true)
          .limit(1)
          .get();

      return marketSnapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error checking marketplace ticket: $e");
      return false;
    }
  }

  Widget _buildExpiredTicketCard(Map<String, dynamic> ticket, int index) {
    var ticketId = ticket['ticketId'];
    var ticketName = ticket['ticketName'] ?? 'General';
    var eventName = ticket['eventName'];
    var eventDateTime = ticket['selectedDateTime'];
    bool isMarketplace = ticket['isMarketplace'] ?? false;
    var daysPassed = DateTime.now().difference(eventDateTime).inDays;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: BoxDecoration(
              gradient: isDarkMode
                  ? null
                  : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey[100]!,
                  Colors.grey[200]!,
                ],
              ),
              color: isDarkMode ? AppColors.cardColor(context) : null,
              border: Border.all(
                color: isDarkMode
                    ? Theme.of(context).dividerColor
                    : Colors.grey[300]!,
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
                            eventName,
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode
                                  ? AppColors.textColor(context).withOpacity(0.7)
                                  : Colors.black87,
                              decoration: TextDecoration.lineThrough,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isMarketplace)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  isDarkMode
                                      ? AppColors.orangePrimary
                                      : Color(0xffFF611A),
                                  Color(0xffFF9349),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: (isDarkMode
                                      ? AppColors.orangePrimary
                                      : Color(0xffFF611A)).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              'MARKETPLACE',
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
                    SizedBox(height: 16),
                    _buildInfoRow(Icons.confirmation_number, 'Ticket ID', ticketId.toString()),
                    _buildInfoRow(Icons.category, 'Ticket Type', ticketName),
                    _buildInfoRow(Icons.calendar_today, 'Date', DateFormat('EEE, MMM d, y').format(eventDateTime)),
                    _buildInfoRow(Icons.access_time, 'Time', DateFormat('h:mm a').format(eventDateTime)),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.grey[800]!.withOpacity(0.3)
                            : Colors.grey[300]!.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.grey[700]!.withOpacity(0.2)
                              : Colors.grey[400]!.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Event Status',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode
                                  ? Theme.of(context).hintColor
                                  : Colors.black54,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.red[200]!,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning_amber_rounded,
                                    size: 16,
                                    color: Colors.red[700]),
                                SizedBox(width: 6),
                                Text(
                                  'EXPIRED ${daysPassed}d AGO',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.red[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              size: 20,
              color: isDarkMode
                  ? AppColors.orangePrimary
                  : Colors.grey[600]),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode
                        ? Theme.of(context).hintColor
                        : Colors.black54,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode
                        ? AppColors.textColor(context).withOpacity(0.8)
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppColors.scaffoldBackground(context)
          : Colors.grey[50],
      appBar: AppBar(
        systemOverlayStyle: isDarkMode
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        title: Text(
          'Expired Tickets',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: isDarkMode
                ? AppColors.textColor(context)
                : Colors.black87,
          ),
        ),
        backgroundColor: isDarkMode
            ? AppColors.cardColor(context)
            : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
            color: isDarkMode
                ? AppColors.orangePrimary
                : Color(0xffFF611A)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, size: 28),
            color: isDarkMode
                ? AppColors.textColor(context)
                : Color(0xffFF611A),
            onPressed: () {
              _animationController.reset();
              _fetchExpiredTickets().then((_) {
                _animationController.forward();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red),
                    SizedBox(width: 12),
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
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 6,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          isDarkMode
                              ? AppColors.orangePrimary
                              : Color(0xffFF611A)),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Loading Expired Tickets',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode
                          ? Theme.of(context).hintColor
                          : Colors.black54,
                    ),
                  ),
                ],
              ),
            )
                : expiredTickets.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_outlined,
                    size: 80,
                    color: isDarkMode
                        ? Theme.of(context).hintColor
                        : Colors.grey[300],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No expired tickets',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode
                          ? Theme.of(context).hintColor
                          : Colors.grey,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'All your tickets are still valid',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDarkMode
                          ? Theme.of(context).hintColor
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: expiredTickets.length,
              itemBuilder: (context, index) {
                return _buildExpiredTicketCard(expiredTickets[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }
}