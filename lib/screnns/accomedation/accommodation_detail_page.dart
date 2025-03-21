import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

class AccommodationDetailsPage extends StatefulWidget {
  final String accommodationId;
  final String imageUrl;
  final String title;
  final String location;
  final String mapLink;
  final double rating;
  final int price;
  final String contact;
  final String email;
  final String description;
  final String website;
  final String socialMedia;

  const AccommodationDetailsPage(
      {super.key,
      required this.accommodationId,
      required this.imageUrl,
      required this.title,
      required this.location,
      required this.mapLink,
      required this.rating,
      required this.price,
      required this.contact,
      required this.email,
      required this.description,
      required this.website,
      required this.socialMedia});

  @override
  _AccommodationDetailsPageState createState() =>
      _AccommodationDetailsPageState();
}

class _AccommodationDetailsPageState extends State<AccommodationDetailsPage> {
  final TextEditingController _reviewController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _reviews = [];

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  void _fetchReviews() async {
    final snapshot = await _firestore
        .collection("accommodations")
        .doc(widget.accommodationId)
        .collection("reviews")
        .orderBy("timestamp", descending: true)
        .get();

    setState(() {
      _reviews = snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  void _addReview() async {
    if (_reviewController.text.isNotEmpty) {
      final reviewData = {
        "text": _reviewController.text,
        "timestamp": FieldValue.serverTimestamp(),
        "reviewer": "Anonymous",
      };

      await _firestore
          .collection("accommodations")
          .doc(widget.accommodationId)
          .collection("reviews")
          .add(reviewData);

      setState(() {
        _reviews.insert(0, {
          "text": _reviewController.text,
          "timestamp": DateTime.now(),
          "reviewer": "Anonymous",
        });
      });

      _reviewController.clear();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Review added successfully!")));
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Copied to clipboard: $text")));
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunch(phoneUri.toString())) {
      await launch(phoneUri.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not launch the phone app.")));
    }
  }

  void _showCallConfirmationDialog(String phoneNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Call $phoneNumber?"),
        content: Text("Are you sure you want to call this number?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _makePhoneCall(phoneNumber);
            },
            child: Text("Call"),
          ),
        ],
      ),
    );
  }

  List<String> _parseFacilities(String description) {
    // Strip any leading or trailing spaces and commas from the description string
    String cleanedDescription = description.trim();

    // Remove any leading or trailing commas and brackets
    cleanedDescription = cleanedDescription.replaceAll(RegExp(r'^\[|\]$'), '');

    // Remove any leading or trailing commas
    if (cleanedDescription.startsWith(',')) {
      cleanedDescription = cleanedDescription.substring(1).trim();
    }
    if (cleanedDescription.endsWith(',')) {
      cleanedDescription =
          cleanedDescription.substring(0, cleanedDescription.length - 1).trim();
    }

    // Now split by commas and return the facilities list
    return cleanedDescription
        .split(',')
        .map((e) => e.trim())
        .where((facility) => facility.isNotEmpty) // Ensure no empty entries
        .toList();
  }

  Widget _buildFacilitiesList() {
    List<String> facilities = _parseFacilities(widget.description);

    return Wrap(
      spacing: 8,
      children: facilities.map((facility) {
        return Chip(
          label: Text(facility, style: TextStyle(color: Colors.orange[700])),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        );
      }).toList(),
    );
  }

  Widget _buildRoundedButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildRoundedPopupMenu({
    required Offset offset, // Add this parameter
    required IconData icon,
    required Color color,
    required List<PopupMenuEntry<String>> menuItems,
    required void Function(String) onSelected,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: PopupMenuButton<String>(
          offset: offset, // Use the passed offset
          constraints: BoxConstraints(minWidth: 10),
          padding: EdgeInsets.zero,
          icon: Icon(icon, color: Colors.white, size: 24),
          onSelected: onSelected,
          itemBuilder: (BuildContext context) => menuItems,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0)),
                  child: Image.network(widget.imageUrl,
                      width: double.infinity, height: 250, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 40,
                  left: 10,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title,
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.orange[700]),
                          SizedBox(width: 5),
                          Text(widget.location,
                              style: TextStyle(color: Colors.grey[700])),
                        ],
                      ),
                      SizedBox(width: 15),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.orange[700]),
                          SizedBox(width: 5),
                          Text(widget.rating.toString(),
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text("Facilities",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  _buildFacilitiesList(),
                  Divider(),
                  SizedBox(height: 10),
                  Text("LKR ${widget.price} / night",
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700])),
                  SizedBox(height: 20),
                  Divider(),
                  // Contact Info Section

                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Phone Button
                      _buildRoundedButton(
                        icon: Icons.phone,
                        color: Colors.orange[700]!,
                        onPressed: () =>
                            _showCallConfirmationDialog(widget.contact),
                      ),
                      // Email Button
                      _buildRoundedButton(
                        icon: Icons.email,
                        color: Colors.orange[700]!,
                        onPressed: () =>
                            _copyToClipboard(context, widget.email),
                      ),
                      // Map Button
                      _buildRoundedButton(
                        icon: Icons.location_pin,
                        color: Colors.orange[700]!,
                        onPressed: () async {
                          final Uri mapUri = Uri.parse(widget.mapLink);
                          if (await canLaunch(mapUri.toString())) {
                            await launch(mapUri.toString());
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text("Could not launch the map link.")),
                            );
                          }
                        },
                      ),
                      // Website Button
                      _buildRoundedPopupMenu(
                        offset: Offset(
                            38, 55), // Adjust this value to move the menu down
                        icon: Icons.language,
                        color: Colors.orange[700]!,
                        menuItems: [
                          PopupMenuItem<String>(
                            value: "website",
                            child: Text("Website"),
                          ),
                          PopupMenuItem<String>(
                            value: "socialMedia",
                            child: Text("Social Media"),
                          ),
                        ],
                        onSelected: (value) async {
                          Uri? uri;
                          if (value == "website") {
                            uri = Uri.parse(widget.website);
                          } else if (value == "socialMedia") {
                            uri = Uri.parse(widget.socialMedia);
                          }

                          if (uri != null && await canLaunch(uri.toString())) {
                            await launch(uri.toString());
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text("Could not launch the link.")),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Divider(),

                  Text("Reviews",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  TextField(
                    controller: _reviewController,
                    decoration: InputDecoration(
                      hintText: "Write a review...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send, color: Colors.orange[700]),
                        onPressed: _addReview,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Display Reviews from Firestore
                  _reviews.isEmpty
                      ? Center(
                          child: Text("No reviews yet.",
                              style: TextStyle(color: Colors.grey)),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _reviews.length,
                          itemBuilder: (context, index) {
                            final review = _reviews[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Reviewer Avatar
                                    CircleAvatar(
                                      backgroundColor: Colors.orange[700],
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    // Review Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Reviewer Name
                                          Text(
                                            review["reviewer"],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange[700],
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          // Review Text
                                          Text(
                                            review["text"],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          // Timestamp
                                          Text(
                                            _formatTimestamp(
                                                review["timestamp"]),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to format the timestamp
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp.toDate());
    } else if (timestamp is DateTime) {
      return DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp);
    }
    return "Unknown date";
  }
}
