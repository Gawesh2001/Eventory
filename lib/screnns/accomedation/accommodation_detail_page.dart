import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
<<<<<<< HEAD
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eventory/helpers/theme_helper.dart';
=======
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f

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
<<<<<<< HEAD
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
=======
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
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f

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
<<<<<<< HEAD
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Review added successfully!",
            style: GoogleFonts.poppins(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.orangePrimary,
        ),
      );
=======
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Review added successfully!")));
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
<<<<<<< HEAD
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Copied to clipboard: $text",
          style: GoogleFonts.poppins(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.orangePrimary,
      ),
    );
=======
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Copied to clipboard: $text")));
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunch(phoneUri.toString())) {
      await launch(phoneUri.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
<<<<<<< HEAD
        SnackBar(
          content: Text(
            "Could not launch the phone app.",
            style: GoogleFonts.poppins(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.orangePrimary,
        ),
      );
=======
          SnackBar(content: Text("Could not launch the phone app.")));
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
    }
  }

  void _showCallConfirmationDialog(String phoneNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
<<<<<<< HEAD
        title: Text(
          "Call $phoneNumber?",
          style: GoogleFonts.poppins(
            color: AppColors.textColor(context),
          ),
        ),
        content: Text(
          "Are you sure you want to call this number?",
          style: GoogleFonts.poppins(
            color: AppColors.textColor(context),
          ),
        ),
        backgroundColor: AppColors.cardColor(context),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(
                color: AppColors.orangePrimary,
              ),
            ),
=======
        title: Text("Call $phoneNumber?"),
        content: Text("Are you sure you want to call this number?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _makePhoneCall(phoneNumber);
            },
<<<<<<< HEAD
            child: Text(
              "Call",
              style: GoogleFonts.poppins(
                color: AppColors.orangePrimary,
              ),
            ),
