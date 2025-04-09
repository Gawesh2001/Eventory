<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';
import 'package:eventory/Friends/addfriends.dart';
import 'package:eventory/screnns/otherscreens/profileedit.dart';
import 'addevent.dart';
import 'provider.dart';
import 'settings.dart';
import 'QRscanpage.dart';
import 'package:eventory/screnns/otherscreens/event_stats.dart';
import 'package:eventory/screnns/Market/market.dart';
import 'package:eventory/screnns/otherscreens/mytickets.dart';
import 'package:eventory/navigators/bottomnavigatorbar.dart';
import 'package:eventory/helpers/theme_helper.dart'; // Added import

class UserProfile extends StatefulWidget {
  final String userId;

  const UserProfile({Key? key, required this.userId}) : super(key: key);
=======
// ignore_for_file: use_key_in_widget_constructors, unused_element, unnecessary_brace_in_string_interps, unused_import, unused_field, library_private_types_in_public_api, prefer_final_fields

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventory/Friends/addfriends.dart';
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
import 'package:eventory/screnns/Market/market.dart';
import 'package:eventory/screnns/otherscreens/mytickets.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key, required String userId}) : super(key: key);
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f

  @override
  _UserProfileState createState() => _UserProfileState();
}

<<<<<<< HEAD
class _UserProfileState extends State<UserProfile> with SingleTickerProviderStateMixin {
  File? _profileImage;
  bool isPublicProfile = false;
  User? user;
  String? username;
  String? _photoUrl;
  List<File> _photos = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int? _selectedImageIndex;
=======
class _UserProfileState extends State<UserProfile> {
  File? _profileImage;
  bool isPublicProfile = false;
  List<File> _photos = []; // List to store photos
  int? _selectedImageIndex; // To track the selected image for enlargement
  User? user; // Added Firebase user reference
  String? username; // Variable to store the username
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    user = FirebaseAuth.instance.currentUser;
    _getUserDetails();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

=======
    user = FirebaseAuth.instance.currentUser; // Retrieve current Firebase user
    _getUserDetails(); // Fetch user details from Firestore
  }

  String? _photoUrl;
  // Method to fetch user details (username) from Firestore
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
  Future<void> _getUserDetails() async {
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('userDetails')
          .doc(user!.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
<<<<<<< HEAD
          username = userDoc['userName'];
          _photoUrl = (userDoc.data() as Map<String, dynamic>).containsKey('dpurl')
              ? userDoc['dpurl']
              : 'https://img.freepik.com/premium-vector/professional-male-avatar-profile-picture-employee-work_1322206-66590.jpg';
=======
          username = userDoc['userName']; // Fetch username from Firestore
          _photoUrl = userDoc.data() != null &&
                  (userDoc.data() as Map<String, dynamic>).containsKey('dpurl')
              ? userDoc['dpurl']
              : 'https://img.freepik.com/premium-vector/professional-male-avatar-profile-picture-employee-work_1322206-66590.jpg'; // Default image
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
        });
      }
    }
  }

<<<<<<< HEAD
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
=======
  // Method to pick image from gallery for profile picture
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
<<<<<<< HEAD
      _animationController.reset();
      _animationController.forward();
    }
  }

  Future<void> _addPhotoToGrid() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _photos.add(File(pickedFile.path));
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

=======
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
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
  void _enlargePhoto(int index) {
    setState(() {
      _selectedImageIndex = index;
    });
<<<<<<< HEAD
    _showEnlargedPhoto(_photos[index]);
=======

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
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      backgroundColor: AppColors.scaffoldBackground(context),
      appBar: AppBar(
        systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(
            color: AppColors.orangePrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.cardColor(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.orangePrimary),
          onPressed: () => Navigator.pop(context),
=======
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
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
        ),
        actions: [
          if (isPublicProfile)
            IconButton(
<<<<<<< HEAD
              icon: Icon(Icons.add_a_photo, color: AppColors.orangePrimary),
              onPressed: _addPhotoToGrid,
            ),
          IconButton(
            icon: Icon(Icons.settings, color: AppColors.orangePrimary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => settings()),
            ),
          ),
        ],
      ),
