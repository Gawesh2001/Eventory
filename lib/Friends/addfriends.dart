import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class addFriendsPage extends StatefulWidget {
  final String userId;

  // Constructor to accept userId
  const addFriendsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _AddFriendsPageState createState() => _AddFriendsPageState();
}

class _AddFriendsPageState extends State<addFriendsPage> {
  String? userName;
  String? dpUrl;
  bool isFollowing = false; // For managing follow status
  bool isFollowed = false; // For managing followed status

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  // Method to fetch user details from Firestore
  Future<void> _getUserDetails() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('userDetails')
        .doc(widget.userId)
        .get();

    if (userDoc.exists && userDoc.data() != null) {
      setState(() {
        userName = userDoc['userName'];
        dpUrl = userDoc['dpurl'] ??
            'https://img.freepik.com/premium-vector/professional-male-avatar-profile-picture-employee-work_1322206-66590.jpg'; // Default image
      });
    }
  }

  // Method to handle follow/unfollow functionality
  void _toggleFollow() {
    setState(() {
      isFollowing = !isFollowing;
    });

    // You could update Firestore to track follow status if required
    // FirebaseFirestore.instance.collection('userDetails').doc(widget.userId)
    //     .update({'following': isFollowing});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Friends"),
        backgroundColor: Color(0xff121212),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Color(0xff121212),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // User Info Container
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: dpUrl != null && dpUrl!.isNotEmpty
                          ? NetworkImage(dpUrl!)
                          : AssetImage('assets/profile.png') as ImageProvider,
                      backgroundColor: Colors.grey[800],
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName ??
                                'Loading...', // Show username if available
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ElevatedButton(
                                onPressed: _toggleFollow,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isFollowing ? Colors.grey : Colors.orange,
                                ),
                                child:
                                    Text(isFollowing ? 'Following' : 'Follow'),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {
                                  // Handle "Followed" action (or add additional functionality here)
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isFollowed ? Colors.grey : Colors.orange,
                                ),
                                child: Text('Followed'),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Additional UI content can go here
              Text(
                'User ID: ${widget.userId}',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
