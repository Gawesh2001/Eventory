import 'dart:io';
import 'package:eventory/services/locationpicker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:eventory/navigators/bottomnavigatorbar.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:eventory/helpers/theme_helper.dart';

class addevent extends StatefulWidget {
  final String uid;
  const addevent({super.key, required this.uid});

  @override
  State<addevent> createState() => _AddEventState();
}

class _AddEventState extends State<addevent>
    with SingleTickerProviderStateMixin {
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
  final Uuid _uuid = Uuid();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? selectedCategory;
  String? eventName;
  String? eventVenue;
  String? eventManagerName;
  double? normalTicketPrice;
  double? vipTicketPrice;
  double? specialTicketPrice;
  double? otherTicketPrice;
  int? normalTicketCount;
  int? vipTicketCount;
  int? specialTicketCount;
  int? otherTicketCount;
  DateTime? selectedDateTime;
  XFile? policeCertificate;
  XFile? eventPhoto;
  XFile? nicCardImageFront;
  XFile? nicCardImageBack;
  LatLng? selectedLocation;
  String eventID = "E1000000000";
  bool _isSaving = false;

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
  Map<String, TextEditingController> ticketCountControllers = {
    'Normal': TextEditingController(),
    'VIP': TextEditingController(),
    'Special': TextEditingController(),
    'Other': TextEditingController(),
  };

  final ImagePicker picker = ImagePicker();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    eventNameController.dispose();
    eventVenueController.dispose();
    eventManagerController.dispose();
    eventIDController.dispose();
    ticketPriceControllers.forEach((_, controller) => controller.dispose());
    ticketCountControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _fetchLastEventID() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('events')
          .orderBy('eventID', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        String lastEventID = snapshot.docs.first['eventID'];
        int numericPart = int.parse(lastEventID.substring(1));
        setState(() {
          eventID = "E${numericPart + 1}";
          eventIDController.text = eventID;
        });
      } else {
        setState(() {
          eventID = "E${_uuid.v4().substring(0, 8)}";
          eventIDController.text = eventID;
        });
      }
    } catch (e) {
      print("Error fetching last event ID: $e");
      setState(() {
        eventID = "E${_uuid.v4().substring(0, 8)}";
        eventIDController.text = eventID;
      });
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
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
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
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
          normalTicketCount =
              int.tryParse(ticketCountControllers['Normal']!.text);
          vipTicketCount = int.tryParse(ticketCountControllers['VIP']!.text);
          specialTicketCount =
              int.tryParse(ticketCountControllers['Special']!.text);
          otherTicketCount =
              int.tryParse(ticketCountControllers['Other']!.text);
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
          'normalTicketCount': normalTicketCount,
          'vipTicketCount': vipTicketCount,
          'specialTicketCount': specialTicketCount,
          'otherTicketCount': otherTicketCount,
          'selectedCategory': selectedCategory,
          'selectedDateTime': selectedDateTime,
          'eventID': eventID,
          'userId': widget.uid,
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
          'availableTickets': {
            'Normal': normalTicketCount ?? 0,
            'VIP': vipTicketCount ?? 0,
            'Special': specialTicketCount ?? 0,
            'Other': otherTicketCount ?? 0,
          },
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
      ticketCountControllers.forEach((_, controller) => controller.clear());
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

  Future<void> _getLocationFromMap(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LocationPickerPage(),
      ),
    );

    if (result != null) {
      setState(() {
        selectedLocation = result;
        _getAddressFromLatLng(result).then((address) {
          if (address != null) {
            eventVenueController.text = address;
          } else {
            eventVenueController.text =
                'Lat: ${result.latitude}, Long: ${result.longitude}';
          }
        });
      });
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
          color: AppColors.orangePrimary,
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool isRequired = true,
      TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.poppins(
        color: AppColors.textColor(context),
        fontSize: 16,
      ),
      keyboardType: keyboardType,
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
      Function(String?) onChanged,
      {bool isRequired = true}) {
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

  Widget _buildTicketPriceAndCountRow(String type) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildTextField(
            ticketPriceControllers[type]!,
            '$type Price',
            Icons.attach_money,
            isRequired: false,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: _buildTextField(
            ticketCountControllers[type]!,
            '$type Count',
            Icons.confirmation_number,
            isRequired: false,
            keyboardType: TextInputType.number,
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
      bottomNavigationBar: const BottomNavigatorBar(
        currentIndex: 0,
        userId: '',
      ),
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
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
                      child: _buildTextField(eventVenueController,
                          'Event Venue', Icons.location_city),
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

                // Ticket Prices and Counts
                _buildSectionTitle('Ticket Information'),
                Column(
                  children: ticketTypes.map((type) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: _buildTicketPriceAndCountRow(type),
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
          ),
        ),
      ),
    );
  }
}
