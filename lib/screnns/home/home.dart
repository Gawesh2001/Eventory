<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:eventory/navigators/mainlayout.dart';
import 'package:eventory/screnns/otherscreens/eventpage.dart';
import 'package:eventory/screnns/otherscreens/userprofile.dart';
import 'package:eventory/navigators/bottomnavigatorbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventory/helpers/theme_helper.dart';
=======
// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventory/navigators/mainlayout.dart';
import 'package:eventory/screnns/otherscreens/eventpage.dart';
import 'package:eventory/screnns/otherscreens/userprofile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eventory/navigators/bottomnavigatorbar.dart';
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String selectedCategory = 'All';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
<<<<<<< HEAD
  bool _showWelcomePopup = false;
  final PageController _featuredEventsController = PageController(viewportFraction: 0.85);
  List<QueryDocumentSnapshot> _allEvents = [];
  bool _isLoading = true;
  final List<String> categories = ['All', 'Music', 'Theater', 'Sport', 'Movie', 'Orchestral', 'Carnival'];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _checkAndShowWelcomePopup();
  }

  Future<void> _loadInitialData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('condi', isEqualTo: 'yes')
          .get();

      setState(() {
        _allEvents = snapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkAndShowWelcomePopup() async {
    final prefs = await SharedPreferences.getInstance();
    final bool shouldShowWelcome = prefs.getBool('showWelcomeAfterLogin') ?? true;

    if (shouldShowWelcome) {
      await prefs.setBool('showWelcomeAfterLogin', false);
      if (mounted) {
        setState(() {
          _showWelcomePopup = true;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_showWelcomePopup) {
            _showWelcomeDialog();
          }
        });
      }
    }
  }

  void _showWelcomeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: AppColors.cardColor(context),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.confirmation_number,
                size: 80,
                color: AppColors.orangePrimary,
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Welcome to Eventory!',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.orangePrimary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Discover amazing events near you. Get tickets instantly and never miss out on your favorite experiences.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.textColor(context)?.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orangePrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    shadowColor: AppColors.orangePrimary.withOpacity(0.3),
                  ),
                  child: Text(
                    'GET STARTED',
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
    ).then((_) {
      setState(() {
        _showWelcomePopup = false;
      });
    });
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

