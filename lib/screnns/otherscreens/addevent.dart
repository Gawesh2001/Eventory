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
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  XFile? nicCardImageFront;
  XFile? nicCardImageBack;
  LatLng? selectedLocation;
  String eventID = "E1000000000"; // Default starting event ID
  bool _isSaving = false; // Track saving state

  final eventNameController = TextEditingController();
  final eventVenueController = TextEditingController();
  final eventManagerController = TextEditingController();
  final eventIDController = TextEditingController();
  Map<String, TextEditingController> ticketPriceControllers = {
    'Normal': TextEditingController(),
    'VIP': TextEditingController(),
    'Special': TextEditingController(),
    'Other': TextEditingController(),
  };

  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchLastEventID(); // Fetch the last event ID when the widget initializes
  }

  @override
  void dispose() {
    eventNameController.dispose();
    eventVenueController.dispose();
    eventManagerController.dispose();
    eventIDController.dispose();
    ticketPriceControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  // Fetch the last event ID from Firestore
  Future<void> _fetchLastEventID() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('events')
          .orderBy('eventID', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        String lastEventID = snapshot.docs.first['eventID'];
        // Extract the numeric part of the ID and increment it
        int numericPart = int.parse(lastEventID.substring(1));
        setState(() {
          eventID = "E${numericPart + 1}"; // Increment and update eventID
          eventIDController.text = eventID; // Update the text field
        });
      } else {
        // If no events exist, start with the default ID
        setState(() {
          eventIDController.text = eventID;
        });
      }
    } catch (e) {
      print("Error fetching last event ID: $e");
    }
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
      {bool isNICCardFront = false, bool isNICCardBack = false}) async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isPoliceCertificate) {
          policeCertificate = pickedFile;
        } else if (isNICCardFront) {
          nicCardImageFront = pickedFile;
        } else if (isNICCardBack) {
          nicCardImageBack = pickedFile;
        } else {
          eventPhoto = pickedFile;
        }
      });
    }
  }

  Future<Map<String, String>?> _uploadImageToCloudinary(XFile file) async {
    try {
      final uri =
          Uri.parse('https://api.cloudinary.com/v1_1/dfnzttf4v/image/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = 'eventoryuploads'
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseData);
        return {
          'url': jsonResponse['secure_url'],
          'public_id': jsonResponse['public_id'],
        };
      } else {
        print("Failed to upload image to Cloudinary: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error uploading image to Cloudinary: $e");
      return null;
    }
  }

  Future<void> _saveEvent() async {
    setState(() {
      _isSaving = true; // Start loading
    });

    try {
      setState(() {
        eventName = eventNameController.text;
        eventVenue = eventVenueController.text;
        eventManagerName = eventManagerController.text;
        normalTicketPrice =
            double.tryParse(ticketPriceControllers['Normal']!.text);
        vipTicketPrice = double.tryParse(ticketPriceControllers['VIP']!.text);
        specialTicketPrice =
            double.tryParse(ticketPriceControllers['Special']!.text);
        otherTicketPrice =
            double.tryParse(ticketPriceControllers['Other']!.text);
      });

      // Upload images to Cloudinary and get their URLs and public IDs
      Map<String, String>? policeCertificateData;
      Map<String, String>? eventPhotoData;
      Map<String, String>? nicCardImageFrontData;
      Map<String, String>? nicCardImageBackData;

      if (policeCertificate != null) {
        policeCertificateData =
            await _uploadImageToCloudinary(policeCertificate!);
      }
      if (eventPhoto != null) {
        eventPhotoData = await _uploadImageToCloudinary(eventPhoto!);
      }
      if (nicCardImageFront != null) {
        nicCardImageFrontData =
            await _uploadImageToCloudinary(nicCardImageFront!);
      }
      if (nicCardImageBack != null) {
        nicCardImageBackData =
            await _uploadImageToCloudinary(nicCardImageBack!);
      }

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
        'policeCertificate': policeCertificateData != null
            ? {
                'url': policeCertificateData['url'],
                'public_id': policeCertificateData['public_id'],
              }
            : null,
        'eventPhoto': eventPhotoData != null
            ? {
                'url': eventPhotoData['url'],
                'public_id': eventPhotoData['public_id'],
              }
            : null,
        'imageUrl':
            eventPhotoData?['url'], // Add the eventPhoto URL to imageUrl
        'nicCardImageFront': nicCardImageFrontData != null
            ? {
                'url': nicCardImageFrontData['url'],
                'public_id': nicCardImageFrontData['public_id'],
              }
            : null,
        'nicCardImageBack': nicCardImageBackData != null
            ? {
                'url': nicCardImageBackData['url'],
                'public_id': nicCardImageBackData['public_id'],
              }
            : null,
        'location': selectedLocation != null
            ? {
                'latitude': selectedLocation!.latitude,
                'longitude': selectedLocation!.longitude,
              }
            : null,
        'createdAt': Timestamp.now(),
      };

      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventID)
          .set(eventData);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Event saved successfully!")),
      );
    } catch (e) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save event: $e")),
      );
    } finally {
      setState(() {
        _isSaving = false; // Stop loading
      });
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

              // NIC Card Image Front
              Text("NIC Card Image Front",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 8),
              Row(
                children: [
                  nicCardImageFront != null
                      ? Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: FileImage(File(nicCardImageFront!.path)),
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
                    onPressed: () => _pickImage(false, isNICCardFront: true),
                    child: Text(
                      "Upload NIC Card Front",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // NIC Card Image Back
              Text("NIC Card Image Back",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 8),
              Row(
                children: [
                  nicCardImageBack != null
                      ? Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: FileImage(File(nicCardImageBack!.path)),
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
                    onPressed: () => _pickImage(false, isNICCardBack: true),
                    child: Text(
                      "Upload NIC Card Back",
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
                  onPressed: _isSaving
                      ? null
                      : _saveEvent, // Disable button while saving
                  child: _isSaving
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                                color: Colors.white), // Loading indicator
                            SizedBox(width: 10),
                            Text(
                              "Saving...",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          "Save Event",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