=======
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
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
<<<<<<< HEAD
              // Profile Header
              Animate(
                effects: [FadeEffect(), ScaleEffect()],
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor(context),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: Offset(0, 5),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Theme.of(context).hoverColor,
                              backgroundImage: _photoUrl != null && _photoUrl!.isNotEmpty
                                  ? NetworkImage(_photoUrl!)
                                  : AssetImage('assets/profile.png') as ImageProvider,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.orangePrimary,
                                ),
                                child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username ?? user?.uid ?? 'UID not available',
                              style: GoogleFonts.poppins(
                                color: AppColors.textColor(context),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              user?.email ?? 'Email not available',
                              style: GoogleFonts.poppins(
                                color: Theme.of(context).hintColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              // Toggle Buttons
              Animate(
                effects: [FadeEffect(), SlideEffect(begin: Offset(0, 0.2))],
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).hoverColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isPublicProfile = false;
                            });
                            _animationController.reset();
                            _animationController.forward();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isPublicProfile ? Colors.transparent : AppColors.orangePrimary,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: Text(
                                "My Account",
                                style: GoogleFonts.poppins(
                                  color: isPublicProfile ? Theme.of(context).hintColor : Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isPublicProfile = true;
                            });
                            _animationController.reset();
                            _animationController.forward();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isPublicProfile ? AppColors.orangePrimary : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: Text(
                                "Public Profile",
                                style: GoogleFonts.poppins(
                                  color: isPublicProfile ? Colors.white : Theme.of(context).hintColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              // Content Section
              Animate(
                effects: [FadeEffect(), SlideEffect(begin: Offset(0, 0.1))],
                child: isPublicProfile ? _buildPublicProfileGrid() : _buildAccountOptions(),
              ),
              SizedBox(height: 16),
              Text(
                'Member since April 2025',
                style: GoogleFonts.poppins(
                  color: Theme.of(context).hintColor,
                  fontSize: 12,
                ),
=======
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 16),
                  // Profile Picture with Upload Icon
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _photoUrl != null &&
                                _photoUrl!.isNotEmpty
                            ? NetworkImage(_photoUrl!)
                            : AssetImage('assets/profile.png') as ImageProvider,
                        backgroundColor: Colors.grey[800],
                      ),
                      // Positioned(
                      //   bottom: 0,
                      //   right: 0,
                      //   child: GestureDetector(
                      //     onTap: _pickImage,
                      //     child: CircleAvatar(
                      //       radius: 12,
                      //       backgroundColor: Colors.orange,
                      // child: Icon(
                      //   Icons.camera_alt,
                      //   color: Colors.white,
                      //   size: 16,
                      // ),
                      // ),
                      //   ),
                      //  ),
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
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
              ),
            ],
          ),
        ),
      ),