=======
            child: Text("Call"),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
          ),
        ],
      ),
    );
  }

  List<String> _parseFacilities(String description) {
<<<<<<< HEAD
    String cleanedDescription = description.trim();
    cleanedDescription = cleanedDescription.replaceAll(RegExp(r'^\[|\]$'), '');

=======
    // Strip any leading or trailing spaces and commas from the description string
    String cleanedDescription = description.trim();

    // Remove any leading or trailing commas and brackets
    cleanedDescription = cleanedDescription.replaceAll(RegExp(r'^\[|\]$'), '');

    // Remove any leading or trailing commas
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
    if (cleanedDescription.startsWith(',')) {
      cleanedDescription = cleanedDescription.substring(1).trim();
    }
    if (cleanedDescription.endsWith(',')) {
      cleanedDescription =
          cleanedDescription.substring(0, cleanedDescription.length - 1).trim();
    }

<<<<<<< HEAD
    return cleanedDescription
        .split(',')
        .map((e) => e.trim())
        .where((facility) => facility.isNotEmpty)
=======
    // Now split by commas and return the facilities list
    return cleanedDescription
        .split(',')
        .map((e) => e.trim())
        .where((facility) => facility.isNotEmpty) // Ensure no empty entries
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
        .toList();
  }

  Widget _buildFacilitiesList() {
    List<String> facilities = _parseFacilities(widget.description);

    return Wrap(
      spacing: 8,
      children: facilities.map((facility) {
        return Chip(
<<<<<<< HEAD
          label: Text(
            facility,
            style: GoogleFonts.poppins(
              color: AppColors.orangePrimary,
            ),
          ),
          backgroundColor: AppColors.cardColor(context),
          side: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
=======
          label: Text(facility, style: TextStyle(color: Colors.orange[700])),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
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
<<<<<<< HEAD
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
=======
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
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
<<<<<<< HEAD
    required Offset offset,
=======
    required Offset offset, // Add this parameter
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
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
<<<<<<< HEAD
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        child: PopupMenuButton<String>(
          offset: offset,
=======
        ),
        child: PopupMenuButton<String>(
          offset: offset, // Use the passed offset
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
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
<<<<<<< HEAD
      backgroundColor: AppColors.scaffoldBackground(context),
=======
      backgroundColor: Colors.white,
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
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
<<<<<<< HEAD
                  child: Image.network(
                    widget.imageUrl,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 250,
                      color: Theme.of(context).hoverColor,
                      child: Icon(
                        Icons.error,
                        color: AppColors.textColor(context),
                      ),
                    ),
                  ),
=======
                  child: Image.network(widget.imageUrl,
                      width: double.infinity, height: 250, fit: BoxFit.cover),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                ),
                Positioned(
                  top: 40,
                  left: 10,
                  child: IconButton(
<<<<<<< HEAD
                    icon: Icon(Icons.arrow_back, color: Color(0xffFF611A)),
=======
                    icon: Icon(Icons.arrow_back, color: Colors.white),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
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
<<<<<<< HEAD
                  Text(
                    widget.title,
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor(context),
                    ),
                  ),
=======
                  Text(widget.title,
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Row(
                        children: [
<<<<<<< HEAD
                          Icon(Icons.location_on, color: AppColors.orangePrimary),
                          SizedBox(width: 5),
                          Text(
                            widget.location,
                            style: GoogleFonts.poppins(
                              color: Theme.of(context).hintColor,
                            ),
                          ),
=======
                          Icon(Icons.location_on, color: Colors.orange[700]),
                          SizedBox(width: 5),
                          Text(widget.location,
                              style: TextStyle(color: Colors.grey[700])),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                        ],
                      ),
                      SizedBox(width: 15),
                      Row(
                        children: [
<<<<<<< HEAD
                          Icon(Icons.star, color: AppColors.orangePrimary),
                          SizedBox(width: 5),
                          Text(
                            widget.rating.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor(context),
                            ),
                          ),
=======
                          Icon(Icons.star, color: Colors.orange[700]),
                          SizedBox(width: 5),
                          Text(widget.rating.toString(),
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
<<<<<<< HEAD
                  Text(
                    "Facilities",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor(context),
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildFacilitiesList(),
                  Divider(
                    color: Theme.of(context).dividerColor,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "LKR ${widget.price} / night",
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.orangePrimary,
                    ),
                  ),
                  SizedBox(height: 20),
                  Divider(
                    color: Theme.of(context).dividerColor,
                  ),
=======
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

>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
<<<<<<< HEAD
                      _buildRoundedButton(
                        icon: Icons.phone,
                        color: AppColors.orangePrimary,
                        onPressed: () =>
                            _showCallConfirmationDialog(widget.contact),
                      ),
                      _buildRoundedButton(
                        icon: Icons.email,
                        color: AppColors.orangePrimary,
                        onPressed: () =>
                            _copyToClipboard(context, widget.email),
                      ),
                      _buildRoundedButton(
                        icon: Icons.location_pin,
                        color: AppColors.orangePrimary,
=======
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
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                        onPressed: () async {
                          final Uri mapUri = Uri.parse(widget.mapLink);
                          if (await canLaunch(mapUri.toString())) {
                            await launch(mapUri.toString());
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
<<<<<<< HEAD
                                content: Text(
                                  "Could not launch the map link.",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: AppColors.orangePrimary,
                              ),
=======
                                  content:
                                      Text("Could not launch the map link.")),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                            );
                          }
                        },
                      ),
<<<<<<< HEAD
                      _buildRoundedPopupMenu(
                        offset: Offset(38, 55),
                        icon: Icons.language,
                        color: AppColors.orangePrimary,
                        menuItems: [
                          PopupMenuItem<String>(
                            value: "website",
                            child: Text(
                              "Website",
                              style: GoogleFonts.poppins(
                                color: AppColors.textColor(context),
                              ),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: "socialMedia",
                            child: Text(
                              "Social Media",
                              style: GoogleFonts.poppins(
                                color: AppColors.textColor(context),
                              ),
                            ),
=======
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
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
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
<<<<<<< HEAD
                                content: Text(
                                  "Could not launch the link.",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: AppColors.orangePrimary,
                              ),
=======
                                  content: Text("Could not launch the link.")),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
<<<<<<< HEAD
                  Divider(
                    color: Theme.of(context).dividerColor,
                  ),
                  Text(
                    "Reviews",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor(context),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _reviewController,
                      style: GoogleFonts.poppins(
                        color: AppColors.textColor(context),
                      ),
                      decoration: InputDecoration(
                        hintText: "Write a review...",
                        hintStyle: GoogleFonts.poppins(
                          color: Theme.of(context).hintColor,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.send, color: AppColors.orangePrimary),
                          onPressed: _addReview,
                        ),
=======
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
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
<<<<<<< HEAD
                  _reviews.isEmpty
                      ? Center(
                    child: Text(
                      "No reviews yet.",
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  )
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _reviews.length,
                    itemBuilder: (context, index) {
                      final review = _reviews[index];
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.cardColor(context),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.orangePrimary,
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      review["reviewer"],
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.orangePrimary,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      review["text"],
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: AppColors.textColor(context),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      _formatTimestamp(
                                          review["timestamp"]),
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Theme.of(context).hintColor,
=======
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
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                                      ),
                                    ),
                                  ],
                                ),
                              ),
<<<<<<< HEAD
                            ],
                          ),
                        ),
                      );
                    },
                  ),
=======
                            );
                          },
                        ),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
=======
  // Helper function to format the timestamp
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp.toDate());
    } else if (timestamp is DateTime) {
      return DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp);
    }
    return "Unknown date";
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
