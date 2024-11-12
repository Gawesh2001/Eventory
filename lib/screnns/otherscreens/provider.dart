// ignore_for_file: camel_case_types, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:eventory/navigators/bottomnavigatorbar.dart';

class provider extends StatefulWidget {
  const provider({super.key});

  @override
  State<provider> createState() => _ProviderState();
}

class _ProviderState extends State<provider> {
  // Method to show rules and regulations in a dialog box
  void _showRulesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Rules and Regulations',
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
          content: Text(
            '1. Please provide accurate information.\n'
            '2. Ensure all added services are valid and within terms.\n'
            '3. Respect user privacy and avoid sharing sensitive data.\n\n'
            'Failure to adhere to these rules may result in a suspension of provider privileges.',
            style: TextStyle(color: Colors.white70),
          ),
          backgroundColor: Color(0xff222222),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          actions: [
            TextButton(
              child: Text("OK", style: TextStyle(color: Colors.orange)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "Provider Access",
            style: TextStyle(
                color: Colors.orange,
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
          backgroundColor: Color(0xff121212),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.orange),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.info_outline, color: Colors.orange),
              onPressed: _showRulesDialog, // Call the rules dialog method
            ),
          ],
        ),
        backgroundColor: Color(0xff121212),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Display image at the top
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    'https://render.fineartamerica.com/images/images-profile-flow/400/images/artworkimages/mediumlarge/3/1-jeep-with-surfboards-on-hawaiian-beach-by-asar-studios-celestial-images.jpg',
                    width: 300,
                    height: 400,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 20),
                // Add Transportation Button
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to Add Transportation page
                  },
                  icon: Icon(Icons.local_shipping, color: Colors.white),
                  label: Text(
                    "Add Transportation",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    backgroundColor: Colors.orange,
                    shadowColor: Colors.orangeAccent,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Add Accommodation Button
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to Add Accommodation page
                  },
                  icon: Icon(Icons.hotel, color: Colors.white),
                  label: Text(
                    "Add Accommodation",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    backgroundColor: Colors.orange,
                    shadowColor: Colors.orangeAccent,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigatorBar(), // Bottom Navigator Bar
      ),
    );
  }
}
