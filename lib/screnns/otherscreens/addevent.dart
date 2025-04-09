<<<<<<< HEAD
=======
// ignore_for_file: camel_case_types, sort_child_properties_last, use_build_context_synchronously, library_private_types_in_public_api, prefer_final_fields, use_key_in_widget_constructors, unused_import, depend_on_referenced_packages, unused_element, avoid_print
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
import 'dart:io';
import 'package:eventory/services/locationpicker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:eventory/navigators/bottomnavigatorbar.dart';
<<<<<<< HEAD
import 'package:flutter/services.dart';
=======
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
<<<<<<< HEAD
import 'package:google_fonts/google_fonts.dart';
import 'package:eventory/helpers/theme_helper.dart';

class addevent extends StatefulWidget {
  final String uid;
  const addevent({super.key, required this.uid});

  @override
  State<addevent> createState() => _AddEventState();
}

class _AddEventState extends State<addevent> with SingleTickerProviderStateMixin {
=======

class addevent extends StatefulWidget {
  const addevent({super.key});

  @override
  State<addevent> createState() => _addeventState();
}

class _addeventState extends State<addevent> {
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
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
<<<<<<< HEAD
  final Uuid _uuid = Uuid();
  final FirebaseStorage _storage = FirebaseStorage.instance;
=======
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f

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
<<<<<<< HEAD
  String eventID = "E1000000000";
  bool _isSaving = false;
=======
  String eventID = "E1000000000"; // Default starting event ID
  bool _isSaving = false; // Track saving state
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f

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
<<<<<<< HEAD
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
=======
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _fetchLastEventID();
    _animationController.forward();
=======
    _fetchLastEventID(); // Fetch the last event ID when the widget initializes
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
  }

  @override
  void dispose() {
<<<<<<< HEAD
    _animationController.dispose();
=======
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
    eventNameController.dispose();
    eventVenueController.dispose();
    eventManagerController.dispose();
    eventIDController.dispose();
    ticketPriceControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

<<<<<<< HEAD
=======
  // Fetch the last event ID from Firestore
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
  Future<void> _fetchLastEventID() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('events')
          .orderBy('eventID', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        String lastEventID = snapshot.docs.first['eventID'];
<<<<<<< HEAD
        int numericPart = int.parse(lastEventID.substring(1));
        setState(() {
          eventID = "E${numericPart + 1}";
          eventIDController.text = eventID;
        });
      } else {
        setState(() {
          eventID = "E${_uuid.v4().substring(0, 8)}";
=======
        // Extract the numeric part of the ID and increment it
        int numericPart = int.parse(lastEventID.substring(1));
        setState(() {
          eventID = "E${numericPart + 1}"; // Increment and update eventID
          eventIDController.text = eventID; // Update the text field
        });
      } else {
        // If no events exist, start with the default ID
        setState(() {
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
          eventIDController.text = eventID;
        });
      }
    } catch (e) {
      print("Error fetching last event ID: $e");
<<<<<<< HEAD
      setState(() {
        eventID = "E${_uuid.v4().substring(0, 8)}";
        eventIDController.text = eventID;
      });
=======
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
<<<<<<< HEAD
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.orangePrimary,
              onPrimary: Colors.white,
              onSurface: AppColors.textColor(context)!,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.orangePrimary,
              ),
            ),
          ),
          child: child!,
        );
      },
=======
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
<<<<<<< HEAD
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.orangePrimary,
                onPrimary: Colors.white,
                onSurface: AppColors.textColor(context)!,
              ),
            ),
            child: child!,
          );
        },
=======
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
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
<<<<<<< HEAD
    await picker.pickImage(source: ImageSource.gallery);
=======
        await picker.pickImage(source: ImageSource.gallery);
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
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