=======
  String? dpUrl;

  // Get filtered events stream based on category
  Stream<QuerySnapshot> getFilteredStream() {
    if (selectedCategory == 'All') {
      return FirebaseFirestore.instance
          .collection('events')
          .where('condi', isEqualTo: 'yes')
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('events')
          .where('condi', isEqualTo: 'yes')
          .where('selectedCategory', isEqualTo: selectedCategory)
          .snapshots();
    }
  }

  // Get search results - Fixed implementation
  Stream<QuerySnapshot> getSearchResults(String query) {
    if (query.isEmpty) {
      return FirebaseFirestore.instance
          .collection('events')
          .where('condi', isEqualTo: 'yes')
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('events')
          .where('condi', isEqualTo: 'yes')
          .where('eventName', isGreaterThanOrEqualTo: query)
          .where('eventName', isLessThan: query + 'z')
          .snapshots();
    }
  }

  // Filter out past events
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
  List<QueryDocumentSnapshot> filterEvents(List<QueryDocumentSnapshot> events) {
    final now = DateTime.now();
    return events.where((event) {
      final eventData = event.data() as Map<String, dynamic>;
      if (eventData['selectedDateTime'] is Timestamp) {
        final eventDate = (eventData['selectedDateTime'] as Timestamp).toDate();
        return eventDate.isAfter(now) || isSameDay(eventDate, now);
      }
      return false;
    }).toList();
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

<<<<<<< HEAD
  Widget _buildFeaturedEventCard(Map<String, dynamic>? eventData, String eventId) {
    String formattedDateTime = '';
    if (eventData?['selectedDateTime'] is Timestamp) {
      DateTime dateTime = (eventData?['selectedDateTime'] as Timestamp).toDate();
      formattedDateTime = DateFormat('EEE, MMM d • h:mm a').format(dateTime);
    }

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 8, bottom: 20),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EventPage(eventId: eventId)),
        ),
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.cardColor(context),
              boxShadow: AppShadows.defaultShadow(context),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: eventData?['imageUrl'] ?? '',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: Theme.of(context).hoverColor,
              ),
              errorWidget: (_, __, ___) => Container(
                color: Theme.of(context).hoverColor,
                child: Icon(Icons.error, color: AppColors.textColor(context)),
              ),
            ),
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 15,
              left: 15,
              right: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eventData?['eventName'] ?? 'Event Name',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: Colors.white70),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          eventData?['eventVenue'] ?? 'Venue',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        Row(
        children: [
        Icon(Icons.access_time_outlined,
            size: 16, color: Theme.of(context).hintColor),
        const SizedBox(width: 8),
        Text(
          formattedDateTime.isEmpty ? 'Date & Time' : formattedDateTime,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Theme.of(context).hintColor,
          ),
        ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'From',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Theme.of(context).hintColor,
                ),
              ),
              Text(
                'LKR ${NumberFormat('#,###').format(eventData?['normalTicketPrice'] ?? 0)}',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.orangePrimary,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EventPage(eventId: eventId)),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orangePrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              elevation: 5,
              shadowColor: AppColors.orangePrimary.withOpacity(0.3),
            ),
            child: const Text(
              'VIEW',
              style: TextStyle(
                fontSize: 14,
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
                ],
            ),
        ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic>? eventData, String eventId) {
    String formattedDateTime = '';
    if (eventData?['selectedDateTime'] is Timestamp) {
      DateTime dateTime = (eventData?['selectedDateTime'] as Timestamp).toDate();
      formattedDateTime = DateFormat('MMM d').format(dateTime);
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EventPage(eventId: eventId)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.cardColor(context),
          boxShadow: AppShadows.defaultShadow(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: eventData?['imageUrl'] ?? '',
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: Theme.of(context).hoverColor,
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: Theme.of(context).hoverColor,
                      child: Icon(Icons.error, color: AppColors.textColor(context)),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        formattedDateTime,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eventData?['eventName'] ?? 'Event Name',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor(context),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 14, color: Theme.of(context).hintColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          eventData?['eventVenue'] ?? 'Venue',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Theme.of(context).hintColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'LKR ${NumberFormat('#,###').format(eventData?['normalTicketPrice'] ?? 0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.orangePrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultCard(Map<String, dynamic>? eventData, String eventId) {
    String formattedDateTime = '';
    if (eventData?['selectedDateTime'] is Timestamp) {
      DateTime dateTime = (eventData?['selectedDateTime'] as Timestamp).toDate();
      formattedDateTime = DateFormat('EEE, MMM d • h:mm a').format(dateTime);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EventPage(eventId: eventId)),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.cardColor(context),
            boxShadow: AppShadows.defaultShadow(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: eventData?['imageUrl'] ?? '',
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: Theme.of(context).hoverColor,
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Theme.of(context).hoverColor,
                        child: Icon(Icons.error, color: AppColors.textColor(context)),
                      ),
                    ),
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 15,
                      left: 15,
                      right: 15,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            eventData?['eventName'] ?? 'Event Name',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 16, color: Colors.white70),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  eventData?['eventVenue'] ?? 'Venue',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time_outlined,
                            size: 16, color: Theme.of(context).hintColor),
                        const SizedBox(width: 8),
                        Text(
                          formattedDateTime.isEmpty ? 'Date & Time' : formattedDateTime,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'From',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            Text(
                              'LKR ${NumberFormat('#,###').format(eventData?['normalTicketPrice'] ?? 0)}',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.orangePrimary,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EventPage(eventId: eventId)),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orangePrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            elevation: 5,
                            shadowColor: AppColors.orangePrimary.withOpacity(0.3),
                          ),
                          child: const Text(
                            'VIEW',
                            style: TextStyle(
                              fontSize: 14,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 4,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Shimmer.fromColors(
          baseColor: Theme.of(context).hoverColor!,
          highlightColor: Theme.of(context).highlightColor!,
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.cardColor(context),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return _buildShimmerLoading();
    }

    final filteredEvents = filterEvents(_allEvents)
        .where((event) => selectedCategory == 'All' ||
        (event.data() as Map<String, dynamic>)['selectedCategory'] == selectedCategory)
        .toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (filteredEvents.any((event) {
            final eventData = event.data() as Map<String, dynamic>;
            final eventDate = (eventData['selectedDateTime'] as Timestamp).toDate();
            return eventDate.isBefore(DateTime.now().add(const Duration(days: 7)));
          }))
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Happening ',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textColor(context),
                      ),
                    ),
                    TextSpan(
                      text: 'This Week',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.orangePrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (filteredEvents.any((event) {
            final eventData = event.data() as Map<String, dynamic>;
            final eventDate = (eventData['selectedDateTime'] as Timestamp).toDate();
            return eventDate.isBefore(DateTime.now().add(const Duration(days: 7)));
          }))
            SizedBox(
              height: 312,
              child: PageView.builder(
                controller: _featuredEventsController,
                scrollDirection: Axis.horizontal,
                itemCount: filteredEvents.where((event) {
                  final eventData = event.data() as Map<String, dynamic>;
                  final eventDate = (eventData['selectedDateTime'] as Timestamp).toDate();
                  return eventDate.isBefore(DateTime.now().add(const Duration(days: 7)));
                }).length,
                itemBuilder: (context, index) {
                  final weeklyEvents = filteredEvents.where((event) {
                    final eventData = event.data() as Map<String, dynamic>;
                    final eventDate = (eventData['selectedDateTime'] as Timestamp).toDate();
                    return eventDate.isBefore(DateTime.now().add(const Duration(days: 7)));
                  }).toList();

                  final eventData = weeklyEvents[index].data() as Map<String, dynamic>;
                  return _buildFeaturedEventCard(eventData, weeklyEvents[index].id);
                },
                padEnds: false,
                pageSnapping: true,
              ),
            ),

          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 10, 16),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Upcoming ',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.orangePrimary,
                    ),
                  ),
                  TextSpan(
                    text: 'Events',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: filteredEvents.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              final eventData = filteredEvents[index].data() as Map<String, dynamic>;
              return _buildEventCard(eventData, filteredEvents[index].id);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return _buildShimmerLoading();
    }

    final searchResults = filterEvents(_allEvents)
        .where((doc) {
      final eventData = doc.data() as Map<String, dynamic>;
      final eventName = eventData['eventName'].toString().toLowerCase();
      return eventName.contains(searchQuery.toLowerCase());
    })
        .toList();

    if (searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Theme.of(context).hintColor),
            const SizedBox(height: 16),
            Text(
              'No events found',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).hintColor,
              ),
            ),
            Text(
              'Try a different search term',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final eventData = searchResults[index].data() as Map<String, dynamic>;
        return _buildSearchResultCard(eventData, searchResults[index].id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground(context),
      appBar: AppBar(
        systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${getGreeting()},',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Theme.of(context).hintColor,
              ),
            ),
            Text(
              'Discover Events',
              style: GoogleFonts.poppins(
                fontSize: 23,
                fontWeight: FontWeight.w700,
                color: AppColors.textColor(context),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.cardColor(context),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.orangePrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                size: 28, color: Color(0xffFF611A)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined,
                size: 28, color: Color(0xffFF611A)),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserProfile(userId: '')),
            ),
