import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:eventory/navigators/bottomnavigatorbar.dart';
import 'package:shimmer/shimmer.dart';
<<<<<<< HEAD
import 'package:eventory/helpers/theme_helper.dart'; // Added import
=======
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f

class Orders extends StatefulWidget {
  final String userId;

  const Orders({Key? key, required this.userId}) : super(key: key);

  @override
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final Map<String, Map<String, dynamic>> _eventCache = {};

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchEventDetails(String eventId) async {
    if (_eventCache.containsKey(eventId)) {
      return _eventCache[eventId]!;
    }

    try {
      DocumentSnapshot eventDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .get();

      final eventData = {
        'eventName': eventDoc['eventName'],
        'eventDate': eventDoc['selectedDateTime'].toDate(),
      };

      _eventCache[eventId] = eventData;
      return eventData;
    } catch (e) {
      return {
        'eventName': "Unknown Event",
        'eventDate': DateTime.now(),
      };
    }
  }

  Widget _buildShimmerCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
<<<<<<< HEAD
            color: AppColors.cardColor(context),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Shimmer.fromColors(
            baseColor: Theme.of(context).hoverColor!,
            highlightColor: Theme.of(context).highlightColor!,
=======
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 24,
<<<<<<< HEAD
                  color: AppColors.cardColor(context),
=======
                  color: Colors.white,
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                ),
                const SizedBox(height: 16),
                _buildShimmerRow(),
                _buildShimmerRow(),
                _buildShimmerRow(),
                _buildShimmerRow(),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
<<<<<<< HEAD
                    color: AppColors.cardColor(context),
=======
                    color: Colors.white,
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
<<<<<<< HEAD
            color: AppColors.cardColor(context),
=======
            color: Colors.white,
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 14,
<<<<<<< HEAD
                  color: AppColors.cardColor(context),
=======
                  color: Colors.white,
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  height: 16,
<<<<<<< HEAD
                  color: AppColors.cardColor(context),
=======
                  color: Colors.white,
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, Map<String, dynamic> eventDetails, int index) {
    bool isSold = order['isSold'] ?? false;
    DateTime eventDate = eventDetails['eventDate'];
    bool isExpired = eventDate.isBefore(DateTime.now());

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
<<<<<<< HEAD
              color: AppColors.cardColor(context),
              gradient: isExpired
                  ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.cardColor(context),
                  Colors.grey.withOpacity(0.1),
                ],
              )
                  : null,
              border: Border.all(
                color: isExpired
                    ? Theme.of(context).dividerColor
                    : Theme.of(context).dividerColor.withOpacity(0.5),
=======
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  isExpired ? Colors.grey[100]! : Colors.white,
                ],
              ),
              border: Border.all(
                color: isExpired
                    ? Colors.grey.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
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
                            eventDetails['eventName'],
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
<<<<<<< HEAD
                              color: isExpired
                                  ? Theme.of(context).hintColor
                                  : AppColors.textColor(context),
=======
                              color: isExpired ? Colors.grey : Colors.black87,
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
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
<<<<<<< HEAD
                              color: Colors.grey[700],
=======
                              color: Colors.grey[300],
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
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
                    _buildInfoRow(Icons.confirmation_number, 'Ticket ID', order['ticketId'].toString()),
                    _buildInfoRow(Icons.calendar_today, 'Event Date', DateFormat('EEE, MMM d, y').format(eventDate)),
                    _buildInfoRow(Icons.access_time, 'Event Time', DateFormat('h:mm a').format(eventDate)),
                    _buildInfoRow(Icons.attach_money, 'Original Price', 'LKR ${NumberFormat('#,###').format(order['originalPrice'])}'),
                    _buildInfoRow(Icons.sell, 'Listed Price', 'LKR ${NumberFormat('#,###').format(order['currentPrice'])}'),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSold
                              ? [Colors.red[400]!, Colors.red[600]!]
                              : [Colors.green[400]!, Colors.green[600]!],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          isSold ? 'SOLD' : 'AVAILABLE',
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
<<<<<<< HEAD
          Icon(icon, size: 20, color: AppColors.orangePrimary),
=======
          Icon(icon, size: 20, color: const Color(0xffFF611A)),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
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
<<<<<<< HEAD
                    color: Theme.of(context).hintColor,
=======
                    color: Colors.black54,
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
<<<<<<< HEAD
                    color: AppColors.textColor(context),
=======
                    color: Colors.black87,
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
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
    return Scaffold(
<<<<<<< HEAD
      backgroundColor: AppColors.scaffoldBackground(context),
      appBar: AppBar(
        systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
=======
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
        title: Text(
          'My Listings',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
<<<<<<< HEAD
            color: AppColors.textColor(context),
          ),
        ),
        backgroundColor: AppColors.cardColor(context),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.orangePrimary),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
=======
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xffFF611A)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
<<<<<<< HEAD
            icon: Icon(Icons.refresh, size: 28),
            color: AppColors.textColor(context),
=======
            icon: const Icon(Icons.refresh, size: 28),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
            onPressed: () {
              _animationController.reset();
              _animationController.forward();
              _eventCache.clear();
              setState(() {});
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('market')
            .where('userId', isEqualTo: widget.userId)
            .orderBy('expiryDate', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) => _buildShimmerCard(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
<<<<<<< HEAD
                    Icon(Icons.error_outline, color: Colors.red),
=======
                    const Icon(Icons.error_outline, color: Colors.red),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Error fetching listings: ${snapshot.error}",
                        style: GoogleFonts.poppins(
                          color: Colors.red[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
<<<<<<< HEAD
                    color: Theme.of(context).hintColor,
=======
                    color: Colors.grey[300],
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No Listings Found',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
<<<<<<< HEAD
                      color: Theme.of(context).hintColor,
=======
                      color: Colors.grey,
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'You haven\'t listed any tickets yet',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
<<<<<<< HEAD
                      color: Theme.of(context).hintColor,
=======
                      color: Colors.grey,
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                    ),
                  ),
                ],
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;
              return FutureBuilder<Map<String, dynamic>>(
                future: _fetchEventDetails(order['eventId']),
                builder: (context, eventSnapshot) {
                  if (eventSnapshot.connectionState == ConnectionState.waiting) {
                    return _buildShimmerCard();
                  }
                  if (eventSnapshot.hasError) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Text(
                        "Error loading event details",
                        style: GoogleFonts.poppins(
                          color: Colors.red[800],
                        ),
                      ),
                    );
                  }
                  return _buildOrderCard(order, eventSnapshot.data!, index);
                },
              );
            },
          );
        },
      ),
<<<<<<< HEAD
      bottomNavigationBar: BottomNavigatorBar(
        currentIndex: 1,
        userId: widget.userId,
      ),
=======
      bottomNavigationBar: BottomNavigatorBar(),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
    );
  }
}