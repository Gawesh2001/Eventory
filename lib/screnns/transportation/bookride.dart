import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Bookride extends StatelessWidget {
  final String eventId;
  final String userId;

  const Bookride({super.key, required this.eventId, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Rides",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F5F5), Color(0xFFE0E0E0)],
          ),
        ),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('offerVehicles')
              .where('eventId', isEqualTo: eventId)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                color: Colors.orange,
              ));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_car,
                        size: 60, color: Colors.grey[400]),
                    const SizedBox(height: 20),
                    Text(
                      "No vehicles available for this event",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var vehicle = snapshot.data!.docs[index];
                return VehicleTile(
                  offerVehicleId: vehicle.id,
                  model: vehicle['model'],
                  ownerName: vehicle['ownerName'],
                  plateNumber: vehicle['plateNumber'],
                  seatingCapacity: vehicle['seatingCapacity'],
                  availableSeats:
                      int.tryParse(vehicle['availableSeats'].toString()) ?? 0,
                  userId: vehicle['userId'],
                  vehicleId: vehicle['vehicleId'],
                  vehicleType: vehicle['vehicleType'],
                  eventId: eventId,
                  currentUserId: userId,
                  location: vehicle['location'] ?? "Not specified",
                  stayInTimePeriod:
                      vehicle['stayInTimePeriod'] ?? "Not specified",
                  vehicleImage: vehicle['vehicleImage'], // Add vehicle image
                );
              },
            );
          },
        ),
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
  final String? vehicleImage;

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
    this.vehicleImage,
  });

  Future<void> _bookRide(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;
    TextEditingController seatsController = TextEditingController();
    bool confirmBooking = false;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Book Ride",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Available seats: $availableSeats",
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              TextField(
                controller: seatsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Number of seats',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (seatsController.text.isNotEmpty &&
                          int.parse(seatsController.text) <= availableSeats &&
                          int.parse(seatsController.text) > 0) {
                        confirmBooking = true;
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please enter a valid number!')),
                        );
                      }
                    },
                    child: const Text('Confirm',
                        style: TextStyle(color: Colors.white)),
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
      final rideId = await _generateRideId(firestore);

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
        'vehicleImage': vehicleImage,
        'bookingTime': FieldValue.serverTimestamp(),
      });

      await firestore.collection('offerVehicles').doc(offerVehicleId).update({
        'availableSeats': availableSeats - seatsBooked,
      });

      // Show success dialog
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text("Booking Confirmed",
                style: TextStyle(color: Colors.green)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (vehicleImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      vehicleImage!,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                    "You've successfully booked $seatsBooked seat${seatsBooked > 1 ? 's' : ''} in $model.",
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK', style: TextStyle(color: Colors.orange)),
              ),
            ],
          );
        },
      );
    }
  }

  Future<String> _generateRideId(FirebaseFirestore firestore) async {
    final querySnapshot = await firestore
        .collection('bookedRides')
        .orderBy('rideId', descending: true)
        .limit(1)
        .get();

    int newId = 900000;
    if (querySnapshot.docs.isNotEmpty) {
      String lastRideId = querySnapshot.docs.first['rideId'];
      newId = int.parse(lastRideId.substring(1)) + 1;
    }

    return 'V$newId';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle Image
          if (vehicleImage != null && vehicleImage!.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: Image.network(
                  vehicleImage!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.directions_car, size: 60),
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      model,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        vehicleType.toUpperCase(),
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      ownerName,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const Spacer(),
                    const Icon(Icons.confirmation_number,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      plateNumber,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildInfoChip(Icons.location_on, location, Colors.blue),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                        Icons.access_time, stayInTimePeriod, Colors.green),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildSeatInfo(
                        'Total Seats', seatingCapacity.toString(), Colors.grey),
                    const SizedBox(width: 16),
                    _buildSeatInfo('Available', availableSeats.toString(),
                        availableSeats > 0 ? Colors.green : Colors.red),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed:
                        availableSeats > 0 ? () => _bookRide(context) : null,
                    child: Text(
                      availableSeats > 0 ? 'Book Now' : 'Fully Booked',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: color, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatInfo(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