=======
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.mosque_outlined, color: Colors.orange),
            SizedBox(width: 8),
            const Text("Eventory"),
          ],
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.person_4_outlined, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UserProfile(
                          userId: '',
                        )),
              );
            },
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
          ),
        ],
      ),
      body: MainLayout(
        body: Column(
          children: [
<<<<<<< HEAD
            Padding(
              padding: const EdgeInsets.all(20),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(30),
                shadowColor: AppColors.orangePrimary.withOpacity(0.2),
=======
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Material(
                elevation: 10,
                shadowColor: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(40),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    filled: true,
<<<<<<< HEAD
                    fillColor: AppColors.cardColor(context),
                    hintText: 'Search concerts, sports, more...',
                    hintStyle: GoogleFonts.poppins(
                      color: Theme.of(context).hintColor,
                      fontSize: 16,
                    ),
                    prefixIcon: Icon(Icons.search,
                        color: Theme.of(context).hintColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 20),
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppColors.textColor(context),
                  ),
                  onChanged: (value) {
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (mounted && _searchController.text == value) {
                        setState(() {
                          searchQuery = value;
                        });
                      }
=======
                    fillColor: Color(0xffF1F7F7),
                    hintText: 'Search events...',
                    hintStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    prefixIcon: Icon(Icons.search, color: Colors.orange),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: BorderSide(color: Colors.black, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: BorderSide(color: Colors.black, width: 0),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                    });
                  },
                ),
              ),
            ),
