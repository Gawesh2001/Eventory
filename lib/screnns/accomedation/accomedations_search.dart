import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventory/screnns/accomedation/add_accomedations.dart';
import 'package:eventory/screnns/accomedation/components.dart';
import 'package:flutter/material.dart';

class AccomedationsSearch extends StatefulWidget {
  const AccomedationsSearch({super.key});

  @override
  State<AccomedationsSearch> createState() => _AccomedationsSearchState();
}

class _AccomedationsSearchState extends State<AccomedationsSearch> {
  String? selectedEvent;
  String eventLocation = "";
  List<String> eventList = [];

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    QuerySnapshot eventSnapshot =
        await FirebaseFirestore.instance.collection('events').get();
    setState(() {
      eventList =
          eventSnapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  Future<void> fetchEventLocation(String eventName) async {
    QuerySnapshot eventSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('name', isEqualTo: eventName)
        .get();

    if (eventSnapshot.docs.isNotEmpty) {
      setState(() {
        eventLocation = eventSnapshot.docs.first['location'];
      });
    }
  }

  Stream<QuerySnapshot> fetchAccommodations() {
    return FirebaseFirestore.instance
        .collection('accommodations')
        .where('event', isEqualTo: selectedEvent)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: CustomAppBar(
        title: "",
        profileImageUrl:
            "https://play-lh.googleusercontent.com/i8fGO7LrghUKcBCijVf09Vy_FET5-tCh35O6FTFjkHUMixnCRokmaKMZOKNvf4k2P3Y=w600-h300-pc0xffffff-pd",
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            ToggleButtonsWidget(activeIndex: 0, onToggle: (index) {}),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const TitleText(text: "Find your stay here!"),
                IconButton(
                  icon: Icon(Icons.add, size: 28, color: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddAccommodationPage()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DropdownButtonFormField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: "Select Event"),
                items: eventList.map((String event) {
                  return DropdownMenuItem(value: event, child: Text(event));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedEvent = value as String?;
                    fetchEventLocation(selectedEvent!);
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: InputField(
                label: "Location",
                icon: Icons.location_pin,
                placeholder: eventLocation,
                isEditable: false,
              ),
            ),
            const SizedBox(height: 10),
            StreamBuilder(
              stream: fetchAccommodations(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text("No accommodations available"));
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
                    return AccommodationCard(
                      imageUrl: data['imageUrl'],
                      title: data['title'],
                      location: data['location'],
                      mapLink: data['mapLink'],
                      rating: data['rating'].toDouble(),
                      minPrice: data['minPrice'],
                      isEventOffer: data['isEventOffer'],
                      contact: data['contact'],
                      email: data['email'],
                      description: data['facilities'],
                      accommodationID: data[''],
                      website: data['website'],
                      socialMedia: data['socialMedia'],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
