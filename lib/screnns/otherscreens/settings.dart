// ignore_for_file: camel_case_types

import 'package:eventory/screnns/authentication/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:eventory/navigators/bottomnavigatorbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Import the Sign-In page

class settings extends StatefulWidget {
  const settings({super.key});

  @override
  State<settings> createState() => _settingsState();
}

class _settingsState extends State<settings> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  // Function to handle logout with confirmation
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Log Out", style: TextStyle(color: Colors.orange)),
          content: Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _logOut(); // Call the logout function
              },
              child: Text("OK", style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  // Function to handle the logout action
  void _logOut() async {
    try {
      // Log out the user from Firebase
      await FirebaseAuth.instance.signOut();

      // After logging out, navigate to the Sign-In screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => Sign_In()), // Navigate to Sign-In page
      );
    } catch (e) {
      // Handle any error that occurs during logout
      print("Error logging out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xff121212),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Color(0xff121212),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          // Notification setting
          SwitchListTile(
            title: Text(
              "Enable Notifications",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            activeColor: Colors.orange,
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          Divider(color: Colors.grey.shade700, thickness: 0.5),

          // Dark Mode setting
          SwitchListTile(
            title: Text(
              "Dark Mode",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            activeColor: Colors.orange,
            value: _darkModeEnabled,
            onChanged: (bool value) {
              setState(() {
                _darkModeEnabled = value;
              });
            },
          ),
          Divider(color: Colors.grey.shade700, thickness: 0.5),

          // Account privacy setting
          ListTile(
            title: Text(
              "Account Privacy",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            trailing:
                Icon(Icons.arrow_forward_ios, color: Colors.orange, size: 20),
            onTap: () {
              // Navigate to Account Privacy settings page if implemented
            },
          ),
          Divider(color: Colors.grey.shade700, thickness: 0.5),

          // Help & Support setting
          ListTile(
            title: Text(
              "Help & Support",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            trailing:
                Icon(Icons.arrow_forward_ios, color: Colors.orange, size: 20),
            onTap: () {
              // Navigate to Help & Support page if implemented
            },
          ),
          Divider(color: Colors.grey.shade700, thickness: 0.5),

          // Logout option
          ListTile(
            title: Text(
              "Log Out",
              style: TextStyle(color: Colors.redAccent, fontSize: 16),
            ),
            trailing: Icon(Icons.logout, color: Colors.redAccent, size: 20),
            onTap: () {
              _confirmLogout(context);
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigatorBar(),
    );
  }
}