<<<<<<< HEAD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: categories
                      .map((category) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(
                        category,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: selectedCategory == category
                              ? Colors.white
                              : AppColors.orangePrimary,
                        ),
                      ),
                      selected: selectedCategory == category,
                      selectedColor: AppColors.orangePrimary,
                      backgroundColor: AppColors.cardColor(context),
                      shape: StadiumBorder(
                        side: BorderSide(color: AppColors.orangePrimary),
                      ),
                      onSelected: (selected) {
                        setState(() {
                          selectedCategory = selected ? category : 'All';
                        });
                      },
                    ),
                  ))
                      .toList(),
                ),
              ),
            ),
            Expanded(
              child: searchQuery.isNotEmpty
                  ? _buildSearchResults()
                  : _buildMainContent(),
=======

            // Search Results
            if (searchQuery.isNotEmpty)
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: getSearchResults(searchQuery),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error loading events.'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final events = filterEvents(snapshot.data?.docs ?? []);

                    if (events.isEmpty) {
                      return Center(child: Text('No events found'));
                    }

                    return ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final eventData =
                            events[index].data() as Map<String, dynamic>;
                        return _buildSearchResultContainer(
                            eventData, events[index].id);
                      },
                    );
                  },
                ),
              ),

            if (searchQuery.isEmpty) ...[
              // Category Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      SizedBox(width: 16),
                      _buildCategoryChip('All'),
                      SizedBox(width: 8),
                      _buildCategoryChip('Music'),
                      SizedBox(width: 8),
                      _buildCategoryChip('Theater'),
                      SizedBox(width: 8),
                      _buildCategoryChip('Sport'),
                      SizedBox(width: 8),
                      _buildCategoryChip('Movie'),
                      SizedBox(width: 8),
                      _buildCategoryChip('Orchestral'),
                      SizedBox(width: 8),
                      _buildCategoryChip('Carnival'),
                      SizedBox(width: 16),
                    ],
                  ),
                ),
              ),

              // Events Content
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: getFilteredStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error loading events.'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final events = filterEvents(snapshot.data?.docs ?? []);

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Happening This Week Section
                                if (events.any((event) {
                                  final eventData =
                                      event.data() as Map<String, dynamic>;
                                  final eventDate =
                                      (eventData['selectedDateTime']
                                              as Timestamp)
                                          .toDate();
                                  return eventDate.isBefore(
                                      DateTime.now().add(Duration(days: 7)));
                                }))
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 16, 16, 8),
                                    child: Text.rich(
                                      TextSpan(children: [
                                        TextSpan(
                                          text: 'Happening ',
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'This Week',
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ]),
                                    ),
                                  ),

                                // Horizontal Scroll for This Week's Events
                                if (events.any((event) {
                                  final eventData =
                                      event.data() as Map<String, dynamic>;
                                  final eventDate =
                                      (eventData['selectedDateTime']
                                              as Timestamp)
                                          .toDate();
                                  return eventDate.isBefore(
                                      DateTime.now().add(Duration(days: 7)));
                                }))
                                  Container(
                                    height: 180,
                                    padding: EdgeInsets.only(bottom: 16),
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      itemCount: events.where((event) {
                                        final eventData = event.data()
                                            as Map<String, dynamic>;
                                        final eventDate =
                                            (eventData['selectedDateTime']
                                                    as Timestamp)
                                                .toDate();
                                        return eventDate.isBefore(DateTime.now()
                                            .add(Duration(days: 7)));
                                      }).length,
                                      itemBuilder: (context, index) {
                                        final filteredEvents =
                                            events.where((event) {
                                          final eventData = event.data()
                                              as Map<String, dynamic>;
                                          final eventDate =
                                              (eventData['selectedDateTime']
                                                      as Timestamp)
                                                  .toDate();
                                          return eventDate.isBefore(
                                              DateTime.now()
                                                  .add(Duration(days: 7)));
                                        }).toList();

                                        final eventData = filteredEvents[index]
                                            .data() as Map<String, dynamic>;
                                        return Padding(
                                          padding: EdgeInsets.only(right: 16),
                                          child: _buildHorizontalEventContainer(
                                              eventData,
                                              filteredEvents[index].id),
                                        );
                                      },
                                    ),
                                  ),

                                // Upcoming Events Section
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 8, 16, 16),
                                  child: Text.rich(
                                    TextSpan(children: [
                                      TextSpan(
                                        text: 'Upcoming ',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Events',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      )
                                    ]),
                                  ),
                                ),

                                // Grid View for All Upcoming Events
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: events.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16.0,
                                    mainAxisSpacing: 16.0,
                                    childAspectRatio: 0.75,
                                  ),
                                  itemBuilder: (context, index) {
                                    final eventData = events[index].data()
                                        as Map<String, dynamic>;
                                    return _buildEventContainer(
                                        eventData, events[index].id);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigatorBar(),
    );
  }

  Widget _buildCategoryChip(String category) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = selectedCategory == category ? 'All' : category;
        });
      },
      child: Chip(
        label: Text(category),
        backgroundColor:
            selectedCategory == category ? Colors.orange : Colors.grey[200],
        labelStyle: TextStyle(
          color: selectedCategory == category ? Colors.white : Colors.black,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.5),
        side: BorderSide.none,
      ),
    );
  }

  Widget _buildHorizontalEventContainer(
      Map<String, dynamic> eventData, String eventId) {
    final dateTime = (eventData['selectedDateTime'] as Timestamp).toDate();
    final formattedDate = DateFormat('MMM d').format(dateTime);
    final formattedTime = DateFormat('h:mm a').format(dateTime);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventPage(eventId: eventId),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image (Left Side)
            ClipRRect(
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(16),
                right: Radius.circular(0),
              ),
              child: Image.network(
                eventData['imageUrl'] ?? 'https://via.placeholder.com/300x150',
                width: 120,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            // Event Details (Right Side)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Event Name
                    Text(
                      eventData['eventName'] ?? 'Event Name',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Date and Time
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.access_time, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          formattedTime,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),

                    // Venue
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            eventData['eventVenue'] ?? 'Venue not specified',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // Price
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'LKR ${eventData['normalTicketPrice']?.toString() ?? '0'}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
            ),
          ],
        ),
      ),
