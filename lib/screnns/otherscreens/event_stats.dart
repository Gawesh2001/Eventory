import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventory/helpers/theme_helper.dart';

class EventStats extends StatefulWidget {
  final String userId;

  const EventStats({Key? key, required this.userId}) : super(key: key);

  @override
  _EventStatsState createState() => _EventStatsState();
}

class _EventStatsState extends State<EventStats> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<Map<String, dynamic>> _events = [];
  Map<String, double> _revenueMap = {};
  Map<String, int> _ticketsSoldMap = {};
  StreamSubscription? _eventsSubscription;
  StreamSubscription? _bookingsSubscription;

  @override
  void initState() {
    super.initState();
    _setupRealTimeUpdates();
    _fetchEvents();
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    _bookingsSubscription?.cancel();
    super.dispose();
  }

  void _setupRealTimeUpdates() {
    // Listen for changes in events collection
    _eventsSubscription = _firestore
        .collection('events')
        .where('userId', isEqualTo: widget.userId)
        .where('condi', isEqualTo: 'yes')
        .snapshots()
        .listen((event) {
      _fetchEvents(); // Refresh when events change
    });

    // Listen for changes in bookings collection
    _bookingsSubscription = _firestore
        .collection('Bookings')
        .where('userId', isEqualTo: widget.userId)
        .snapshots()
        .listen((event) {
      _fetchEvents(); // Refresh when bookings change
    });
  }

  Future<void> _fetchEvents() async {
    try {
      setState(() {
        _isLoading = true;
      });

      QuerySnapshot eventsSnapshot = await _firestore
          .collection('events')
          .where('userId', isEqualTo: widget.userId)
          .where('condi', isEqualTo: 'yes')
          .get();

      List<Map<String, dynamic>> events = [];
      for (var doc in eventsSnapshot.docs) {
        var eventData = doc.data() as Map<String, dynamic>;
        eventData['id'] = doc.id;
        events.add(eventData);
        await _calculateEventStats(eventData['eventID']);
      }

      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching events: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _calculateEventStats(String eventId) async {
    try {
      QuerySnapshot bookingsSnapshot = await _firestore
          .collection('Bookings')
          .where('eventId', isEqualTo: eventId)
          .get();

      double totalRevenue = 0;
      int totalTickets = 0;

      for (var bookingDoc in bookingsSnapshot.docs) {
        var bookingData = bookingDoc.data() as Map<String, dynamic>;
        totalRevenue += (bookingData['totalPriceLKR'] as num).toDouble();
        totalTickets += (bookingData['totalTickets'] as num).toInt();
      }

      setState(() {
        _revenueMap[eventId] = totalRevenue;
        _ticketsSoldMap[eventId] = totalTickets;
      });
    } catch (e) {
      print("Error calculating stats for event $eventId: $e");
    }
  }

  Future<void> _cancelEvent(String eventId) async {
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 60,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                Text(
                  "Cancel Event?",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Are you sure you want to cancel this event? This action cannot be undone.",
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
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteEvent(eventId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        "YES, CANCEL",
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

  Future<void> _deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).update({
        'condi': 'no',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Event cancelled successfully'),
          backgroundColor: Colors.green,
        ),
      );

      await _fetchEvents();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel event: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildStatsHeader() {
    double totalRevenue =
        _revenueMap.values.fold(0, (sum, value) => sum + value);
    int totalTickets =
        _ticketsSoldMap.values.fold(0, (sum, value) => sum + value);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: AppColors.cardColor(context),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'YOUR EVENT STATS',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Theme.of(context).hintColor,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  Icons.event,
                  'Events',
                  _events.length.toString(),
                ),
                _buildStatItem(
                  Icons.confirmation_number,
                  'Tickets Sold',
                  totalTickets.toString(),
                ),
                _buildStatItem(
                  Icons.attach_money,
                  'Total Revenue',
                  'LKR ${NumberFormat('#,###').format(totalRevenue)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.orangePrimary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 24,
            color: AppColors.orangePrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor(context),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Theme.of(context).hintColor,
          ),
        ),
      ],
    );
  }

  Widget _buildEventList() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.orangePrimary),
        ),
      );
    }

    if (_events.isEmpty) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event,
                size: 60,
                color: Theme.of(context).hintColor,
              ),
              const SizedBox(height: 16),
              Text(
                'No events listed',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _events.length,
      itemBuilder: (context, index) {
        var event = _events[index];
        DateTime eventDate = (event['selectedDateTime'] as Timestamp).toDate();
        String eventId = event['eventID'];
        double revenue = _revenueMap[eventId] ?? 0;
        int ticketsSold = _ticketsSoldMap[eventId] ?? 0;

        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  imageUrl: event['imageUrl'],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Theme.of(context).hoverColor,
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Theme.of(context).hoverColor,
                    child: const Icon(Icons.error),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            event['eventName'],
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: AppColors.orangePrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            DateFormat('MMM d').format(eventDate),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 20,
                          color: Theme.of(context).hintColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            event['eventVenue'],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMiniStatItem(
                          'Tickets Sold',
                          ticketsSold.toString(),
                        ),
                        _buildMiniStatItem(
                          'Revenue',
                          'LKR ${NumberFormat('#,###').format(revenue)}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _cancelEvent(event['id']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'Cancel Event',
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor(context),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Event Listings',
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
            icon: Icon(Icons.refresh),
            onPressed: _fetchEvents,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatsHeader(),
            const SizedBox(height: 24),
            _buildEventList(),
          ],
        ),
      ),
    );
  }
}
