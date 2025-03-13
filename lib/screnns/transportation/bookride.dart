
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Bookride extends StatelessWidget {
  final String eventId; // Event ID received here
  final String userId; // User ID received here

  const Bookride({super.key, required this.eventId, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick a ride"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('offerVehicles')
            .where('eventId', isEqualTo: eventId) // Fetch records where eventId matches
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var vehicles = snapshot.data!.docs;
          if (vehicles.isEmpty) {
            return const Center(
                child: Text("No vehicles available for this event."));
          }

          return ListView.builder(
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              var vehicle = vehicles[index];

              return VehicleTile(
                offerVehicleId: vehicle.id,
                model: vehicle['model'],
                ownerName: vehicle['ownerName'],
                plateNumber: vehicle['plateNumber'],
                seatingCapacity: vehicle['seatingCapacity'],
                availableSeats: int.tryParse(vehicle['availableSeats'].toString()) ?? 0,
                userId: vehicle['userId'],
                vehicleId: vehicle['vehicleId'],
                vehicleType: vehicle['vehicleType'],
                eventId: eventId,
                currentUserId: userId,
                location: vehicle['location'] ?? "Unknown",
                stayInTimePeriod: vehicle['stayInTimePeriod'] ?? "Not Specified",
              );
            },
          );
        },
      ),
    );
  }
}

class VehicleTile extends StatelessWidget {
  final String offerVehicleId;
  final String model;
  final String ownerName;
  final String plateNumber;
  final int seatingCapacity;
  final int availableSeats;
  final String userId;
  final String vehicleId;
  final String vehicleType;
  final String eventId;
  final String currentUserId;
  final String location;
  final String stayInTimePeriod;

  const VehicleTile({
    super.key,
    required this.offerVehicleId,
    required this.model,
    required this.ownerName,
    required this.plateNumber,
    required this.seatingCapacity,
    required this.availableSeats,
    required this.userId,
    required this.vehicleId,
    required this.vehicleType,
    required this.eventId,
    required this.currentUserId,
    required this.location,
    required this.stayInTimePeriod,
  });

  Future<void> _bookRide(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;

    // Show a dialog to ask for the number of seats
    TextEditingController seatsController = TextEditingController();
    bool confirmBooking = false;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Book Ride"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Available Seats: $availableSeats"),
              TextField(
                controller: seatsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Number of Seats',
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (seatsController.text.isNotEmpty &&
                          int.parse(seatsController.text) <= availableSeats) {
                        confirmBooking = true;
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invalid number of seats!')),
                        );
                      }
                    },
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (confirmBooking) {
      int seatsBooked = int.parse(seatsController.text);

      // Generate a new ride ID
      final rideId = await _generateRideId(firestore);

      // Add the booking to the bookedRides collection
      await firestore.collection('bookedRides').add({
        'rideId': rideId,
        'userId': currentUserId,
        'eventId': eventId,
        'vehicleId': vehicleId,
        'seatsBooked': seatsBooked,
        'ownerName': ownerName,
        'model': model,
        'plateNumber': plateNumber,
        'vehicleType': vehicleType,
        'location': location,
        'stayInTimePeriod': stayInTimePeriod,
      });

      // Update the availableSeats in the offerVehicles collection
      await firestore.collection('offerVehicles').doc(offerVehicleId).update({
        'availableSeats': availableSeats - seatsBooked,
      });

      // Show a confirmation dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Booking Confirmed"),
            content: Text("You've booked $seatsBooked seats with $ownerName for the vehicle: $model."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<String> _generateRideId(FirebaseFirestore firestore) async {
    // Fetch the last ride ID from Firestore
    final querySnapshot = await firestore
        .collection('bookedRides')
        .orderBy('rideId', descending: true)
        .limit(1)
        .get();

    int newId = 900000; // Default starting ID

    if (querySnapshot.docs.isNotEmpty) {
      // Extract the last ride ID and increment it
      String lastRideId = querySnapshot.docs.first['rideId'];
      newId = int.parse(lastRideId.substring(1)) + 1;
    }

    return 'V$newId'; // Return the new ride ID
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Vehicle Model: $model",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Owner: $ownerName",
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            Text("Plate Number: $plateNumber",
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            Text("Seating Capacity: $seatingCapacity",
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            Text("Vehicle Type: $vehicleType",
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 8),
            Text("Location: $location",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text("Stay Period: $stayInTimePeriod",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Available Seats: $availableSeats",
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _bookRide(context),
              child: const Text('Pick'),
            ),
          ],
        ),
      ),
    );
  }
}
