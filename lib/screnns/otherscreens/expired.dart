import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Expired extends StatefulWidget {
  final String userId;

  const Expired({Key? key, required this.userId}) : super(key: key);

  @override
  _ExpiredState createState() => _ExpiredState();
}

class _ExpiredState extends State<Expired> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading delay
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expired Tickets'),
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Colors.orange,
        ),
      )
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Tickets')
            .where('userId', isEqualTo: widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
                  color: Colors.orange,
                ));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No expired tickets found.'));
          }

          var tickets = snapshot.data!.docs;

          // Filter expired tickets
          var expiredTickets = tickets.where((ticket) {
            var eventId = ticket['eventId'];
            var eventDateTime = ticket['timestamp'].toDate();
            return eventDateTime.isBefore(DateTime.now());
          }).toList();

          return ListView.builder(
            itemCount: expiredTickets.length,
            itemBuilder: (context, index) {
              var ticket = expiredTickets[index];
              var ticketId = ticket['ticketId'];
              var eventId = ticket['eventId'];
              var ticketName = ticket['ticketName'];
              var timestamp = ticket['timestamp'].toDate();

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('events')
                    .doc(eventId)
                    .get(),
                builder: (context, eventSnapshot) {
                  if (eventSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const ListTile(
                      title: Text('Loading event details...'),
                    );
                  }
                  if (!eventSnapshot.hasData) {
                    return const ListTile(
                      title: Text('Event details not found.'),
                    );
                  }

                  var event = eventSnapshot.data!;
                  var eventName = event['eventName'];
                  var eventDateTime = event['selectedDateTime'].toDate();

                  return Card(
                    margin: const EdgeInsets.all(8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                eventName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('Ticket ID: $ticketId'),
                              Text('Ticket Type: $ticketName'),
                              Text(
                                  'Date: ${DateFormat('dd MMM yyyy').format(eventDateTime)}'),
                              Text(
                                  'Time: ${DateFormat('hh:mm a').format(eventDateTime)}'),
                            ],
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Expired',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}