<<<<<<< HEAD
      bottomNavigationBar: BottomNavigatorBar(
        currentIndex: 3,
        userId: widget.userId,
      ),
    );
  }

  Widget _buildAccountOptions() {
    return Column(
      children: [
        _buildProfileOption(
          icon: Icons.edit,
          title: "Edit Profile",
          onTap: () => _navigateWithAnimation(ProfileEdit()),
        ),
        _buildProfileOption(
          icon: Icons.qr_code_scanner,
          title: "QR Scanner",
          onTap: () => _navigateWithAnimation(QRScannerScreen()),
        ),
        _buildProfileOption(
          icon: Icons.person_add,
          title: "Add Friends",
          onTap: () {
            if (user != null) {
              _navigateWithAnimation(AddFriendsPage(userId: user!.uid));
=======
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
          icon: Icons.person_add,
          title: 'Add Friends',
          onTap: () {
            if (user != null) {
              // Navigate to AddFriendsPage and pass userID
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddFriendsPage(userId: user!.uid), // Pass userID here
                ),
              );
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User not logged in!')),
              );
            }
          },
        ),
<<<<<<< HEAD
        _buildProfileOption(
          icon: Icons.store,
          title: "Marketplace",
          onTap: () {
            if (user != null) {
              _navigateWithAnimation(Market(userId: user!.uid));
=======
// Method to navigate to Market page
        DrawerListTile(
          icon: Icons.store,
          title: 'Market place',
          onTap: () {
            if (user != null) {
              // Pass the userId when navigating to the Market page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      Market(userId: user!.uid), // Pass userId here
                ),
              );
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User not logged in!')),
              );
            }
          },
        ),
<<<<<<< HEAD
        _buildProfileOption(
          icon: Icons.confirmation_number,
          title: "My Tickets",
          onTap: () {
            if (user != null) {
              _navigateWithAnimation(MyTickets(userId: user!.uid));
=======
        DrawerListTile(
          icon: Icons.confirmation_number,
          title: 'My Tickets',
          onTap: () {
            if (user != null) {
              // Pass the userId when navigating to the My tickets page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MyTickets(userId: user!.uid), // Pass userId here
                ),
              );
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User not logged in!')),
              );
            }
          },
        ),
<<<<<<< HEAD
        _buildProfileOption(
          icon: Icons.event,
          title: "Events",
          onTap: () => _navigateWithAnimation(EventStats(userId: user!.uid)),
        ),
        _buildProfileOption(
          icon: Icons.manage_accounts,
          title: "Enter Your Event Here",
          onTap: () => _navigateWithAnimation(addevent(uid: user!.uid)),
        ),
        _buildProfileOption(
          icon: Icons.handyman,
          title: "Become a Provider",
          onTap: () {
            if (user != null) {
              _navigateWithAnimation(provider(uid: user!.uid));
=======

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
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
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

<<<<<<< HEAD
  Widget _buildPublicProfileGrid() {
    return _photos.isEmpty
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library, size: 50, color: Theme.of(context).hintColor),
          SizedBox(height: 16),
          Text(
            "No photos yet",
            style: GoogleFonts.poppins(color: Theme.of(context).hintColor),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: _addPhotoToGrid,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orangePrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text("Add Photo", style: GoogleFonts.poppins(color: Colors.white)),
          ).animate().scale(),
        ],
      ),
    )
        : GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _photos.length,
      itemBuilder: (context, index) {
        return Animate(
          effects: [FadeEffect(), ScaleEffect()],
          child: GestureDetector(
            onTap: () => _enlargePhoto(index),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).hoverColor,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
=======
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
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                child: Image.file(
                  _photos[index],
                  fit: BoxFit.cover,
                ),
              ),
            ),
<<<<<<< HEAD
          ),
        );
      },
    );
  }

  void _showEnlargedPhoto(File image) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Animate(
          effects: [FadeEffect(), SlideEffect(begin: Offset(0, 0.5))],
          child: Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: AppColors.cardColor(context),
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.close, color: Theme.of(context).hintColor),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Photo',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor(context),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _photos.remove(image);
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: InteractiveViewer(
                    panEnabled: true,
                    boundaryMargin: EdgeInsets.all(20),
                    minScale: 0.5,
                    maxScale: 3,
                    child: Center(
                      child: Image.file(image, fit: BoxFit.contain),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileOption({required IconData icon, required String title, required VoidCallback onTap}) {
    return Animate(
      effects: [FadeEffect(), SlideEffect(begin: Offset(0.1, 0))],
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.cardColor(context),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: ListTile(
          leading: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.orangePrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.orangePrimary),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              color: AppColors.textColor(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(Icons.chevron_right, color: Theme.of(context).hintColor),
          onTap: onTap,
        ),
      ),
    );
  }

  void _navigateWithAnimation(Widget page) {
    _animationController.reverse().then((_) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds: 300),
        ),
      ).then((_) => _animationController.forward());
    });
  }
}
=======
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
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
