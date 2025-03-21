// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventory/screnns/accomedation/add_accomedations.dart';
import 'package:eventory/screnns/accomedation/components.dart';
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
  String? selectedEvent; // To store the selected event ID
  String eventLocation = ""; // To store the event location
  List<Map<String, String>> eventList = []; // Store eventName and eventID

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: 1); // Default to "Transportation"
    _fetchUserId();
    fetchEvents();
  }

  // Fetch events from Firestore
  Future<void> fetchEvents() async {
    QuerySnapshot eventSnapshot =
        await FirebaseFirestore.instance.collection('events').get();
    setState(() {
      eventList = eventSnapshot.docs
          .map((doc) => {
                'eventName': doc['eventName'].toString(),
                'eventID': doc.id, // Firestore IDs are always Strings
              })
          .toList();
    });
  }

  // Fetch event location from Firestore
  Future<void> fetchEventLocation(String eventID) async {
    DocumentSnapshot eventDoc = await FirebaseFirestore.instance
        .collection('events')
        .doc(eventID)
        .get();

    if (eventDoc.exists) {
      setState(() {
        eventLocation = eventDoc['eventVenue'];
      });
    }
  }

  // Fetch accommodations from Firestore
  Stream<QuerySnapshot> fetchAccommodations() {
    Query query = FirebaseFirestore.instance.collection('accommodations');

    if (selectedEvent != null) {
      query = query.where('selectedEvent', isEqualTo: selectedEvent);
    }

    return query.snapshots();
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
        title: const Text("Transportation"),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserProfile()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.orange[700], // Color of the selected tab text/icon
          unselectedLabelColor:
              Colors.grey[500], // Color of unselected tab text/icon
          indicatorColor:
              Colors.orange[700], // Orange underline for the selected tab
          tabs: const [
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
                // Accommodation Tab
                SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Find your stay here!",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[700]),
                            ),
                            // Add button only on the accommodation side
                            if (_tabController.index == 0)
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AddAccommodationPage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                      255, 255, 255, 255), // Button color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        8), // Rounded corners
                                  ),
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: Colors.orange[700], // Icon color
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: "Select Event",
                            floatingLabelStyle: TextStyle(
                              color: Colors
                                  .orange, // Label text color when focused
                              fontWeight: FontWeight.bold,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.orange,
                                  width: 2.0), // Orange when active
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          items: eventList.map((event) {
                            return DropdownMenuItem(
                              value: event[
                                  'eventID'], // Store event ID in selectedEvent
                              child:
                                  Text(event['eventName']!), // Show event name
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedEvent =
                                  value as String?; // Now stores eventID
                              fetchEventLocation(selectedEvent!);
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: "Location",
                            icon: const Icon(
                              Icons.location_pin,
                              color: Colors.grey,
                            ),
                            hintText: eventLocation,
                            enabled: false,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: StreamBuilder(
                          stream: fetchAccommodations(),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return const Center(
                                  child: Text("No accommodations available"));
                            }
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data!.docs.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.6,
                              ),
                              itemBuilder: (context, index) {
                                var data = snapshot.data!.docs[index];
                                return AccommodationCard(
                                  imageUrl: data['imageUrl'],
                                  title: data['name'],
                                  location: data['location'],
                                  mapLink: data['mapLink'],
                                  rating: data['rating'].toDouble(),
                                  minPrice: data['price'].toInt(),
                                  isEventOffer: data['isEventOffer'],
                                  contact: data['contact'],
                                  email: data['email'],
                                  description: data['facilities'].toString(),
                                  accommodationID: data['accommodationID'],
                                  website: data['website'],
                                  socialMedia: data['socialMedia'],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Transportation Tab
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('events')
                      .where('condi', isEqualTo: 'yes')
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
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
      margin: const EdgeInsets.all(15),
      child: Container(
        padding: const EdgeInsets.all(8),
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
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Venue: $eventVenue',
                      style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  Text('Date: $selectedDateTime',
                      style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 10),
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
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            minimumSize:
                                const Size(100, 40), // Button size reduced
                          ),
                          child: const Text('Offer a vehicle'),
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
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            minimumSize:
                                const Size(100, 40), // Button size reduced
                          ),
                          child: const Text('Book Ride'),
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