<<<<<<< HEAD
  Future<String?> _uploadToFirebaseStorage(XFile file, String path) async {
    try {
      final Reference storageReference = _storage.ref().child(path);
      final UploadTask uploadTask = storageReference.putFile(File(file.path));
      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading to Firebase Storage: $e");
      return null;
    }
  }

  Future<Map<String, String>?> _uploadImageToCloudinary(XFile file) async {
    try {
      final uri =
      Uri.parse('https://api.cloudinary.com/v1_1/dfnzttf4v/image/upload');
=======
  Future<Map<String, String>?> _uploadImageToCloudinary(XFile file) async {
    try {
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
      } else {
        print("Failed to upload image to Cloudinary: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error uploading image to Cloudinary: $e");
      return null;
    }
  }

<<<<<<< HEAD
  Future<String?> _getAddressFromLatLng(LatLng position) async {
    try {
      final List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        return '${place.street}, ${place.locality}, ${place.country}';
      }
    } catch (e) {
      print("Error getting address from coordinates: $e");
    }
    return null;
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSaving = true;
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

        if (selectedCategory == null) {
          throw Exception("Please select a category");
        }

        if (selectedDateTime == null) {
          throw Exception("Please select date and time");
        }

        String? venueAddress = eventVenue;
        if (selectedLocation != null) {
          venueAddress = await _getAddressFromLatLng(selectedLocation!);
        }

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

        Map<String, dynamic> eventData = {
          'eventName': eventName,
          'eventVenue': venueAddress ?? eventVenue,
          'eventManagerName': eventManagerName,
          'normalTicketPrice': normalTicketPrice,
          'vipTicketPrice': vipTicketPrice,
          'specialTicketPrice': specialTicketPrice,
          'otherTicketPrice': otherTicketPrice,
          'selectedCategory': selectedCategory,
          'selectedDateTime': selectedDateTime,
          'eventID': eventID,
          'userId': widget.uid, // Access the userId directly from widget
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
          'imageUrl': eventPhotoData?['url'],
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
          'condi': 'no',
        };

        await FirebaseFirestore.instance
            .collection('events')
            .doc(eventID)
            .set(eventData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Event saved successfully!"),
            backgroundColor: AppColors.orangePrimary,
          ),
        );

        _clearForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save event: $e"),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _clearForm() {
    setState(() {
      eventNameController.clear();
      eventVenueController.clear();
      eventManagerController.clear();
      ticketPriceControllers.forEach((_, controller) => controller.clear());
      selectedCategory = null;
      selectedDateTime = null;
      policeCertificate = null;
      eventPhoto = null;
      nicCardImageFront = null;
      nicCardImageBack = null;
      selectedLocation = null;
      _fetchLastEventID();
    });
  }

=======
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
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
  Future<void> _getLocationFromMap(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LocationPickerPage(),
      ),
    );

    if (result != null) {
      setState(() {
        selectedLocation = result;
<<<<<<< HEAD
        _getAddressFromLatLng(result).then((address) {
          if (address != null) {
            eventVenueController.text = address;
          } else {
            eventVenueController.text =
            'Lat: ${result.latitude}, Long: ${result.longitude}';
          }
        });
=======
        eventVenueController.text =
            'Lat: ${selectedLocation!.latitude}, Long: ${selectedLocation!.longitude}';
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
      });
    }
  }

