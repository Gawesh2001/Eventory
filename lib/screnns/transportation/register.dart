// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RegisterVehiclePage extends StatefulWidget {
  final String userId;
  final String eventId;

  const RegisterVehiclePage({
    super.key,
    required this.userId,
    required this.eventId,
  });

  @override
  _RegisterVehiclePageState createState() => _RegisterVehiclePageState();
}

class _RegisterVehiclePageState extends State<RegisterVehiclePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register Vehicle")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('vehicles')
                  .where('userId', isEqualTo: widget.userId)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var vehicles = snapshot.data!.docs;
                if (vehicles.isEmpty) {
                  return const Center(child: Text("No vehicles registered"));
                }

                return ListView.builder(
                  itemCount: vehicles.length,
                  itemBuilder: (context, index) {
                    var vehicle = vehicles[index];
                    int seatingCapacity =
                        int.tryParse(vehicle['seatingCapacity'].toString()) ??
                            0;

                    return VehicleCard(
                      ownerName: vehicle['ownerName'],
                      plateNumber: vehicle['plateNumber'],
                      vehicleId: vehicle['vehicleId'],
                      seatingCapacity: seatingCapacity,
                      model: vehicle['model'],
                      vehicleType: vehicle['vehicleType'],
                      userId: widget.userId,
                      eventId: widget.eventId,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class VehicleCard extends StatelessWidget {
  final String ownerName;
  final String plateNumber;
  final String vehicleId;
  final int seatingCapacity;
  final String model;
  final String vehicleType;
  final String userId;
  final String eventId;

  const VehicleCard({
    super.key,
    required this.ownerName,
    required this.plateNumber,
    required this.vehicleId,
    required this.seatingCapacity,
    required this.model,
    required this.vehicleType,
    required this.userId,
    required this.eventId,
  });

  Future<void> _offerVehicle(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;

    final offerVehicles = await firestore.collection('offerVehicles').get();

    int offerVehicleId = 500000;
    if (offerVehicles.docs.isNotEmpty) {
      final lastOffer = offerVehicles.docs
          .map((doc) => doc['offerVehicleId'] as int)
          .reduce((a, b) => a > b ? a : b);
      offerVehicleId = lastOffer + 1;
    }

    await firestore.collection('offerVehicles').add({
      'offerVehicleId': offerVehicleId,
      'userId': userId,
      'eventId': eventId,
      'ownerName': ownerName,
      'plateNumber': plateNumber,
      'vehicleId': vehicleId,
      'seatingCapacity': seatingCapacity,
      'availableSeats':
          seatingCapacity, // Set availableSeats based on seatingCapacity
      'model': model,
      'vehicleType': vehicleType,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Vehicle offered with ID: $offerVehicleId')),
    );
  }

  String _getVehicleImage() {
    switch (vehicleType.toLowerCase()) {
      case 'bus':
        return 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRDKdpJKMeVFuOqNrhAf7A_cxAArJjmAISmFA7qSmHjJnVlYSv0yaanyMCTcstAsnwa_ZA&usqp=CAU';
      case 'car':
        return 'https://static.vecteezy.com/system/resources/previews/008/459/863/non_2x/gorgeous-car-for-2d-cartoon-animation-cute-cartoon-car-free-vector.jpg';
      case 'bike':
        return 'https://t3.ftcdn.net/jpg/00/40/41/06/360_F_40410609_VJAIk9BK7EaiNwToWBk0sn0ijySf9cQU.jpg';
      case 'van':
        return 'https://static.vecteezy.com/system/resources/previews/047/709/176/non_2x/realistic-truck-illustration-vector.jpg';
      default:
        return 'https://via.placeholder.com/150';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Image.network(
              _getVehicleImage(),
              height: 150,
              width: 150,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Owner: $ownerName',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Plate Number: $plateNumber',
                      style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  Text('Vehicle ID: $vehicleId',
                      style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  Text('Seating Capacity: $seatingCapacity',
                      style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  Text('Model: $model',
                      style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  Text('Vehicle Type: $vehicleType',
                      style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _offerVehicle(context),
                    child: const Text('Offer Vehicle'),
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
