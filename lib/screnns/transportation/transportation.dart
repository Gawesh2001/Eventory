import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:eventory/screnns/accomedation/add_accomedations.dart';
import 'package:eventory/screnns/accomedation/components.dart';
import 'package:eventory/screnns/transportation/bookride.dart';
import 'package:eventory/screnns/transportation/register.dart';
import 'package:eventory/screnns/otherscreens/userprofile.dart';
import 'package:eventory/navigators/bottomnavigatorbar.dart';

class TransportationPage extends StatefulWidget {
  final String userId;

  const TransportationPage({super.key, required this.userId});

  @override
  _TransportationPageState createState() => _TransportationPageState();
}

class _TransportationPageState extends State<TransportationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, String>> eventList = [];
  String? selectedEvent;
  String eventLocation = "";
  bool _isLoadingEvents = true;
  bool _isLoadingAccommodations = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    _tabController.addListener(() {
      setState(() {});
    });
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    setState(() {
      _isLoadingEvents = true;
    });

    try {
      QuerySnapshot eventSnapshot =
          await FirebaseFirestore.instance.collection('events').get();
      setState(() {
        eventList = eventSnapshot.docs
            .map((doc) => {
                  'eventName': doc['eventName'].toString(),
                  'eventID': doc.id,
                })
            .toList();
        _isLoadingEvents = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingEvents = false;
      });
    }
  }

  Future<void> fetchEventLocation(String eventID) async {
    DocumentSnapshot eventDoc = await FirebaseFirestore.instance
        .collection('events')
        .doc(eventID)
        .get();

    if (eventDoc.exists) {
      setState(() {
        eventLocation = eventDoc['eventVenue'];
      });
    }
  }

  Stream<QuerySnapshot> fetchAccommodations() {
    Query query = FirebaseFirestore.instance.collection('accommodations');

    if (selectedEvent != null) {
      query = query.where('selectedEvent', isEqualTo: selectedEvent);
    }

    return query.snapshots();
  }

  Widget _buildEventDropdown() {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Color(0xffFF611A),
            width: 2.0,
          ),
        ),
        labelText: "Select Event",
        labelStyle: GoogleFonts.poppins(
          color: Theme.of(context).hintColor,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: eventList.map((event) {
        return DropdownMenuItem(
          value: event['eventID'],
          child: Text(
            event['eventName']!,
            style: GoogleFonts.poppins(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedEvent = value as String?;
          fetchEventLocation(selectedEvent!);
        });
      },
    );
  }

  Widget _buildLocationField() {
    return TextField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).cardColor,
        labelText: "Location",
        labelStyle: GoogleFonts.poppins(
          color: Theme.of(context).hintColor,
        ),
        hintText: eventLocation,
        hintStyle: GoogleFonts.poppins(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        enabled: false,
        prefixIcon: Icon(
          Icons.location_pin,
          color: Theme.of(context).hintColor,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).hoverColor!,
        highlightColor: Theme.of(context).highlightColor!,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).cardColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccommodationGrid() {
    return StreamBuilder(
      stream: fetchAccommodations(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.6,
            ),
            itemBuilder: (context, index) {
              return _buildShimmerCard();
            },
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Column(
            children: [
              const SizedBox(height: 40),
              Icon(
                Icons.hotel_outlined,
                size: 80,
                color: Theme.of(context).hintColor,
              ),
              const SizedBox(height: 20),
              Text(
                "No accommodations available",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.6,
          ),
          itemBuilder: (context, index) {
            var data = snapshot.data!.docs[index];
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: AccommodationCard(
                key: ValueKey(data.id),
                imageUrl: data['imageUrl'],
                title: data['name'],
                location: data['location'],
                mapLink: data['mapLink'],
                rating: data['rating'].toDouble(),
                minPrice: data['price'].toInt(),
                isEventOffer: data['isEventOffer'],
                contact: data['contact'],
                email: data['email'],
                description: data['facilities'].toString(),
                accommodationID: data['accommodationID'],
                website: data['website'],
                socialMedia: data['socialMedia'],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTransportCard(QueryDocumentSnapshot event) {
    final eventDate = event['selectedDateTime'].toDate();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: event['eventPhoto']['url'] ?? event['imageUrl'],
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Theme.of(context).hoverColor,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xffFF611A)),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['eventName'],
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 18, color: Theme.of(context).hintColor),
                        SizedBox(width: 8),
                        Text(
                          event['eventVenue'],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 18, color: Theme.of(context).hintColor),
                        SizedBox(width: 8),
                        Text(
                          DateFormat('EEE, MMM d • h:mm a').format(eventDate),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _navigateToRegister(event.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xffFF611A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14),
                              elevation: 4,
                              shadowColor: Color(0xffFF611A).withOpacity(0.3),
                            ),
                            child: Text(
                              "OFFER RIDE",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _navigateToBook(event.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal[600],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14),
                              elevation: 4,
                              shadowColor: Colors.teal.withOpacity(0.3),
                            ),
                            child: Text(
                              "BOOK RIDE",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  void _navigateToRegister(String eventId) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => RegisterVehiclePage(
          userId: widget.userId,
          eventId: eventId,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  void _navigateToBook(String eventId) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => Bookride(
          userId: widget.userId,
          eventId: eventId,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.5),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutQuart,
            )),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Transport & Stay',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              width: 3.0,
              color: Color(0xffFF611A),
            ),
          ),
          labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'Accommodation'),
            Tab(text: 'Transportation'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Find your stay here!",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xffFF611A),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) =>
                                  AddAccommodationPage(userId: widget.userId),
                              transitionsBuilder: (_, animation, __, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xffFF611A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add,
                                size: 20, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              'Add',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildEventDropdown(),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildLocationField(),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildAccommodationGrid(),
                ),
              ],
            ),
          ),
          _isLoadingEvents
              ? ListView.builder(
                  itemCount: 3,
                  itemBuilder: (_, i) => _buildShimmerCard(),
                )
              : StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('events')
                      .where('condi', isEqualTo: 'yes')
                      .snapshots(),
                  builder: (_, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return ListView.builder(
                        itemCount: 3,
                        itemBuilder: (_, i) => _buildShimmerCard(),
                      );
                    }
                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (_, index) {
                        final event = snapshot.data!.docs[index];
                        return _buildTransportCard(event);
                      },
                    );
                  },
                ),
        ],
      ),
      bottomNavigationBar: BottomNavigatorBar(
        currentIndex: 2,
        userId: widget.userId,
      ),
    );
  }
}
