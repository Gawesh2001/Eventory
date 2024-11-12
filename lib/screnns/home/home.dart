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
  String selectedCategory = 'All'; // Default category is All
  final Stream<QuerySnapshot> allEventStream = FirebaseFirestore.instance
      .collection('events')
      .where('condi', isEqualTo: 'yes')
      .snapshots();

  Stream<QuerySnapshot> getFilteredStream() {
    print("Selected category: $selectedCategory");
    if (selectedCategory == 'All') {
      return allEventStream;
    } else {
      print("Filtering events by category: $selectedCategory");
      return FirebaseFirestore.instance
          .collection('events')
          .where('category', isEqualTo: selectedCategory)
          .where('condi', isEqualTo: 'yes')
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.notifications, color: Colors.orange),
            SizedBox(width: 8),
            const Text("Home"),
          ],
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfile()),
              );
            },
          ),
        ],
      ),
      body: MainLayout(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xffF1F7F7),
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.orange[300]),
                  labelText: 'Search Events',
                  labelStyle: TextStyle(color: Color(0xff6F7D7D)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(color: Colors.orange, width: 1),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedCategory = 'All';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedCategory == 'All'
                          ? Colors.orange
                          : Colors.white60,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text('All', style: TextStyle(color: Colors.black)),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedCategory = 'Music';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedCategory == 'Music'
                          ? Colors.orange
                          : Colors.white60,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text('Music', style: TextStyle(color: Colors.black)),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedCategory = 'Theater';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedCategory == 'Theater'
                          ? Colors.orange
                          : Colors.white60,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child:
                        Text('Theater', style: TextStyle(color: Colors.black)),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedCategory = 'Sport';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedCategory == 'Sport'
                          ? Colors.orange
                          : Colors.white60,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text('Sport', style: TextStyle(color: Colors.black)),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedCategory = 'Movie';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedCategory == 'Movie'
                          ? Colors.orange
                          : Colors.white60,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text('Movie', style: TextStyle(color: Colors.black)),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedCategory = 'Orchestral';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedCategory == 'Orchestral'
                          ? Colors.orange
                          : Colors.white60,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text('Orchestral',
                        style: TextStyle(color: Colors.black)),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedCategory = 'Carnival';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedCategory == 'Carnival'
                          ? Colors.orange
                          : Colors.white60,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child:
                        Text('Carnival', style: TextStyle(color: Colors.black)),
                  ),
                  SizedBox(width: 16),
                ],
              ),
            ),
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
                  final events = snapshot.data?.docs ?? [];

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text.rich(TextSpan(children: [
                            TextSpan(
                              text: 'Happening ',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black, // "Happening" in black
                              ),
                            ),
                            TextSpan(
                              text: 'This Week',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange, // "This Week" in orange
                              ),
                            ),
                          ])),
                        ),
                        SizedBox(
                          height: 220,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(events.length, (index) {
                                final eventData = events[index].data()
                                    as Map<String, dynamic>?;
                                DateTime eventDate = DateTime.now();
                                if (eventData?['selectedDateTime']
                                    is Timestamp) {
                                  eventDate = (eventData?['selectedDateTime']
                                          as Timestamp)
                                      .toDate();
                                }
                                bool isUpcoming = eventDate
                                        .isAfter(DateTime.now()) &&
                                    eventDate.isBefore(
                                        DateTime.now().add(Duration(days: 7)));
                                // Add the event if it is within the next 7 days
                                if (isUpcoming) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EventPage(
                                            eventId: events[index].id,
                                          ),
                                        ),
                                      );
                                    },
                                    child: _buildHorizontalEventContainer(
                                        eventData),
                                  );
                                } else {
                                  return Container(); // Skip if not in next 7 days
                                }
                              }),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text.rich(TextSpan(children: [
                            TextSpan(
                              text: 'Upcoming ',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange, // "Upcoming" in orange
                              ),
                            ),
                            TextSpan(
                              text: 'Events',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black, // "Events" in black
                              ),
                            )
                          ])),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: events.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 4.0,
                            mainAxisSpacing: 6.0,
                            childAspectRatio: 0.6,
                          ),
                          itemBuilder: (context, index) {
                            final eventData =
                                events[index].data() as Map<String, dynamic>?;
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          EventPage(eventId: events[index].id)),
                                );
                              },
                              child: _buildEventContainer(eventData),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigatorBar(),
    );
  }

  Widget _buildHorizontalEventContainer(Map<String, dynamic>? eventData) {
    String formattedDateTime = '';
    if (eventData?['selectedDateTime'] is Timestamp) {
      DateTime dateTime =
          (eventData?['selectedDateTime'] as Timestamp).toDate();
      formattedDateTime = DateFormat('h:mm a').format(dateTime);
    }

    return Container(
      width: 350,
      height: 200,
      margin: EdgeInsets.symmetric(horizontal: 8),
      padding: EdgeInsets.all(23),
      decoration: BoxDecoration(
        color: Color(0xffF1F7F7),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(eventData?['imageUrl'] ??
                    'https://via.placeholder.com/150'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eventData?['eventName'] ?? 'Event Name',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(eventData?['eventVenue'] ?? 'Venue'),
                SizedBox(height: 4),
                Text(formattedDateTime.isEmpty ? 'Time' : formattedDateTime),
                SizedBox(height: 4),
                Text('Price: LKR: ${eventData?['normalTicketPrice'] ?? '0'}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventContainer(Map<String, dynamic>? eventData) {
    String formattedDateTime = '';
    if (eventData?['selectedDateTime'] is Timestamp) {
      DateTime dateTime =
          (eventData?['selectedDateTime'] as Timestamp).toDate();
      formattedDateTime = DateFormat('h:mm a').format(dateTime);
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xffF1F7F7),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                image: NetworkImage(eventData?['imageUrl'] ??
                    'https://via.placeholder.com/150'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            eventData?['eventName'] ?? 'Event Name',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(eventData?['eventVenue'] ?? 'Event Venue',
              style: TextStyle(fontSize: 12)),
          Text(
            formattedDateTime.isEmpty
                ? 'Event Date and Time'
                : formattedDateTime,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 4),
          Text('Price: LKR: ${eventData?['normalTicketPrice'] ?? '0'}'),
        ],
      ),
    );
  }
}
