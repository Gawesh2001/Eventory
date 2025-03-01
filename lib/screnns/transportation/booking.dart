
import 'package:flutter/material.dart';
import 'package:eventory/screnns/otherscreens/userprofile.dart';

class CarBookingPage extends StatelessWidget {
  final Map<String, String> vehicle;

  const CarBookingPage({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfile()),
              );
            },
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.deepOrange),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Vehicle Info
            Card(
              child: ListTile(
                leading: Image.network(
                  vehicle['image']!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
                title: Text(vehicle['name']!,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Plate No: CBA 0000\nColombo, Sri Lanka'),
              ),
            ),

            SizedBox(height: 18),

            // Contact Info
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      NetworkImage('https://i.imgur.com/8Km9tLL.png'),
                ),
                title: Text('S H Perera'),
                subtitle: Text('Driver'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.call, color: Colors.green),
                    SizedBox(width: 10),
                    Icon(Icons.message, color: Colors.blue),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Route Info
            Card(
              child: ListTile(
                leading: Icon(Icons.location_on, color: Colors.orange),
                title: Text('Keells - Colombo 4'),
                subtitle: Text('To: Kalaa Tharanaya, Colombo 10'),
              ),
            ),

            SizedBox(height: 16),

            // Fare Details
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.attach_money, color: Colors.orange),
                    title: Text('Estimated Fare'),
                    trailing: Text(vehicle['price']!),
                  ),
                  ListTile(
                    leading: Icon(Icons.timer, color: Colors.orange),
                    title: Text('Estimated Duration'),
                    trailing: Text('8 Minutes'),
                  ),
                  ListTile(
                    leading: Icon(Icons.route, color: Colors.orange),
                    title: Text('Estimated Distance'),
                    trailing: Text('5 KM'),
                  ),
                ],
              ),
            ),

            Spacer(),

            // Book Now Button
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ride Booked Successfully!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Book Now', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:eventory/screnns/otherscreens/userprofile.dart';

class CarBookingPage extends StatelessWidget {
  final Map<String, String> vehicle;

   const CarBookingPage ({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfile()),
              );
            },
          ),
        ],
    
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.deepOrange),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Vehicle Info
            Card(
              child: ListTile(
                leading: Image.network(
                  vehicle['image']!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
                title: Text(vehicle['name']!, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Plate No: CBA 0000\nColombo, Sri Lanka'),
              ),
            ),

            SizedBox(height: 18),

            // Contact Info
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage('https://i.imgur.com/8Km9tLL.png'),
                ),
                title: Text('S H Perera'),
                subtitle: Text('Driver'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.call, color: Colors.green),
                    SizedBox(width: 10),
                    Icon(Icons.message, color: Colors.blue),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Route Info
            Card(
              child: ListTile(
                leading: Icon(Icons.location_on, color: Colors.orange),
                title: Text('Keells - Colombo 4'),
                subtitle: Text('To: Kalaa Tharanaya, Colombo 10'),
              ),
            ),

            SizedBox(height: 16),

            // Fare Details
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.attach_money, color: Colors.orange),
                    title: Text('Estimated Fare'),
                    trailing: Text(vehicle['price']!),
                  ),
                  ListTile(
                    leading: Icon(Icons.timer, color: Colors.orange),
                    title: Text('Estimated Duration'),
                    trailing: Text('8 Minutes'),
                  ),
                  ListTile(
                    leading: Icon(Icons.route, color: Colors.orange),
                    title: Text('Estimated Distance'),
                    trailing: Text('5 KM'),
                  ),
                ],
              ),
            ),

            Spacer(),

            // Book Now Button
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ride Booked Successfully!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Book Now', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

