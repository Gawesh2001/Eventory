import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddAccommodationPage extends StatefulWidget {
  @override
  _AddAccommodationPageState createState() => _AddAccommodationPageState();
}

class _AddAccommodationPageState extends State<AddAccommodationPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController mapLinkController =
      TextEditingController(); // New controller for Map Link
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController socialMediaController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cancellationPolicyController =
      TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();

  bool isEventOffer = false;
  String? selectedEvent;
  List<Map<String, dynamic>> events = [];
  TimeOfDay? checkInTime;
  TimeOfDay? checkOutTime;

  bool _isLoading = false;

  List<TextEditingController> roomOptions = [];
  List<TextEditingController> facilities = [];

  double rating = 0;

  Future<void> fetchEvents() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('events').get();
    setState(() {
      events = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> _selectTime(BuildContext context, bool isCheckIn) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          checkInTime = picked;
        } else {
          checkOutTime = picked;
        }
      });
    }
  }

  void _addRoomOption() {
    setState(() {
      roomOptions.add(TextEditingController());
    });
  }

  void _addFacility() {
    setState(() {
      facilities.add(TextEditingController());
    });
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          floatingLabelStyle: TextStyle(
            color: Colors.orange, // Label text color when focused
            fontWeight: FontWeight.bold,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.orange, width: 2.0), // Orange border when active
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Colors.grey, width: 1.0), // Normal border
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Generate accommodation ID (A10000001, A10000002, etc.)
  Future<String> generateAccommodationID() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('accommodations')
        .orderBy('accommodationID', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return "A10000001";
    }

    String lastAccommodationID = snapshot.docs.first['accommodationID'];
    int lastNumber = int.parse(lastAccommodationID.substring(1));
    return "A${(lastNumber + 1).toString().padLeft(8, '0')}";
  }

  // Handle form submission
  Future<void> _submitForm() async {
    if (nameController.text.isEmpty ||
        locationController.text.isEmpty ||
        priceController.text.isEmpty ||
        contactController.text.isEmpty ||
        emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String accommodationID = await generateAccommodationID();

      // Prepare the data to send to Firestore
      final accommodationData = {
        'accommodationID': accommodationID, // Generated accommodation ID
        'name': nameController.text,
        'location': locationController.text,
        'mapLink': mapLinkController.text, // Add map link to Firestore
        'website': websiteController.text,
        'socialMedia': socialMediaController.text,
        'price': double.tryParse(priceController.text) ?? 0.0,
        'contact': contactController.text,
        'email': emailController.text,
        'cancellationPolicy': cancellationPolicyController.text,
        'imageUrl': imageUrlController.text,
        'rating': rating,
        'checkInTime': checkInTime?.format(context),
        'checkOutTime': checkOutTime?.format(context),
        'isEventOffer': isEventOffer,
        'selectedEvent': selectedEvent,
        'facilities': facilities.map((controller) => controller.text).toList(),
        'feedbacks':
            [], // Empty feedback list (to be added in accommodation detail page)
      };

      // Add to Firestore using the generated accommodationID as the document ID
      await FirebaseFirestore.instance
          .collection('accommodations')
          .doc(accommodationID) // Document ID is accommodationID
          .set(accommodationData); // Use .set() to add data

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Accommodation added successfully!')),
      );

      // Clear the form fields
      nameController.clear();
      locationController.clear();
      mapLinkController.clear(); // Clear map link field
      websiteController.clear();
      socialMediaController.clear();
      priceController.clear();
      contactController.clear();
      emailController.clear();
      cancellationPolicyController.clear();
      imageUrlController.clear();
      setState(() {
        rating = 0;
        isEventOffer = false;
        selectedEvent = null;
        facilities.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add accommodation: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Accommodation'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTextField('Accommodation Name', nameController),
            buildTextField('Location', locationController),
            buildTextField('Map Url (Google Maps Link)',
                mapLinkController), // New Map Link field
            Text('Rating', style: TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: rating,
              min: 0,
              max: 5,
              divisions: 50,
              label: rating.toStringAsFixed(1),
              onChanged: (value) => setState(() => rating = value),
              thumbColor: Colors.orange, // Thumb (circle) color
            ),
            buildTextField('Price (Per Night)', priceController),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Check-in Time:'),
                TextButton(
                  onPressed: () => _selectTime(context, true),
                  child: Text(checkInTime?.format(context) ?? 'Select time'),
                  style: TextButton.styleFrom(foregroundColor: Colors.orange),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Check-out Time:'),
                TextButton(
                  onPressed: () => _selectTime(context, false),
                  child: Text(checkOutTime?.format(context) ?? 'Select time'),
                  style: TextButton.styleFrom(foregroundColor: Colors.orange),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Text('Facilities', style: TextStyle(fontSize: 16)),
            ...facilities
                .map((controller) => buildTextField('Facility', controller))
                .toList(),
            ElevatedButton(
              onPressed: _addFacility,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // Set background color to orange
                foregroundColor:
                    Colors.orange[700], // Set text color to white for contrast
              ),
              child: Text('Add Facility'),
            ),
            SizedBox(
              height: 10,
            ),
            buildTextField('Website (Optional)', websiteController),
            buildTextField(
                'Social Media Links (Optional)', socialMediaController),
            buildTextField('Contact Number', contactController),
            buildTextField('Email', emailController),
            buildTextField('Image URL (Optional)', imageUrlController),
            buildTextField(
                'Cancellation Policy (Optional)', cancellationPolicyController),
            SwitchListTile(
              title: Text('Event Offer'),
              value: isEventOffer,
              activeColor: Colors.orange[700],
              onChanged: (value) {
                setState(() {
                  isEventOffer = value;
                  if (value) fetchEvents();
                });
              },
            ),
            if (isEventOffer && events.isNotEmpty)
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Colors.orange, width: 2.0), // Orange when active
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                value: selectedEvent,
                hint: Text('Select Event'),
                onChanged: (value) => setState(() => selectedEvent = value),
                items: events.map((event) {
                  // Add the 'items' parameter
                  return DropdownMenuItem<String>(
                    value: event['eventID'],
                    child: Text(event['eventName']),
                  );
                }).toList(),
              ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.white, // Set background color to orange
                        foregroundColor: Colors.orange[
                            700], // Set text color to white for contrast
                      ),
                      child: Text('Submit'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
