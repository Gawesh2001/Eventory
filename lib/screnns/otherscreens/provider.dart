<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:eventory/screnns/accomedation/add_accomedations.dart';
import 'package:eventory/navigators/bottomnavigatorbar.dart';
import 'package:eventory/screnns/otherscreens/add_transportation.dart';
import 'package:eventory/screnns/otherscreens/provider_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eventory/helpers/theme_helper.dart';

class provider extends StatefulWidget {
  final String uid;
  const provider({super.key, required this.uid});

  @override
  State<provider> createState() => _ProviderPortalState();
}

class _ProviderPortalState extends State<provider> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _showContent = false;
  int _selectedService = -1;

  final List<Map<String, dynamic>> _services = [
    {
      'title': 'Transportation',
      'icon': Icons.directions_car,
      'color': Colors.blueAccent,
      'description': 'List your vehicles for event transportation services',
    },
    {
      'title': 'Accommodation',
      'icon': Icons.hotel,
      'color': Colors.orangeAccent,
      'description': 'Add hotels, resorts or rental properties for attendees',
    },
  ];
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() => _showContent = true);
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

=======
// ignore_for_file: camel_case_types, use_key_in_widget_constructors

import 'package:eventory/screnns/accomedation/add_accomedations.dart';
import 'package:flutter/material.dart';
import 'package:eventory/navigators/bottomnavigatorbar.dart';
import 'package:eventory/screnns/otherscreens/add_transportation.dart'; // Import the VehicleRegistration page

class provider extends StatefulWidget {
  final String uid; // Add uid as a parameter
  const provider({super.key, required this.uid}); // Constructor

  @override
  State<provider> createState() => _ProviderState();
}

class _ProviderState extends State<provider> {
  // Method to show rules and regulations in a dialog box
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
  void _showRulesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
<<<<<<< HEAD
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardColor(context),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ],
            ),
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.security, color: AppColors.orangePrimary, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      'Provider Guidelines',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        color: AppColors.orangePrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildRuleItem(Icons.verified_user, 'Verified Information', 'All provided details must be accurate and verifiable'),
                _buildRuleItem(Icons.calendar_today, 'Availability', 'Keep your calendar updated to avoid double bookings'),
                _buildRuleItem(Icons.star_rate, 'Quality Standards', 'Maintain high quality services as per our guidelines'),
                _buildRuleItem(Icons.monetization_on, 'Pricing', 'Be transparent with pricing and avoid hidden charges'),
                const SizedBox(height: 25),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orangePrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      shadowColor: AppColors.orangePrimary.withOpacity(0.4),
                    ),
                    child: Text(
                      'I UNDERSTAND',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 300.ms).scale();
      },
    );
  }

  Widget _buildRuleItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.orangePrimary.withOpacity(0.8)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: AppColors.textColor(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    color: AppColors.textColor(context)?.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToService(int index) {
    setState(() => _selectedService = index);
    Future.delayed(300.ms, () {
      switch (index) {
        case 0:
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  VehicleRegistration(uid: widget.uid),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
          break;
        case 1:
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
              AddAccommodationPage(userId: widget.uid),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
            ),
          );
          break;
      }
    });
  }

  Widget _buildServiceCard(Map<String, dynamic> service, int index) {
    return AnimatedContainer(
      duration: 300.ms,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.cardColor(context),
        border: Border.all(
          color: _selectedService == index
              ? service['color'] as Color
              : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 1,
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToService(index),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: service['color'].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    service['icon'],
                    color: service['color'],
                    size: 24,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  service['title'],
                  style: GoogleFonts.poppins(
                    color: AppColors.textColor(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  service['description'],
                  style: GoogleFonts.poppins(
                    color: AppColors.textColor(context)?.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      "Add New",
                      style: GoogleFonts.poppins(
                        color: service['color'],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: service['color'],
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManageButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProviderManager(uid: widget.uid),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orangePrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          shadowColor: AppColors.orangePrimary.withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.manage_accounts, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              "MANAGE YOUR PROVIDINGS",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 600.ms);
=======
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
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      backgroundColor: AppColors.scaffoldBackground(context),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Provider Portal",
          style: GoogleFonts.poppins(
            color: AppColors.textColor(context),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.orangePrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline_rounded, color: AppColors.orangePrimary),
            onPressed: _showRulesDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 100, bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome, Provider!",
                      style: GoogleFonts.poppins(
                        color: AppColors.textColor(context),
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ).animate().fadeIn(delay: 100.ms).slide(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                      curve: Curves.easeOutCubic,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Choose a service to list on our platform",
                      style: GoogleFonts.poppins(
                        color: AppColors.textColor(context)?.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slide(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                      curve: Curves.easeOutCubic,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Services Grid
              GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: _services.length,
                itemBuilder: (context, index) {
                  final service = _services[index];
                  return _buildServiceCard(service, index);
                },
              ).animate().fadeIn(delay: 300.ms).slide(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
                curve: Curves.easeOutCubic,
              ),

              const SizedBox(height: 30),

              // Manage Button
              _buildManageButton(),

              const SizedBox(height: 30),
=======
      appBar: AppBar(
        title: Text(
          "Provider Access",
          style: TextStyle(
              color: Colors.orange, fontSize: 22, fontWeight: FontWeight.bold),
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
              // Display the user ID
              // Text(
              //   'User ID: ${widget.uid}', // Display the uid passed to this page
              //   style: TextStyle(color: Colors.white, fontSize: 16),
              // ),
              SizedBox(height: 0),
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
                  // Navigate to VehicleRegistration page and pass the uid
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          VehicleRegistration(uid: widget.uid), // Pass uid here
                    ),
                  );
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddAccommodationPage(), // Pass uid here
                    ),
                  );
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
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
            ],
          ),
        ),
      ),
<<<<<<< HEAD
      bottomNavigationBar: BottomNavigatorBar(
        currentIndex: 3,
        userId: widget.uid,
      ),
    );
  }
}
=======
      bottomNavigationBar: BottomNavigatorBar(), // Bottom Navigator Bar
    );
  }
}
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
