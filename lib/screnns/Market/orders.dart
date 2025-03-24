import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventory/navigators/bottomnavigatorbar.dart';

class Orders extends StatelessWidget {
  final String userId;

  const Orders({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Orders"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Filter orders by the logged-in user's userId
        stream: FirebaseFirestore.instance
            .collection('market')
            .where('userId', isEqualTo: userId) // Only fetch orders for the logged-in user
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error fetching orders: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No orders available for this user."),
            );
          }

          // Fetch all event names in advance
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchEventNames(snapshot.data!.docs),
            builder: (context, eventSnapshot) {
              if (eventSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (eventSnapshot.hasError) {
                return Center(child: Text("Error fetching event details: ${eventSnapshot.error}"));
              }

              final orders = snapshot.data!.docs;
              final eventNames = eventSnapshot.data!;

              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index].data() as Map<String, dynamic>;
                  final eventName = eventNames[index]['eventName'];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 4,
                    child: ListTile(
                      title: Text("Event: $eventName"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Ticket ID: ${order['ticketId']}"),
                          Text("Original Price: LKR ${order['originalPrice']}"),
                          Text("Current Price: LKR ${order['currentPrice']}"),
                        ],
                      ),
                      trailing: order['isSold']
                          ? const Text("Sold", style: TextStyle(color: Colors.red))
                          : const Text("Available", style: TextStyle(color: Colors.green)),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigatorBar(),
    );
  }

  // Helper function to fetch event names for all orders
  Future<List<Map<String, dynamic>>> _fetchEventNames(List<QueryDocumentSnapshot> orders) async {
    List<Map<String, dynamic>> eventNames = [];

    for (var order in orders) {
      final orderData = order.data() as Map<String, dynamic>;
      final eventId = orderData['eventId'];

      DocumentSnapshot eventDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .get();

      eventNames.add({
        'eventName': eventDoc.exists ? eventDoc['eventName'] : "Unknown Event",
      });
    }

    return eventNames;
  }
}