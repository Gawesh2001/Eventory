import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eventory/helpers/theme_helper.dart';

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
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
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
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunch(phoneUri.toString())) {
      await launch(phoneUri.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
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
    }
  }

  void _showCallConfirmationDialog(String phoneNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _makePhoneCall(phoneNumber);
            },
            child: Text(
              "Call",
              style: GoogleFonts.poppins(
                color: AppColors.orangePrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _parseFacilities(String description) {
    String cleanedDescription = description.trim();
    cleanedDescription = cleanedDescription.replaceAll(RegExp(r'^\[|\]$'), '');

    if (cleanedDescription.startsWith(',')) {
      cleanedDescription = cleanedDescription.substring(1).trim();
    }
    if (cleanedDescription.endsWith(',')) {
      cleanedDescription =
          cleanedDescription.substring(0, cleanedDescription.length - 1).trim();
    }

    return cleanedDescription
        .split(',')
        .map((e) => e.trim())
        .where((facility) => facility.isNotEmpty)
        .toList();
  }

  Widget _buildFacilitiesList() {
    List<String> facilities = _parseFacilities(widget.description);

    return Wrap(
      spacing: 8,
      children: facilities.map((facility) {
        return Chip(
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
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
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
    required Offset offset,
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
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        child: PopupMenuButton<String>(
          offset: offset,
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
      backgroundColor: AppColors.scaffoldBackground(context),
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
                ),
                Positioned(
                  top: 40,
                  left: 10,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Color(0xffFF611A)),
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
                  Text(
                    widget.title,
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor(context),
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              color: AppColors.orangePrimary),
                          SizedBox(width: 5),
                          Text(
                            widget.location,
                            style: GoogleFonts.poppins(
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 15),
                      Row(
                        children: [
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
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
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
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
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
                        onPressed: () async {
                          final Uri mapUri = Uri.parse(widget.mapLink);
                          if (await canLaunch(mapUri.toString())) {
                            await launch(mapUri.toString());
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Could not launch the map link.",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: AppColors.orangePrimary,
                              ),
                            );
                          }
                        },
                      ),
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
                                content: Text(
                                  "Could not launch the link.",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: AppColors.orangePrimary,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
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
                          icon:
                              Icon(Icons.send, color: AppColors.orangePrimary),
                          onPressed: _addReview,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
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
                                              color:
                                                  AppColors.textColor(context),
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            _formatTimestamp(
                                                review["timestamp"]),
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color:
                                                  Theme.of(context).hintColor,
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

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp.toDate());
    } else if (timestamp is DateTime) {
      return DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp);
    }
    return "Unknown date";
  }
}
