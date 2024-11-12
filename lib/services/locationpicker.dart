// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerPage extends StatefulWidget {
  @override
  _LocationPickerPageState createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  late GoogleMapController mapController;
  LatLng _selectedLocation = LatLng(0.0, 0.0);

  // Set initial camera position to a default location (e.g., 0.0, 0.0)
  final CameraPosition _initialPosition =
      CameraPosition(target: LatLng(0.0, 0.0), zoom: 10);

  // Function to handle tap on map and update location
  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Location"),
        backgroundColor: Color(0xffF79C14),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, _selectedLocation);
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: _initialPosition,
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        onTap: _onMapTapped,
        markers: {
          Marker(
            markerId: MarkerId('selected_location'),
            position: _selectedLocation,
          ),
        },
      ),
    );
  }
}
