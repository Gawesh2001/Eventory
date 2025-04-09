import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventory/screnns/Market/sell.dart';
import 'package:eventory/navigators/bottomnavigatorbar.dart';
import 'marketpayment.dart';
import 'package:intl/intl.dart';
import 'package:eventory/helpers/theme_helper.dart'; // Added import

class Market extends StatefulWidget {
  final String userId;

  const Market({Key? key, required this.userId}) : super(key: key);

  @override
  _MarketState createState() => _MarketState();
}

class _MarketState extends State<Market> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool isLoading = false;
  String? errorMessage;
  List<Map<String, dynamic>> marketListings = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedSort = 'Recent';
  final List<String> _sortOptions = ['Recent', 'Price: Low to High', 'Price: High to Low', 'Date: Soonest'];

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
    _fetchMarketListings();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchMarketListings() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      QuerySnapshot marketDocs = await FirebaseFirestore.instance
          .collection('market')
          .where('isListed', isEqualTo: true)
          .where('isSold', isEqualTo: false)
          .where('userId', isNotEqualTo: widget.userId)
          .get();

      List<Map<String, dynamic>> listings = [];
      for (var doc in marketDocs.docs) {
        var marketData = doc.data() as Map<String, dynamic>;
        DocumentSnapshot eventDoc = await FirebaseFirestore.instance
            .collection('events')
            .doc(marketData['eventId'])
            .get();

        if (eventDoc.exists) {
          var eventData = eventDoc.data() as Map<String, dynamic>;
          DateTime eventDate = eventData['selectedDateTime'].toDate();
          int daysUntilEvent = eventDate.difference(DateTime.now()).inDays;

          // Skip expired events (daysUntilEvent < 0)
          if (daysUntilEvent >= 0) {
            listings.add({
              ...marketData,
              'eventName': eventData['eventName'],
              'eventPhoto': eventData['eventPhoto'],
              'selectedDateTime': eventDate,
              'docId': doc.id,
            });
          }
        }
      }

      setState(() {
        marketListings = listings;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching market listings: ${e.toString()}";
      });
      print("Error fetching market listings: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _filterAndSortListings() {
    List<Map<String, dynamic>> filtered = marketListings.where((listing) {
      final eventName = listing['eventName'].toString().toLowerCase();
      final ticketId = listing['ticketId'].toString().toLowerCase();
      return eventName.contains(_searchQuery) || ticketId.contains(_searchQuery);
    }).toList();

    switch (_selectedSort) {
      case 'Price: Low to High':
        filtered.sort((a, b) => a['currentPrice'].compareTo(b['currentPrice']));
        break;
      case 'Price: High to Low':
        filtered.sort((a, b) => b['currentPrice'].compareTo(a['currentPrice']));
        break;
      case 'Date: Soonest':
        filtered.sort((a, b) => a['selectedDateTime'].compareTo(b['selectedDateTime']));
        break;
      case 'Recent':
      default:
        break;
    }

    return filtered;
  }

  Widget _buildMarketCard(Map<String, dynamic> listing, int index) {
    final eventDate = listing['selectedDateTime'];
    final daysUntilEvent = eventDate.difference(DateTime.now()).inDays;
    final discountPercentage = ((listing['originalPrice'] - listing['currentPrice']) /
        listing['originalPrice'] * 100).round();

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
              gradient: daysUntilEvent < 7
                  ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.cardColor(context),
                  AppColors.orangePrimary.withOpacity(0.1),
                ],
              )
                  : null,
            ),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: listing['eventPhoto']['url'],
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Theme.of(context).hoverColor,
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.orangePrimary),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Theme.of(context).hoverColor,
                          child: Icon(Icons.error, color: AppColors.textColor(context)),
                        ),
                      ),
                      if (daysUntilEvent < 7)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.orangePrimary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'SOON: ${daysUntilEvent}d',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${discountPercentage}% OFF',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing['eventName'],
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor(context),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              "LKR ${NumberFormat('#,###').format(listing['currentPrice'])}",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.orangePrimary,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              "LKR ${NumberFormat('#,###').format(listing['originalPrice'])}",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Theme.of(context).hintColor,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 18,
                                color: Theme.of(context).hintColor),
                            SizedBox(width: 8),
                            Text(
                              DateFormat('EEE, MMM d • h:mm a').format(eventDate),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.confirmation_number,
                                size: 18,
                                color: Theme.of(context).hintColor),
                            SizedBox(width: 8),
                            Text(
                              "Ticket ID: ${listing['ticketId']}",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MarketPayment(
                                    userId: widget.userId,
                                    ticketId: listing['ticketId'].toString(),
                                    eventName: listing['eventName'],
                                    currentPrice: listing['currentPrice'].toInt(),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.orangePrimary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14),
                              elevation: 4,
                              shadowColor: AppColors.orangePrimary.withOpacity(0.3),
                            ),
                            child: Text(
                              "BUY NOW",
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredListings = _filterAndSortListings();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground(context),
      appBar: AppBar(
        systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        title: Text(
          'Ticket Marketplace',
          style: GoogleFonts.poppins(
            fontSize: 22,
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
              _fetchMarketListings().then((_) {
                _animationController.forward();
              });
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
                            hintText: "Search events or ticket IDs...",
                            hintStyle: GoogleFonts.poppins(
                              color: Theme.of(context).hintColor,
                            ),
                            border: InputBorder.none,
                            icon: Icon(Icons.search,
                                color: AppColors.orangePrimary),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.toLowerCase();
                            });
                          },
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: _searchQuery.isNotEmpty ? 100 : 60,
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
                          onTap: () {
                            setState(() {
                              _searchQuery = _searchController.text.toLowerCase();
                            });
                          },
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: Duration(milliseconds: 300),
                              child: _searchQuery.isNotEmpty
                                  ? Text(
                                'SEARCH',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              )
                                  : Icon(Icons.search, color: Colors.white),
                            ),
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
            child: Row(
              children: [
                Icon(Icons.sort, color: AppColors.orangePrimary),
                SizedBox(width: 8),
                Text(
                  'Sort by:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColor(context),
                  ),
                ),
                SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedSort,
                  icon: Icon(Icons.arrow_drop_down,
                      color: AppColors.orangePrimary),
                  underline: Container(),
                  style: GoogleFonts.poppins(
                    color: AppColors.textColor(context),
                    fontSize: 14,
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedSort = newValue!;
                    });
                  },
                  items: _sortOptions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
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
                          AppColors.orangePrimary),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Loading Market Listings',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            )
                : filteredListings.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.markunread_mailbox_outlined,
                    size: 80,
                    color: Theme.of(context).hintColor,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No listings available',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Check back later or list your own tickets',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: filteredListings.length,
              itemBuilder: (context, index) {
                return _buildMarketCard(filteredListings[index], index);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Sell(userId: widget.userId),
              fullscreenDialog: true,
            ),
          ).then((_) => _fetchMarketListings());
        },
        backgroundColor: AppColors.orangePrimary,
        elevation: 6,
        child: Icon(Icons.add, size: 32),
      ),
      bottomNavigationBar: BottomNavigatorBar(
        currentIndex: 1,
        userId: widget.userId,
      ),
    );
  }
}