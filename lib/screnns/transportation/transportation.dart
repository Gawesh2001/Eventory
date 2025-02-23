import 'package:eventory/navigators/bottomnavigatorbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransportationPage extends StatelessWidget {
  const TransportationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transportation', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
        //leading: IconButton(
        //icon: Icon(Icons.arrow_back, color: Colors.white),
        //onPressed: () {
        // Navigator.pop(context);
        // },
      ),
      //  ),
      body: StreamBuilder(
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
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Venue: $eventVenue',
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text('Date: $selectedDateTime',
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Mokakhri'),
                    ),
                    ElevatedButton(
                      onPressed: () {},
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
