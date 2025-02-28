import 'package:eventory/navigators/bottomnavigatorbar.dart';
import 'package:eventory/screnns/transportation/pickup_search.dart';
import 'package:eventory/screnns/transportation/register.dart';
import 'package:eventory/screnns/otherscreens/userprofile.dart'; // Import UserProfile
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransportationPage extends StatefulWidget {
  const TransportationPage({super.key});

  @override
  _TransportationPageState createState() => _TransportationPageState();
}

class _TransportationPageState extends State<TransportationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 2 tabs: Accommodation, Transportation
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
      body: TabBarView(
        controller: _tabController,
        children: [
          // Accommodation content placeholder
          Center(child: Text('Accommodation content goes here')),

          // Transportation content
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
                    eventName: event['eventName'],
                    eventVenue: event['eventVenue'],
                    selectedDateTime: (event['selectedDateTime'] as Timestamp)
                        .toDate()
                        .toString(),
                    imageUrl: event['imageUrl'],
                  );
                },
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigatorBar(),
    );
  }
}

class EventTile extends StatelessWidget {
  final String eventName;
  final String eventVenue;
  final String selectedDateTime;
  final String imageUrl;

  const EventTile({
    super.key,
    required this.eventName,
    required this.eventVenue,
    required this.selectedDateTime,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(
              imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(eventName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Venue: $eventVenue',
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text('Date: $selectedDateTime',
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterVehiclePage()),
                        );
                      },
                      child: Text('Offer a vehicle'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PickupLocationSearch()),
                        );
                      },
                      child: Text('Book Ride'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
