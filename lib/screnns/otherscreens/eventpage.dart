import 'package:flutter/material.dart';

class EventPage extends StatefulWidget {
  final String eventId; // Add this parameter

  const EventPage(
      {super.key,
      required this.eventId}); // Require the eventId in the constructor

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Event Details"),
      ),
      body: Center(
        child:
            Text("Event ID: ${widget.eventId}"), // Display event ID for testing
      ),
    );
  }
}
