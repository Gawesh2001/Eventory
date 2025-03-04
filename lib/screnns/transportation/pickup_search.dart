// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'choose_ride.dart';

class PickupLocationSearch extends StatefulWidget {
  const PickupLocationSearch({super.key, required String eventId});

  @override
  _PickupLocationSearchState createState() => _PickupLocationSearchState();
}

class _PickupLocationSearchState extends State<PickupLocationSearch> {
  final List<String> locations = [
    'Keells - Colombo 4',
    'Keells - Colombo 5',
    'Keells - Colombo 6',
    'Lotus Tower - Colombo 10',
    'Galle Face - Colombo 3',
    'Majestic City - Colombo 4',
  ];

  List<String> filteredLocations = [];
  String selectedLocation = '';

  @override
  void initState() {
    super.initState();
    filteredLocations = locations;
  }

  void _filterLocations(String query) {
    setState(() {
      filteredLocations = locations
          .where((location) =>
              location.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _selectLocation(String location) {
    setState(() {
      selectedLocation = location;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Pick Up Location', style: TextStyle(color: Colors.orange)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _filterLocations,
              decoration: InputDecoration(
                hintText: 'Pickup Location',
                prefixIcon: Icon(Icons.search, color: Colors.orange),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.orange),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.orange, width: 2),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredLocations.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.location_on, color: Colors.grey),
                  title: Text(filteredLocations[index]),
                  onTap: () {
                    _selectLocation(filteredLocations[index]);
                  },
                  selected: selectedLocation == filteredLocations[index],
                  selectedTileColor: Colors.orange.withOpacity(0.1),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: selectedLocation.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChooseRide(
                              // pickupLocation: selectedLocation,
                              ),
                        ),
                      );
                    },
              child: Text(
                'Confirm Pick-up',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
