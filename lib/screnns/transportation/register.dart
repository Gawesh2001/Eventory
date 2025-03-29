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
      appBar: AppBar(
        title: const Text("Offer Your Vehicle"),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
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
                        vehicleImage:
                            vehicle['vehicleImage'], // Pass the image URL
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VehicleCard extends StatefulWidget {
  final String ownerName;
  final String plateNumber;
  final String vehicleId;
  final int seatingCapacity;
  final String model;
  final String vehicleType;
  final String userId;
  final String eventId;
  final String? vehicleImage; // Make it nullable

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
    this.vehicleImage, // Optional parameter
  });

  @override
  _VehicleCardState createState() => _VehicleCardState();
}

class _VehicleCardState extends State<VehicleCard> {
  final TextEditingController locationController = TextEditingController();
  final TextEditingController stayInTimePeriodController =
      TextEditingController();
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  Future<void> _offerVehicle(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;
    final location = locationController.text;
    final stayInTimePeriod = stayInTimePeriodController.text;

    if (location.isEmpty || stayInTimePeriod.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the fields.')),
      );
      return;
    }

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
      'userId': widget.userId,
      'eventId': widget.eventId,
      'ownerName': widget.ownerName,
      'plateNumber': widget.plateNumber,
      'vehicleId': widget.vehicleId,
      'seatingCapacity': widget.seatingCapacity,
      'availableSeats': widget.seatingCapacity,
      'model': widget.model,
      'vehicleType': widget.vehicleType,
      'vehicleImage': widget.vehicleImage, // Include the image in the offer
      'location': location,
      'stayInTimePeriod': stayInTimePeriod,
      'status': 'available', // Add status field
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Vehicle offered with ID: $offerVehicleId')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Image (if available)
            if (widget.vehicleImage != null && widget.vehicleImage!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.vehicleImage!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.error, color: Colors.red),
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            Text('Owner: ${widget.ownerName}',
                style: Theme.of(context).textTheme.titleMedium),
            Text('Plate Number: ${widget.plateNumber}'),
            Text('Vehicle Type: ${widget.vehicleType}'),
            Text('Model: ${widget.model}'),
            Text('Seats: ${widget.seatingCapacity}'),

            const SizedBox(height: 10),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: stayInTimePeriodController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Stay-in Time Period',
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                TimeOfDay? start = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (start != null) {
                  TimeOfDay? end = await showTimePicker(
                    context: context,
                    initialTime: start,
                  );
                  if (end != null) {
                    setState(() {
                      startTime = start;
                      endTime = end;
                      stayInTimePeriodController.text =
                          "${start.format(context)} - ${end.format(context)}";
                    });
                  }
                }
              },
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _offerVehicle(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Offer Vehicle',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
