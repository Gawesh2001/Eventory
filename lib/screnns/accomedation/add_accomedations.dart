import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class AddAccommodationPage extends StatefulWidget {
  @override
  _AddAccommodationPageState createState() => _AddAccommodationPageState();
}

class _AddAccommodationPageState extends State<AddAccommodationPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController mapLinkController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController socialMediaController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cancellationPolicyController =
      TextEditingController();

  bool isEventOffer = false;
  String? selectedEvent;
  List<Map<String, dynamic>> events = [];
  TimeOfDay? checkInTime;
  TimeOfDay? checkOutTime;
  File? _imageFile;
  bool _isLoading = false;

  List<TextEditingController> roomOptions = [];
  List<TextEditingController> facilities = [];
  double rating = 0;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('events').get();
    setState(() {
      events = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<Map<String, String>?> _uploadImageToCloudinary(File file) async {
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

  void _addFacility() {
    setState(() {
      facilities.add(TextEditingController());
    });
  }

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
      String? imageUrl;
      if (_imageFile != null) {
        final imageData = await _uploadImageToCloudinary(_imageFile!);
        if (imageData != null) {
          imageUrl = imageData['url'];
        } else {
          throw Exception('Failed to upload image');
        }
      }

      String accommodationID = await generateAccommodationID();

      final accommodationData = {
        'accommodationID': accommodationID,
        'name': nameController.text,
        'location': locationController.text,
        'mapLink': mapLinkController.text,
        'website': websiteController.text,
        'socialMedia': socialMediaController.text,
        'price': double.tryParse(priceController.text) ?? 0.0,
        'contact': contactController.text,
        'email': emailController.text,
        'cancellationPolicy': cancellationPolicyController.text,
        'imageUrl': imageUrl,
        'rating': rating,
        'checkInTime': checkInTime?.format(context),
        'checkOutTime': checkOutTime?.format(context),
        'isEventOffer': isEventOffer,
        'selectedEvent': selectedEvent,
        'facilities': facilities.map((controller) => controller.text).toList(),
        'feedbacks': [],
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('accommodations')
          .doc(accommodationID)
          .set(accommodationData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Accommodation added successfully!')),
      );

      // Clear form
      nameController.clear();
      locationController.clear();
      mapLinkController.clear();
      websiteController.clear();
      socialMediaController.clear();
      priceController.clear();
      contactController.clear();
      emailController.clear();
      cancellationPolicyController.clear();
      setState(() {
        rating = 0;
        isEventOffer = false;
        selectedEvent = null;
        facilities.clear();
        _imageFile = null;
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

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          floatingLabelStyle: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange, width: 2.0),
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Accommodation'),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Upload Section
            const Text('Accommodation Image',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Tap to upload image'),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            buildTextField('Accommodation Name', nameController),
            buildTextField('Location', locationController),
            buildTextField('Map Url (Google Maps Link)', mapLinkController),

            const Text('Rating', style: TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: rating,
              min: 0,
              max: 5,
              divisions: 50,
              label: rating.toStringAsFixed(1),
              onChanged: (value) => setState(() => rating = value),
              thumbColor: Colors.orange,
            ),

            buildTextField('Price (Per Night)', priceController),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Check-in Time:'),
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
                const Text('Check-out Time:'),
                TextButton(
                  onPressed: () => _selectTime(context, false),
                  child: Text(checkOutTime?.format(context) ?? 'Select time'),
                  style: TextButton.styleFrom(foregroundColor: Colors.orange),
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Text('Facilities', style: TextStyle(fontSize: 16)),
            ...facilities
                .map((controller) => buildTextField('Facility', controller))
                .toList(),
            ElevatedButton(
              onPressed: _addFacility,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange[700],
              ),
              child: const Text('Add Facility'),
            ),

            const SizedBox(height: 10),
            buildTextField('Website (Optional)', websiteController),
            buildTextField(
                'Social Media Links (Optional)', socialMediaController),
            buildTextField('Contact Number', contactController),
            buildTextField('Email', emailController),
            buildTextField(
                'Cancellation Policy (Optional)', cancellationPolicyController),

            SwitchListTile(
              title: const Text('Event Offer'),
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
                    borderSide:
                        const BorderSide(color: Colors.orange, width: 2.0),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                value: selectedEvent,
                hint: const Text('Select Event'),
                onChanged: (value) => setState(() => selectedEvent = value),
                items: events.map((event) {
                  return DropdownMenuItem<String>(
                    value: event['eventID'],
                    child: Text(event['eventName']),
                  );
                }).toList(),
              ),

            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Submit'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
