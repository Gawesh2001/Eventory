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
import 'package:eventory/helpers/theme_helper.dart';

class UserProfile extends StatefulWidget {
  final String userId;

  const UserProfile({Key? key, required this.userId}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with SingleTickerProviderStateMixin {
  File? _profileImage;
  bool isPublicProfile = false;
  User? user;
  String? username;
  String? _photoUrl;
  List<File> _photos = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int? _selectedImageIndex;

  @override
  void initState() {
    super.initState();
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

  Future<void> _getUserDetails() async {
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('userDetails')
          .doc(user!.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          username = userDoc['userName'];
          _photoUrl = (userDoc.data() as Map<String, dynamic>)
                  .containsKey('dpurl')
              ? userDoc['dpurl']
              : 'https://img.freepik.com/premium-vector/professional-male-avatar-profile-picture-employee-work_1322206-66590.jpg';
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  Future<void> _addPhotoToGrid() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _photos.add(File(pickedFile.path));
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _enlargePhoto(int index) {
    setState(() {
      _selectedImageIndex = index;
    });
    _showEnlargedPhoto(_photos[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        ),
        actions: [
          if (isPublicProfile)
            IconButton(
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
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
                              backgroundImage:
                                  _photoUrl != null && _photoUrl!.isNotEmpty
                                      ? NetworkImage(_photoUrl!)
                                      : AssetImage('assets/profile.png')
                                          as ImageProvider,
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
                                child: Icon(Icons.camera_alt,
                                    size: 16, color: Colors.white),
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
                              color: isPublicProfile
                                  ? Colors.transparent
                                  : AppColors.orangePrimary,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: Text(
                                "My Account",
                                style: GoogleFonts.poppins(
                                  color: isPublicProfile
                                      ? Theme.of(context).hintColor
                                      : Colors.white,
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
                              color: isPublicProfile
                                  ? AppColors.orangePrimary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: Text(
                                "Public Profile",
                                style: GoogleFonts.poppins(
                                  color: isPublicProfile
                                      ? Colors.white
                                      : Theme.of(context).hintColor,
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
                child: isPublicProfile
                    ? _buildPublicProfileGrid()
                    : _buildAccountOptions(),
              ),
              SizedBox(height: 16),
              Text(
                'Member since April 2025',
                style: GoogleFonts.poppins(
                  color: Theme.of(context).hintColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
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
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User not logged in!')),
              );
            }
          },
        ),
        _buildProfileOption(
          icon: Icons.store,
          title: "Marketplace",
          onTap: () {
            if (user != null) {
              _navigateWithAnimation(Market(userId: user!.uid));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User not logged in!')),
              );
            }
          },
        ),
        _buildProfileOption(
          icon: Icons.confirmation_number,
          title: "My Tickets",
          onTap: () {
            if (user != null) {
              _navigateWithAnimation(MyTickets(userId: user!.uid));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User not logged in!')),
              );
            }
          },
        ),
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

  Widget _buildPublicProfileGrid() {
    return _photos.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library,
                    size: 50, color: Theme.of(context).hintColor),
                SizedBox(height: 16),
                Text(
                  "No photos yet",
                  style:
                      GoogleFonts.poppins(color: Theme.of(context).hintColor),
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
                  child: Text("Add Photo",
                      style: GoogleFonts.poppins(color: Colors.white)),
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
                      child: Image.file(
                        _photos[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
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
                        icon: Icon(Icons.close,
                            color: Theme.of(context).hintColor),
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

  Widget _buildProfileOption(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
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
          trailing:
              Icon(Icons.chevron_right, color: Theme.of(context).hintColor),
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
