// ignore_for_file: use_key_in_widget_constructors, unused_element, unnecessary_brace_in_string_interps, unused_import, unused_field, library_private_types_in_public_api, prefer_final_fields

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventory/navigators/bottomnavigatorbar.dart';
import 'package:eventory/screnns/otherscreens/profileedit.dart';
import 'package:flutter/material.dart';
import 'addevent.dart';
import 'provider.dart'; // Import the provider.dart file
import 'settings.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart'; // Added Firebase import
import 'QRscanpage.dart'; // Import the QR scan page

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  File? _profileImage;
  bool isPublicProfile = false;
  List<File> _photos = []; // List to store photos
  int? _selectedImageIndex; // To track the selected image for enlargement
  User? user; // Added Firebase user reference
  String? username; // Variable to store the username

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser; // Retrieve current Firebase user
    _getUserDetails(); // Fetch user details from Firestore
  }

  // Method to fetch user details (username) from Firestore
  Future<void> _getUserDetails() async {
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('userDetails')
          .doc(user!.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          username = userDoc['userName']; // Fetch username from Firestore
        });
      }
    }
  }

  // Method to pick image from gallery for profile picture
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Method to add a photo to the grid
  Future<void> _addPhotoToGrid() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _photos.add(File(pickedFile.path)); // Add image to grid
      });
    }
  }

  // Method to enlarge the photo when clicked
  void _enlargePhoto(int index) {
    setState(() {
      _selectedImageIndex = index;
    });

    // Navigate to the enlarged photo view
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnlargedPhotoView(
          image: _photos[index],
          onBack: () {
            // Handle back navigation if needed
            setState(() {
              _selectedImageIndex = null; // Go back to the grid view
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: TextStyle(color: Colors.orange, fontSize: 20),
        ),
        backgroundColor: Color(0xff121212),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          if (isPublicProfile)
            IconButton(
              icon: Icon(Icons.add_a_photo, color: Colors.orange),
              onPressed: _addPhotoToGrid,
            ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.orange),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => settings()),
              );
            },
          ),
        ],
      ),
      backgroundColor: Color(0xff121212),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 16),
                  // Profile Picture with Upload Icon
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : AssetImage('assets/profile.png') as ImageProvider,
                        backgroundColor: Colors.grey[800],
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.orange,
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 16),
                  // User Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username ??
                              (user?.uid ??
                                  'UID not available'), // Show username if available, otherwise show UID
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          user?.email ??
                              'Email not available', // Display user email
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Toggle Buttons
              ToggleButtons(
                borderRadius: BorderRadius.circular(30),
                isSelected: [!isPublicProfile, isPublicProfile],
                selectedColor: Colors.black,
                fillColor: Colors.orange,
                color: Colors.white70,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Text("My account", style: TextStyle(fontSize: 16)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child:
                        Text("Public Profile", style: TextStyle(fontSize: 16)),
                  ),
                ],
                onPressed: (index) {
                  setState(() {
                    isPublicProfile = index == 1;
                  });
                },
              ),
              SizedBox(height: 24),
              // Display different content based on selected tab
              isPublicProfile
                  ? _buildPublicProfileGrid()
                  : _buildAccountOptions(),
              SizedBox(height: 16),
              Text(
                'Member since August 2024',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigatorBar(),
    );
  }

  // My Account options layout
  Widget _buildAccountOptions() {
    return Column(
      children: [
        DrawerListTile(
            icon: Icons.edit,
            title: "Edit Profile",
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ProfileEdit()));
            }),
        DrawerListTile(
          icon: Icons.qr_code_scanner,
          title: 'QR Scan',
          onTap: () {
            // Navigate to QR Scan page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => QRScannerScreen()),
            );
          },
        ),
        DrawerListTile(
          icon: Icons.emoji_events,
          title: 'Achievements',
          onTap: () {
            // Navigate to Achievements page
          },
        ),
        DrawerListTile(
          icon: Icons.group,
          title: 'Friends',
          onTap: () {
            // Navigate to Friends page
          },
        ),
        DrawerListTile(
          icon: Icons.event,
          title: 'Events',
          onTap: () {
            // Navigate to Events page
          },
        ),
        DrawerListTile(
          icon: Icons.manage_accounts,
          title: 'Enter Your Event Here',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const addevent()),
            );
          },
        ),
        DrawerListTile(
          icon: Icons.handyman,
          title: 'Become a Provider',
          onTap: () {
            // Pass the uid to the provider.dart page
            if (user != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      provider(uid: user!.uid), // Pass uid here
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User not logged in!')),
              );
            }
          },
        ),
      ],
    );
  }

  // Public Profile grid layout
  Widget _buildPublicProfileGrid() {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _photos.length, // Display the photos added to the grid
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _enlargePhoto(index), // Enlarge photo when clicked
            child: Container(
              color: Colors.grey[800],
              child: Hero(
                tag: 'photo_${index}', // Use unique tag for each photo
                child: Image.file(
                  _photos[index],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Widget for enlarged photo view
class EnlargedPhotoView extends StatelessWidget {
  final File image;
  final VoidCallback onBack;

  const EnlargedPhotoView({Key? key, required this.image, required this.onBack})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onBack,
            child: Image.file(
              image,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

// Drawer List Tile Widget
class DrawerListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const DrawerListTile(
      {Key? key, required this.icon, required this.title, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(title, style: TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}
