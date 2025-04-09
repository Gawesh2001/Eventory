<<<<<<< HEAD
=======
import 'package:eventory/screnns/otherscreens/userprofile.dart';
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
import 'package:flutter/material.dart';
import 'package:eventory/screnns/home/home.dart';
import 'package:eventory/screnns/transportation/transportation.dart';
import 'package:eventory/screnns/Market/market.dart';
<<<<<<< HEAD
import '../screnns/otherscreens/userprofile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class BottomNavigatorBar extends StatefulWidget {
  final int currentIndex;
  final String userId;

  const BottomNavigatorBar({Key? key, required this.userId, required this.currentIndex}) : super(key: key);

=======

class BottomNavigatorBar extends StatefulWidget {
  final int currentIndex;

  const BottomNavigatorBar({Key? key, this.currentIndex = 0}) : super(key: key);
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f

  @override
  State<BottomNavigatorBar> createState() => _BottomNavigatorBarState();
}

class _BottomNavigatorBarState extends State<BottomNavigatorBar> {
<<<<<<< HEAD
  late int _selectedIndex;

  late String userId;
  @override
  void initState() {
    super.initState();
    fetchUserId();
    _selectedIndex = widget.currentIndex;
  }

  void fetchUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('userDetails')
          .doc(user.uid)
          .get();
      setState(() {
        userId = userDoc['userId'];
      });
    }
  }
  void _onItemTapped(int index, BuildContext context) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Market(userId: userId),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TransportationPage(userId: userId),
          ),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfile(userId: userId),
          ),
        );
        break;
    }
=======
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Container(
        height: 91,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: isDark ? Colors.grey[900] : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xffFF611A),
          unselectedItemColor: isDark
              ? Colors.grey[400]
              : const Color(0xffFF611A).withOpacity(0.4),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          iconSize: 26,
          onTap: (index) => _onItemTapped(index, context),
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.home_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.home_filled),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.shopping_bag_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.shopping_bag),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.directions_bus_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.directions_bus),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.person_outline),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.person),
              ),
              label: '',
=======
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => _onItemTapped(index, context),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.deepOrangeAccent,
          selectedItemColor:
              const Color.fromARGB(255, 245, 243, 243), // Selected icon color
          unselectedItemColor:
              const Color.fromARGB(255, 253, 253, 253), // Unselected icon color
          selectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          elevation: 0,
          items: [
            _buildNavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'Home',
            ),
            _buildNavItem(
              icon: Icons.directions_bus_outlined,
              activeIcon: Icons.directions_bus_rounded,
              label: 'Transport',
            ),
            _buildNavItem(
              icon: Icons.shopping_bag_outlined,
              activeIcon: Icons.shopping_bag_rounded,
              label: 'Market',
            ),
            _buildNavItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person_rounded,
              label: 'Profile',
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
            ),
          ],
        ),
      ),
    );
  }
<<<<<<< HEAD
}
=======

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    return BottomNavigationBarItem(
      icon: Icon(icon, size: 24),
      activeIcon:
          Icon(activeIcon, size: 26), // No background color on selection
      label: label,
    );
  }

  void _onItemTapped(int index, BuildContext context) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const Home(),
            transitionDuration: Duration.zero,
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const TransportationPage(),
            transitionDuration: Duration.zero,
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const Market(userId: ''),
            transitionDuration: Duration.zero,
          ),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const UserProfile(
              userId: '',
            ),
            transitionDuration: Duration.zero,
          ),
        );
        break;
    }
  }
}
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