<<<<<<< HEAD
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.orangePrimary,
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool isRequired = true}) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.poppins(
        color: AppColors.textColor(context),
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Theme.of(context).hintColor,
        ),
        prefixIcon: Icon(
          icon,
          color: AppColors.orangePrimary,
        ),
        filled: true,
        fillColor: AppColors.cardColor(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      validator: isRequired
          ? (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      }
          : null,
    );
  }

  Widget _buildDropdown(String title, String? value, List<String> items,
      Function(String?) onChanged, {bool isRequired = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(
            'Select $title',
            style: GoogleFonts.poppins(
              color: Theme.of(context).hintColor,
            ),
          ),
          dropdownColor: AppColors.cardColor(context),
          style: GoogleFonts.poppins(
            color: AppColors.textColor(context),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.cardColor(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          onChanged: onChanged,
          validator: isRequired
              ? (value) {
            if (value == null || value.isEmpty) {
              return 'Please select $title';
            }
            return null;
          }
              : null,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                title == 'Category'
                    ? '$item (Code: ${eventCategoryCodes[item]})'
                    : item,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildImageUploadRow(
      String title, XFile? image, Function() onPressed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.cardColor(context),
              ),
              child: image != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(image.path),
                  fit: BoxFit.cover,
                ),
              )
                  : Icon(
                Icons.image,
                size: 40,
                color: Theme.of(context).hintColor,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orangePrimary,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Upload $title',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Event Date & Time'),
        GestureDetector(
          onTap: () => _selectDateTime(context),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.cardColor(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDateTime != null
                      ? DateFormat('yyyy-MM-dd , hh:mm a')
                      .format(selectedDateTime!)
                      : 'Select Date & Time',
                  style: GoogleFonts.poppins(
                    color: selectedDateTime != null
                        ? AppColors.textColor(context)
                        : Theme.of(context).hintColor,
                    fontSize: 16,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: AppColors.orangePrimary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveEvent,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orangePrimary,
          padding: EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          shadowColor: AppColors.orangePrimary.withOpacity(0.3),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Center(
            child: _isSaving
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(width: 10),
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
              'SAVE EVENT',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground(context),
      appBar: AppBar(
        systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        title: Text(
          'Add Event',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor(context),
          ),
        ),
        backgroundColor: AppColors.cardColor(context),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.orangePrimary),
      ),
      bottomNavigationBar: const BottomNavigatorBar(currentIndex: 0, userId: '',),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event ID (Read-only)
                _buildSectionTitle('Event ID'),
                TextField(
                  controller: eventIDController..text = eventID,
                  style: GoogleFonts.poppins(
                    color: AppColors.textColor(context),
                  ),
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Event ID will be generated automatically',
                    hintStyle: GoogleFonts.poppins(
                      color: Theme.of(context).hintColor,
                    ),
                    filled: true,
                    fillColor: AppColors.cardColor(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                  ),
                ),
                SizedBox(height: 16),

                // Event Category
                _buildDropdown(
                  'Category',
                  selectedCategory,
                  eventCategories,
                      (value) => setState(() => selectedCategory = value),
                ),
                SizedBox(height: 16),

                // Event Name
                _buildSectionTitle('Event Name'),
                _buildTextField(eventNameController, 'Event Name', Icons.event),
                SizedBox(height: 16),

                // Event Venue
                _buildSectionTitle('Event Venue'),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                          eventVenueController, 'Event Venue', Icons.location_city),
                    ),
                    IconButton(
                      icon: Icon(Icons.map, size: 28),
                      color: AppColors.orangePrimary,
                      onPressed: () => _getLocationFromMap(context),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Event Date & Time
                _buildDateTimePicker(),
                SizedBox(height: 16),

                // Event Manager Name
                _buildSectionTitle('Event Manager'),
                _buildTextField(
                    eventManagerController, 'Manager Name', Icons.person),
                SizedBox(height: 16),

                // Ticket Prices
                _buildSectionTitle('Ticket Prices'),
                Column(
                  children: ticketTypes.map((type) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: _buildTextField(
                        ticketPriceControllers[type]!,
                        '$type Ticket Price',
                        Icons.confirmation_number,
                        isRequired: false,
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),

                // Police Certificate
                _buildImageUploadRow(
                  'Police Certificate',
                  policeCertificate,
                      () => _pickImage(true),
                ),
                SizedBox(height: 16),

                // Event Photo
                _buildImageUploadRow(
                  'Event Photo',
                  eventPhoto,
                      () => _pickImage(false),
                ),
                SizedBox(height: 16),

                // NIC Card Front
                _buildImageUploadRow(
                  'NIC Front',
                  nicCardImageFront,
                      () => _pickImage(false, isNICCardFront: true),
                ),
                SizedBox(height: 16),

                // NIC Card Back
                _buildImageUploadRow(
                  'NIC Back',
                  nicCardImageBack,
                      () => _pickImage(false, isNICCardBack: true),
                ),
                SizedBox(height: 16),

                // Save Button
                _buildSaveButton(),
              ],
            ),
=======
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
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
          ),
        ),
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
