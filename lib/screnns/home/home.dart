// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventory/navigators/mainlayout.dart';
import 'package:eventory/screnns/otherscreens/eventpage.dart';
import 'package:eventory/screnns/otherscreens/userprofile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eventory/navigators/bottomnavigatorbar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String selectedCategory = 'All';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
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
          ),
        ],
      ),
      body: MainLayout(
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Material(
                elevation: 10,
                shadowColor: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(40),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    filled: true,
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
                    });
                  },
                ),
              ),
            ),

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
            ),
          ],
        ),
      ),
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
