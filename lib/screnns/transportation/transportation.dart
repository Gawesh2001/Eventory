// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eventory/navigators/bottomnavigatorbar.dart';
import 'package:eventory/screnns/transportation/bookride.dart';
import 'package:eventory/screnns/transportation/register.dart';
import 'package:eventory/screnns/otherscreens/userprofile.dart'; // Import UserProfile

class TransportationPage extends StatefulWidget {
  const TransportationPage({super.key});

  @override
  _TransportationPageState createState() => _TransportationPageState();
}

class _TransportationPageState extends State<TransportationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String userId = "Loading..."; // Default while fetching

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: 1); // Default to "Transportation"
    _fetchUserId();
  }

  // Fetch user ID from Firebase Authentication
  void _fetchUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      userId = user?.uid ?? "User ID: Not Available"; // Always set a value
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transportation"),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfile()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Accommodation'),
            Tab(text: 'Transportation'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Center(child: Text('Accommodation content goes here')),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('events')
                      .where('condi', isEqualTo: 'yes')
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    var events = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        var event = events[index];
                        return EventTile(
                          eventId: event.id, // Pass event ID
                          eventName: event['eventName'],
                          eventVenue: event['eventVenue'],
                          selectedDateTime:
                              (event['selectedDateTime'] as Timestamp)
                                  .toDate()
                                  .toString(),
                          imageUrl: event['imageUrl'],
                          userId: userId, // Pass user ID to EventTile
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          BottomNavigatorBar(),
        ],
      ),
    );
  }
}

class EventTile extends StatelessWidget {
  final String eventId;
  final String eventName;
  final String eventVenue;
  final String selectedDateTime;
  final String imageUrl;
  final String userId; // User ID is now required

  const EventTile({
    super.key,
    required this.eventId, // Ensure event ID is passed
    required this.eventName,
    required this.eventVenue,
    required this.selectedDateTime,
    required this.imageUrl,
    required this.userId, // Ensure it's always required
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(15),
      child: Container(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8), // Border radius added
                child: Image.network(
                  imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(eventName,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Venue: $eventVenue',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                  Text('Date: $selectedDateTime',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Reduced button size using padding
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterVehiclePage(
                                      userId: userId,
                                      eventId:
                                          eventId)), // Send both User ID & Event ID
                            );
                          },
                          child: Text('Offer a vehicle'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            minimumSize: Size(100, 40), // Button size reduced
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Bookride(
                                      userId: userId,
                                      eventId:
                                          eventId)), // Send event ID to PickupLocationSearch
                            );
                          },
                          child: Text('Book Ride'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            minimumSize: Size(100, 40), // Button size reduced
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
    );
  }
}