<<<<<<< HEAD
      bottomNavigationBar: const BottomNavigatorBar(currentIndex: 0, userId: ''),
    );
  }
}
=======
    );
  }

  Widget _buildEventContainer(Map<String, dynamic> eventData, String eventId) {
    final dateTime = (eventData['selectedDateTime'] as Timestamp).toDate();
    final formattedDate = DateFormat('MMM d').format(dateTime);
    final formattedTime = DateFormat('h:mm a').format(dateTime);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventPage(eventId: eventId),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Event Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                eventData['imageUrl'] ?? 'https://via.placeholder.com/300x150',
                height: 100,
                fit: BoxFit.cover,
              ),
            ),

            // Event Details
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Name
                  Text(
                    eventData['eventName'] ?? 'Event Name',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 4),

                  // Date and Time
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        formattedTime,
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),

                  SizedBox(height: 4),

                  // Venue
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 12, color: Colors.grey),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          eventData['eventVenue'] ?? 'Venue not specified',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),

                  // Price
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'LKR ${eventData['normalTicketPrice']?.toString() ?? '0'}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultContainer(
      Map<String, dynamic> eventData, String eventId) {
    final dateTime = (eventData['selectedDateTime'] as Timestamp).toDate();
    final formattedDate = DateFormat('MMM d, y').format(dateTime);
    final formattedTime = DateFormat('h:mm a').format(dateTime);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventPage(eventId: eventId),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Event Image
            ClipRRect(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
              child: Image.network(
                eventData['imageUrl'] ?? 'https://via.placeholder.com/100',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),

            // Event Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eventData['eventName'] ?? 'Event Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 12, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 12, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          formattedTime,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'LKR ${eventData['normalTicketPrice']?.toString() ?? '0'}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
