// ignore_for_file: camel_case_types, sort_child_properties_last, use_build_context_synchronously, library_private_types_in_public_api, prefer_final_fields, use_key_in_widget_constructors, unused_import, depend_on_referenced_packages, unused_element, avoid_print
import 'dart:io';
import 'package:eventory/services/locationpicker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:eventory/navigators/bottomnavigatorbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class addevent extends StatefulWidget {
  const addevent({super.key});

  @override
  State<addevent> createState() => _addeventState();
}

class _addeventState extends State<addevent> {
  final List<String> eventCategories = [
    'Music',
    'Theater',
    'Sport',
    'Movie',
    'Orchestral',
    'Carnival'
  ];
  final Map<String, int> eventCategoryCodes = {
    'Music': 1001,
    'Theater': 1002,
    'Sport': 1003,
    'Movie': 1004,
    'Orchestral': 1005,
    'Carnival': 1006,
  };

  final List<String> ticketTypes = ['Normal', 'VIP', 'Special', 'Other'];

  String? selectedCategory;
  String? eventName;
  String? eventVenue;
  String? eventManagerName;
  double? normalTicketPrice;
  double? vipTicketPrice;
  double? specialTicketPrice;
  double? otherTicketPrice;
  DateTime? selectedDateTime;
  XFile? policeCertificate;
  XFile? eventPhoto;
  XFile? nicCardImage;
  LatLng? selectedLocation;
  String eventID = Uuid().v4();
  String? imageUrl;

  final eventNameController = TextEditingController();
  final eventVenueController = TextEditingController();
  final eventManagerController = TextEditingController();
  final eventIDController = TextEditingController();
  final imageUrlController =
      TextEditingController(); // New controller for image URL
  Map<String, TextEditingController> ticketPriceControllers = {
    'Normal': TextEditingController(),
    'VIP': TextEditingController(),
    'Special': TextEditingController(),
    'Other': TextEditingController(),
  };

  final ImagePicker picker = ImagePicker();

