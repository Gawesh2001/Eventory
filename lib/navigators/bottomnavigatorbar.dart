import 'package:flutter/material.dart';
import 'package:eventory/screnns/home/home.dart';
import 'package:eventory/screnns/transportation/transportation.dart';
import 'package:eventory/screnns/Market/market.dart';
import '../screnns/otherscreens/userprofile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BottomNavigatorBar extends StatefulWidget {
  final int currentIndex;
  final String userId;

  const BottomNavigatorBar(
      {Key? key, required this.userId, required this.currentIndex})
      : super(key: key);

  @override
  State<BottomNavigatorBar> createState() => _BottomNavigatorBarState();
}

class _BottomNavigatorBarState extends State<BottomNavigatorBar> {
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
  }

  @override
  Widget build(BuildContext context) {
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
            ),
          ],
        ),
      ),
    );
  }
}
