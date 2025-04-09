<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
=======
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
<<<<<<< HEAD
import 'package:google_fonts/google_fonts.dart';

import '../../helpers/theme_helper.dart';

class AddAccommodationPage extends StatefulWidget {
  final String userId;
  const AddAccommodationPage({Key? key, required this.userId}) : super(key: key);
=======

class AddAccommodationPage extends StatefulWidget {
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
  @override
  _AddAccommodationPageState createState() => _AddAccommodationPageState();
}

class _AddAccommodationPageState extends State<AddAccommodationPage> {
<<<<<<< HEAD
  final _formKey = GlobalKey<FormState>();
=======
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController mapLinkController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController socialMediaController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
<<<<<<< HEAD
  final TextEditingController cancellationPolicyController = TextEditingController();
=======
  final TextEditingController cancellationPolicyController =
      TextEditingController();
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f

  bool isEventOffer = false;
  String? selectedEvent;
  List<Map<String, dynamic>> events = [];
  TimeOfDay? checkInTime;
  TimeOfDay? checkOutTime;
  File? _imageFile;
  bool _isLoading = false;

<<<<<<< HEAD
=======
  List<TextEditingController> roomOptions = [];
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
  List<TextEditingController> facilities = [];
  double rating = 0;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
<<<<<<< HEAD
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('events').get();
    setState(() {
      events = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
=======
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('events').get();
    setState(() {
      events = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
    });
  }

  Future<void> _pickImage() async {
<<<<<<< HEAD
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
=======
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<Map<String, String>?> _uploadImageToCloudinary(File file) async {
    try {
<<<<<<< HEAD
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/dfnzttf4v/image/upload');
=======
      final uri =
          Uri.parse('https://api.cloudinary.com/v1_1/dfnzttf4v/image/upload');
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
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
<<<<<<< HEAD
      }
      return null;
=======
      } else {
        print("Failed to upload image to Cloudinary: ${response.statusCode}");
        return null;
      }
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
    } catch (e) {
      print("Error uploading image to Cloudinary: $e");
      return null;
    }
  }

<<<<<<< HEAD
  Future<String> generateAccommodationID() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('accommodations')
        .orderBy('accommodationID', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return "A10000001";

    String lastAccommodationID = snapshot.docs.first['accommodationID'];
    int lastNumber = int.parse(lastAccommodationID.substring(1));
    return "A${(lastNumber + 1).toString().padLeft(8, '0')}";
  }

=======
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
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

<<<<<<< HEAD
  Future<void> _showConfirmationDialog(Map<String, dynamic> accommodationData) async {
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: AppColors.cardColor(context),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 60,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                Text(
                  "Accommodation Added!",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildConfirmationRow('Accommodation ID', accommodationData['accommodationID']),
                      _buildConfirmationRow('Name', accommodationData['name']),
                      _buildConfirmationRow('Location', accommodationData['location']),
                      _buildConfirmationRow('Price', '\$${accommodationData['price']} per night'),
                      _buildConfirmationRow('Rating', accommodationData['rating'].toString()),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context); // Return to previous screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffFF611A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      "DONE",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Color(0xffFF611A),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
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

      setState(() => _isLoading = true);

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
          'userId': widget.userId, // Access the userId directly from widget
        };

        await FirebaseFirestore.instance
            .collection('accommodations')
            .doc(accommodationID)
            .set(accommodationData);

        await _showConfirmationDialog(accommodationData);

        // Clear form
        _formKey.currentState?.reset();
        setState(() {
          rating = 0;
          isEventOffer = false;
          selectedEvent = null;
          facilities.clear();
          _imageFile = null;
          checkInTime = null;
          checkOutTime = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add accommodation: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xffFF611A),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        style: GoogleFonts.poppins(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: Theme.of(context).hintColor,
          ),
          prefixIcon: Icon(
            icon,
            color: Color(0xffFF611A),
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Color(0xffFF611A).withOpacity(0.3),
              width: 1,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        validator: isRequired ? (value) => value!.isEmpty ? '$label is required' : null : null,
      ),
    );
  }

  Widget _buildImageUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Accommodation Image'),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color(0xffFF611A).withOpacity(0.3),
                width: 1,
              ),
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
              children: [
                Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                const SizedBox(height: 8),
                Text('Tap to upload image', style: GoogleFonts.poppins()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Rating'),
        Slider(
          value: rating,
          min: 0,
          max: 5,
          divisions: 50,
          label: rating.toStringAsFixed(1),
          onChanged: (value) => setState(() => rating = value),
          activeColor: Color(0xffFF611A),
          inactiveColor: Color(0xffFF611A).withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay? time, bool isCheckIn) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(label),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Color(0xffFF611A).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                time?.format(context) ?? 'Not selected',
                style: GoogleFonts.poppins(),
              ),
              IconButton(
                icon: Icon(Icons.access_time, color: Color(0xffFF611A)),
                onPressed: () => _selectTime(context, isCheckIn),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFacilitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Facilities'),
        ...facilities.map((controller) => _buildTextField(
          controller,
          'Facility',
          Icons.room_service,
          isRequired: false,
        )),
        ElevatedButton(
          onPressed: _addFacility,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xffFF611A),
          ),
          child: Text('Add Facility', style: GoogleFonts.poppins()),
        ),
      ],
    );
  }

  Widget _buildEventOfferSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: Text('Event Offer', style: GoogleFonts.poppins()),
          value: isEventOffer,
          activeColor: Color(0xffFF611A),
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
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Color(0xffFF611A).withOpacity(0.3),
                  width: 1,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            dropdownColor: Theme.of(context).cardColor,
            style: GoogleFonts.poppins(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            value: selectedEvent,
            items: events.map((event) {
              return DropdownMenuItem<String>(
                value: event['eventID'],
                child: Text(event['eventName']),
              );
            }).toList(),
            onChanged: (value) => setState(() => selectedEvent = value),
            hint: Text(
              'Select Event',
              style: GoogleFonts.poppins(
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xffFF611A),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          shadowColor: Color(0xffFF611A).withOpacity(0.3),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Center(
            child: _isLoading
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  'Saving...',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            )
                : Text(
              'ADD ACCOMMODATION',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
=======
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
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
        title: Text(
          'Add Accommodation',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xffFF611A)),
            const SizedBox(height: 20),
            Text(
              'Saving accommodation...',
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageUpload(),
              const SizedBox(height: 20),
              _buildTextField(nameController, 'Accommodation Name', Icons.home),
              _buildTextField(locationController, 'Location', Icons.location_on),
              _buildTextField(mapLinkController, 'Map Link', Icons.map, isRequired: false),
              _buildRatingSection(),
              _buildTextField(priceController, 'Price (Per Night)', Icons.attach_money),
              _buildTimePicker('Check-in Time', checkInTime, true),
              _buildTimePicker('Check-out Time', checkOutTime, false),
              _buildFacilitiesSection(),
              _buildTextField(websiteController, 'Website', Icons.web, isRequired: false),
              _buildTextField(socialMediaController, 'Social Media', Icons.share, isRequired: false),
              _buildTextField(contactController, 'Contact Number', Icons.phone),
              _buildTextField(emailController, 'Email', Icons.email),
              _buildTextField(cancellationPolicyController, 'Cancellation Policy', Icons.policy, isRequired: false),
              _buildEventOfferSection(),
              _buildSubmitButton(),
            ],
          ),
        ),
=======
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
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
      ),
    );
  }
}
<<<<<<< HEAD

=======
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