  @override
  void dispose() {
    eventNameController.dispose();
    eventVenueController.dispose();
    eventManagerController.dispose();
    eventIDController.dispose();
    imageUrlController.dispose(); // Dispose the new controller
    ticketPriceControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _pickImage(bool isPoliceCertificate,
      {bool isNICCard = false}) async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isPoliceCertificate) {
          policeCertificate = pickedFile;
        } else if (isNICCard) {
          nicCardImage = pickedFile;
        } else {
          eventPhoto = pickedFile;
        }
      });
    }
  }

  Future<void> _saveEvent() async {
    setState(() {
      eventName = eventNameController.text;
      eventVenue = eventVenueController.text;
      eventManagerName = eventManagerController.text;
      normalTicketPrice =
          double.tryParse(ticketPriceControllers['Normal']!.text);
      vipTicketPrice = double.tryParse(ticketPriceControllers['VIP']!.text);
      specialTicketPrice =
          double.tryParse(ticketPriceControllers['Special']!.text);
      otherTicketPrice = double.tryParse(ticketPriceControllers['Other']!.text);
      imageUrl =
          imageUrlController.text; // Get the image URL from the controller
    });

    // Create event data map to store in Firestore
    Map<String, dynamic> eventData = {
      'eventName': eventName,
      'eventVenue': eventVenue,
      'eventManagerName': eventManagerName,
      'normalTicketPrice': normalTicketPrice,
      'vipTicketPrice': vipTicketPrice,
      'specialTicketPrice': specialTicketPrice,
      'otherTicketPrice': otherTicketPrice,
      'selectedCategory': selectedCategory,
      'selectedDateTime': selectedDateTime,
      'eventID': eventID,
      'imageUrl': imageUrl, // Save the image URL to Firestore
      'location': selectedLocation != null
          ? {
              'latitude': selectedLocation!.latitude,
              'longitude': selectedLocation!.longitude
            }
          : null,
      'createdAt': Timestamp.now(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventID)
          .set(eventData);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Event saved successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save event: $e")),
      );
    }
  }

  Future<String?> _uploadImage(XFile file, String path) async {
    try {
      // Upload image to Firebase Storage
      Reference storageRef = FirebaseStorage.instance.ref().child(path);
      UploadTask uploadTask = storageRef.putFile(File(file.path));

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl; // Return the download URL for storage
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  // Function to handle location selection from Google Maps
  Future<void> _getLocationFromMap(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LocationPickerPage(),
      ),
    );

    if (result != null) {
      setState(() {
        selectedLocation = result;
        eventVenueController.text =
            'Lat: ${selectedLocation!.latitude}, Long: ${selectedLocation!.longitude}';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    eventIDController.text = eventID; // Initialize the event ID field
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff121212),
      appBar: AppBar(
        title: Text(
          "Add Your Event Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xffF79C14),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event ID (Read-only)
              Text("Event ID",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 8),
              TextField(
                controller: eventIDController..text = eventID,
                style: TextStyle(color: Colors.white),
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Event ID will be generated automatically',
                  hintStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(height: 16),

              // Event Category
              Text("Event Category",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                hint: Text('Select Category',
                    style: TextStyle(color: Colors.white70)),
                dropdownColor: Color(0xff1f1f1f),
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
                items: eventCategories.map((category) {
                  return DropdownMenuItem(
                      value: category,
                      child: Text(
                          '$category (Code: ${eventCategoryCodes[category]})'));
                }).toList(),
              ),
              SizedBox(height: 16),

              // Event Name
              Text("Event Name",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 8),
              TextField(
                controller: eventNameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter event name',
                  hintStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(height: 16),

              // Event Venue
              Text("Event Venue",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: eventVenueController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter event venue',
                        hintStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.location_on, color: Colors.white),
                    onPressed: () => _getLocationFromMap(context),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Event Date and Time
              Text("Event Date & Time",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDateTime(context),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDateTime != null
                            ? DateFormat('yyyy-MM-dd , hh:mm a')
                                .format(selectedDateTime!)
                            : 'Select Date & Time',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      Icon(Icons.calendar_today, color: Colors.white70),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Event Manager Name
              Text("Event Manager Name",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 8),
              TextField(
                controller: eventManagerController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter manager name',
                  hintStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(height: 16),

              // Ticket Prices
              Text("Event Ticket Price",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 8),
              Column(
                children: ticketTypes.map((type) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: TextField(
                      controller: ticketPriceControllers[type],
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter $type ticket price',
                        hintStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),

              // Image URL
              Text("Image URL",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 8),
              TextField(
                controller: imageUrlController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter image URL',
                  hintStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(height: 16),

              // Police Certificate
              Text("Police Certificate",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 8),
              Row(
                children: [
                  policeCertificate != null
                      ? Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: FileImage(File(policeCertificate!.path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.image,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                  SizedBox(width: 30),
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: () => _pickImage(true),
                    child: Text(
                      "Upload Police Certificate",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Event Photo
              Text("Event Photo",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 8),
              Row(
                children: [
                  eventPhoto != null
                      ? Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: FileImage(File(eventPhoto!.path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.image,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                  SizedBox(width: 30),
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: () => _pickImage(false),
                    child: Text(
                      "Upload Event Photo",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // NIC Card Image
              Text("NIC Card Image",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 8),
              Row(
                children: [
                  nicCardImage != null
                      ? Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: FileImage(File(nicCardImage!.path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.image,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                  SizedBox(width: 30),
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: () => _pickImage(false, isNICCard: true),
                    child: Text(
                      "Upload NIC Card Image",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 26),

              // Save Button
              Center(
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: _saveEvent,
                  child: Text(
                    "Save Event",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 26),
            ],
          ),
        ),
      ),
    );
  }
}
