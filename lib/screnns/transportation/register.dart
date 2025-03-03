import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RegisterVehiclePage extends StatefulWidget {
  final String userId; // User ID passed from the previous screen

  const RegisterVehiclePage({super.key, required this.userId});

  @override
  _RegisterVehiclePageState createState() => _RegisterVehiclePageState();
}

class _RegisterVehiclePageState extends State<RegisterVehiclePage> {
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = widget.userId; // Get the user ID passed from the previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register Vehicle")),
      body: Column(
        children: [
          // Displaying the userId at the top
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'User ID: $userId',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          // StreamBuilder to fetch the vehicles registered by the user
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection(
                      'vehicles') // Assuming you have a 'vehicles' collection in Firestore
                  .where('userId',
                      isEqualTo:
                          userId) // Fetch vehicles for the specific user based on userId
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var vehicles = snapshot.data!.docs;
                if (vehicles.isEmpty) {
                  return Center(child: Text("No vehicles registered"));
                }

                return ListView.builder(
                  itemCount: vehicles.length,
                  itemBuilder: (context, index) {
                    var vehicle = vehicles[index];
                    // Ensure 'seatingCapacity' is parsed as an integer
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

  const VehicleCard({
    super.key,
    required this.ownerName,
    required this.plateNumber,
    required this.vehicleId,
    required this.seatingCapacity,
    required this.model,
    required this.vehicleType,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Owner: $ownerName',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Plate Number: $plateNumber',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text('Vehicle ID: $vehicleId',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text('Seating Capacity: $seatingCapacity',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text('Model: $model',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text('Vehicle Type: $vehicleType',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Handle the "Offer" button action
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Vehicle offered')));
              },
              child: Text('Offer Vehicle'),
            ),
          ],
        ),
      ),
    );
  }
}
