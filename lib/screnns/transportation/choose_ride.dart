import 'package:flutter/material.dart';
import 'booking.dart';

class ChooseRide extends StatefulWidget {
  @override
  _ChooseRideState createState() => _ChooseRideState();
}

class _ChooseRideState extends State<ChooseRide> {
  String selectedType = 'Car';

  final Map<String, List<Map<String, String>>> vehicleData = {
    'Car': [
      {
        'name': 'Suzuki Wagon R',
        'image': 'https://th.bing.com/th/id/OIP.8i4QnFe7JRYUGznMl3rAmAHaFa?rs=1&pid=ImgDetMain',
        'price': 'LKR 900'
      },
      {
        'name': 'Toyota Aqua',
        'image': 'https://th.bing.com/th/id/OIP.8i4QnFe7JRYUGznMl3rAmAHaFa?rs=1&pid=ImgDetMain',
        'price': 'LKR 1000'
      },
      {
        'name': 'Nissan Leaf',
        'image': 'https://th.bing.com/th/id/OIP.8i4QnFe7JRYUGznMl3rAmAHaFa?rs=1&pid=ImgDetMain',
        'price': 'LKR 1100'
      },
    ],
    'Van': [
      {
        'name': 'Toyota Hiace',
        'image': 'https://static.vecteezy.com/system/resources/previews/035/976/525/original/ai-generated-a-cartoon-van-free-png.png',
        'price': 'LKR 2500'
      },
      {
        'name': 'Nissan Caravan',
        'image': 'https://static.vecteezy.com/system/resources/previews/035/976/525/original/ai-generated-a-cartoon-van-free-png.png',
        'price': 'LKR 2700'
      },
    ],
    'Bus': [
      {
        'name': 'Leyland Bus',
        'image': 'https://pngimg.com/d/bus_PNG101205.png',
        'price': 'LKR 4000'
      },
      {
        'name': 'Tata Bus',
        'image': 'https://pngimg.com/d/bus_PNG101205.png',
        'price': 'LKR 3800'
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> vehicles = vehicleData[selectedType]!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Choose Ride', style: TextStyle(color: Colors.orange)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ride Info (Static Example)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage('https://lk-aps.bmscdn.com/events/eventlisting/ET00005204.jpg'),
                ),
                title: Text('Kalaa Tharanaya', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Keells - Colombo 4 to Kalaa Tharanaya, Colombo 10'),
              ),
            ),
          ),

          // Vehicle Type Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Text('Choose Vehicle Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 15),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: vehicleData.keys.map((type) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedType = type;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: selectedType == type ? Colors.orange : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        color: selectedType == type ? Colors.white : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 16),

          // Vehicle List
          Expanded(
            child: ListView.builder(
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        vehicle['image']!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.broken_image, size: 60, color: Colors.red),
                      ),
                    ),
                    title: Text(vehicle['name']!, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(vehicle['price']!),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.orange),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CarBookingPage(vehicle: vehicle),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
