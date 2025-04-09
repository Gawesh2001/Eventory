// event_tile.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:eventory/modles/eventmodel.dart';

class EventTile extends StatelessWidget {
  final Event event;

  const EventTile({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          if (event.imageUrl != null)
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: FileImage(File(event.imageUrl!)),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              width: 100,
              height: 100,
              color: Colors.grey,
            ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.name,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(event.venue),
                Text("${event.dateTime.toLocal()}".split(' ')[0]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
