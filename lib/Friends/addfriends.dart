import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddFriendsPage extends StatefulWidget {
  final String userId;

  const AddFriendsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _AddFriendsPageState createState() => _AddFriendsPageState();
}

class _AddFriendsPageState extends State<AddFriendsPage> {
  String? userName;
  String dpUrl =
      'https://img.freepik.com/premium-vector/professional-male-avatar-profile-picture-employee-work_1322206-66590.jpg';
  int followersCount = 0;
  int followingCount = 0;
  bool isFriend = false;
  bool isLoading = true;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _getUserDetails();
    _getFollowStats();
    _checkFriendshipStatus();
  }

  Future<void> _getUserDetails() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('userDetails')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc['userName'] ?? 'User';
          dpUrl =
              userDoc['dpurl'] ?? dpUrl; // Use existing dpUrl if dpurl is null
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching user details: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _getFollowStats() async {
    try {
      DocumentSnapshot statsDoc = await FirebaseFirestore.instance
          .collection('userDetails')
          .doc(widget.userId)
          .get();

      if (statsDoc.exists) {
        setState(() {
          followersCount = statsDoc['followers'] ?? 0;
          followingCount = statsDoc['following'] ?? 0;
        });
      }
    } catch (e) {
      print("Error fetching follow stats: $e");
    }
  }

  Future<void> _checkFriendshipStatus() async {
    if (currentUserId == null) return;

    try {
      DocumentSnapshot friendDoc = await FirebaseFirestore.instance
          .collection('userDetails')
          .doc(widget.userId)
          .collection('friends')
          .doc(currentUserId)
          .get();

      setState(() {
        isFriend = friendDoc.exists;
      });
    } catch (e) {
      print("Error checking friendship status: $e");
    }
  }

  Future<void> _handleAddFriend() async {
    if (currentUserId == null) return;

    setState(() => isLoading = true);

    try {
      final batch = FirebaseFirestore.instance.batch();

      // Add to current user's following
      batch.set(
        FirebaseFirestore.instance
            .collection('userDetails')
            .doc(currentUserId)
            .collection('following')
            .doc(widget.userId),
        {'timestamp': FieldValue.serverTimestamp()},
      );

      // Add to target user's followers
      batch.set(
        FirebaseFirestore.instance
            .collection('userDetails')
            .doc(widget.userId)
            .collection('followers')
            .doc(currentUserId),
        {'timestamp': FieldValue.serverTimestamp()},
      );

      // Update counters
      batch.update(
        FirebaseFirestore.instance.collection('userDetails').doc(currentUserId),
        {'following': FieldValue.increment(1)},
      );

      batch.update(
        FirebaseFirestore.instance.collection('userDetails').doc(widget.userId),
        {'followers': FieldValue.increment(1)},
      );

      await batch.commit();

      setState(() {
        isFriend = true;
        followersCount++;
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend request sent to ${userName ?? 'user'}')),
      );
    } catch (e) {
      print("Error adding friend: $e");
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send friend request')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Friends", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(dpUrl),
                          backgroundColor: Colors.grey[200],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userName ?? 'User',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStatItem('Followers', followersCount),
                            const SizedBox(width: 20),
                            _buildStatItem('Following', followingCount),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (currentUserId != widget.userId)
                          SizedBox(
                            width: 200,
                            child: ElevatedButton(
                              onPressed: isFriend ? null : _handleAddFriend,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isFriend ? Colors.grey[300] : Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(
                                isFriend ? 'Request Sent' : 'Add Friend',
                                style: TextStyle(
                                  color: isFriend ? Colors.black : Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mutual Friends Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.grey[200]!),
                        bottom: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'People You May Know',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSuggestedFriends(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestedFriends() {
    // This would ideally come from your database
    // For demo purposes, we'll use a static list
    final suggestedFriends = [
      {'name': 'Alex Johnson', 'mutual': 5, 'image': ''},
      {'name': 'Sarah Miller', 'mutual': 12, 'image': ''},
      {'name': 'David Wilson', 'mutual': 3, 'image': ''},
    ];

    return Column(
      children: suggestedFriends.map((friend) {
        return ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[200],
            child: const Icon(Icons.person, color: Colors.grey),
          ),
          title: Text(friend['name'] as String),
          subtitle: Text('${friend['mutual']} mutual friends'),
          trailing: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Add',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }).toList(),
    );
  }
}
