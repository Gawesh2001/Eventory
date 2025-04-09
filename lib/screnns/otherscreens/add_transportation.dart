<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:eventory/helpers/theme_helper.dart';
import 'package:eventory/screnns/transportation/transportation.dart';
=======
// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:eventory/screnns/transportation/transportation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f

class VehicleRegistration extends StatefulWidget {
  final String uid;
  const VehicleRegistration({super.key, required this.uid});

  @override
<<<<<<< HEAD
  State<VehicleRegistration> createState() => _VehicleRegistrationState();
=======
  _VehicleRegistrationState createState() => _VehicleRegistrationState();
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
}

class _VehicleRegistrationState extends State<VehicleRegistration> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _plateNumberController = TextEditingController();
  final TextEditingController _vehicleColorController = TextEditingController();
<<<<<<< HEAD
  final TextEditingController _seatingCapacityController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
=======
  final TextEditingController _seatingCapacityController =
      TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f

  File? _vehicleLicenseFile;
  File? _driverLicenseFile;
  String? _selectedVehicleType;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isUploading = false;
<<<<<<< HEAD
  bool _isImageUploading = false;

  final List<String> _vehicleTypes = ['Car', 'Van', 'Bus', 'Bike', 'Tuk Tuk', 'Other'];

  @override
  void dispose() {
    _modelController.dispose();
    _plateNumberController.dispose();
    _vehicleColorController.dispose();
    _seatingCapacityController.dispose();
    _ownerNameController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }

  Future<Map<String, String>?> _uploadImageToCloudinary(File file) async {
    try {
      setState(() => _isImageUploading = true);
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/dfnzttf4v/image/upload');
=======

  Future<Map<String, String>?> _uploadImageToCloudinary(File file) async {
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
<<<<<<< HEAD
      }
      return null;
    } catch (e) {
      print("Error uploading image to Cloudinary: $e");
      return null;
    } finally {
      setState(() => _isImageUploading = false);
=======
      } else {
        print("Failed to upload image to Cloudinary: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error uploading image to Cloudinary: $e");
      return null;
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
    }
  }

  Future<String> _generateVehicleId() async {
    final querySnapshot = await _firestore
        .collection('vehicles')
        .orderBy('vehicleId', descending: true)
        .limit(1)
        .get();

    int newId = 100000;
    if (querySnapshot.docs.isNotEmpty) {
      String lastVehicleId = querySnapshot.docs.first['vehicleId'];
      newId = int.parse(lastVehicleId.substring(1)) + 1;
    }
    return 'V$newId';
  }

<<<<<<< HEAD
  Future<void> _showConfirmationDialog(Map<String, dynamic> vehicleData) async {
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
                  "Registration Complete!",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor(context),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.scaffoldBackground(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildConfirmationRow('Vehicle ID', vehicleData['vehicleId']),
                      _buildConfirmationRow('Model', vehicleData['model']),
                      _buildConfirmationRow('Type', vehicleData['vehicleType']),
                      _buildConfirmationRow('Plate', vehicleData['plateNumber']),
                      _buildConfirmationRow('Seats', vehicleData['seatingCapacity'].toString()),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => TransportationPage(userId: widget.uid)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orangePrimary,
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
              color: AppColors.textColor(context),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: AppColors.orangePrimary,
            ),
          ),
        ],
      ),
    );
  }

=======
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
  Future<void> _registerVehicle() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedVehicleType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a vehicle type!')),
        );
        return;
      }

      if (_vehicleLicenseFile == null || _driverLicenseFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload both photos!')),
        );
        return;
      }

<<<<<<< HEAD
      setState(() => _isUploading = true);

      try {
        final vehiclePhotoData = await _uploadImageToCloudinary(_vehicleLicenseFile!);
        final driverLicenseData = await _uploadImageToCloudinary(_driverLicenseFile!);

        if (vehiclePhotoData == null || driverLicenseData == null) {
          throw Exception('Failed to upload images');
        }

        String vehicleId = await _generateVehicleId();
        int seatingCapacity = int.tryParse(_seatingCapacityController.text) ?? 0;

        Map<String, dynamic> vehicleData = {
=======
      setState(() {
        _isUploading = true;
      });

      try {
        // Upload vehicle photo to Cloudinary
        final vehiclePhotoData =
            await _uploadImageToCloudinary(_vehicleLicenseFile!);
        if (vehiclePhotoData == null) {
          throw Exception('Failed to upload vehicle photo');
        }

        // Upload driver license to Cloudinary
        final driverLicenseData =
            await _uploadImageToCloudinary(_driverLicenseFile!);
        if (driverLicenseData == null) {
          throw Exception('Failed to upload driver license');
        }

        // Generate a new vehicle ID
        String vehicleId = await _generateVehicleId();

        // Parse seating capacity to an integer
        int seatingCapacity =
            int.tryParse(_seatingCapacityController.text) ?? 0;

        // Upload data to Firestore
        await _firestore.collection('vehicles').add({
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
          'vehicleId': vehicleId,
          'userId': widget.uid,
          'vehicleType': _selectedVehicleType,
          'model': _modelController.text,
          'plateNumber': _plateNumberController.text,
          'vehicleColor': _vehicleColorController.text,
          'seatingCapacity': seatingCapacity,
          'availableSeats': seatingCapacity,
          'ownerName': _ownerNameController.text,
          'contactNumber': _contactNumberController.text,
<<<<<<< HEAD
          'vehicleImage': vehiclePhotoData['url'],
=======
          'vehicleImage': vehiclePhotoData['url'], // New separate column
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
          'Vphoto': {
            'url': vehiclePhotoData['url'],
            'public_id': vehiclePhotoData['public_id'],
          },
          'Dphoto': {
            'url': driverLicenseData['url'],
            'public_id': driverLicenseData['public_id'],
          },
          'createdAt': FieldValue.serverTimestamp(),
<<<<<<< HEAD
          'status': 'pending',
        };

        await _firestore.collection('vehicles').add(vehicleData);
        await _showConfirmationDialog(vehicleData);

=======
          'status': 'pending', // Added status field
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle Registered Successfully! 🚗✅')),
        );

        // Clear the form after submission
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
        _formKey.currentState!.reset();
        setState(() {
          _selectedVehicleType = null;
          _vehicleLicenseFile = null;
          _driverLicenseFile = null;
<<<<<<< HEAD
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() => _isUploading = false);
=======
          _isUploading = false;
        });

        // Navigate to the transportation page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TransportationPage()),
        );
      } catch (e) {
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error registering vehicle: $e')),
        );
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
      }
    }
  }

  Future<void> _pickFile(bool isVehicleLicense) async {
<<<<<<< HEAD
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
=======
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
    if (pickedFile != null) {
      setState(() {
        if (isVehicleLicense) {
          _vehicleLicenseFile = File(pickedFile.path);
        } else {
          _driverLicenseFile = File(pickedFile.path);
        }
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.poppins(
        color: AppColors.textColor(context),
        fontSize: 16,
      ),
      keyboardType: keyboardType,
      validator: validator,
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
          borderSide: BorderSide(
            color: AppColors.orangePrimary.withOpacity(0.3),
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }

  Widget _buildVehicleTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Vehicle Type'),
        DropdownButtonFormField<String>(
          value: _selectedVehicleType,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.cardColor(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.orangePrimary.withOpacity(0.3),
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          dropdownColor: AppColors.cardColor(context),
          style: GoogleFonts.poppins(
            color: AppColors.textColor(context),
          ),
          items: _vehicleTypes.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedVehicleType = value),
          validator: (value) => value == null ? 'Please select a vehicle type' : null,
          hint: Text(
            'Select Vehicle Type',
            style: GoogleFonts.poppins(
              color: Theme.of(context).hintColor,
            ),
          ),
        ),
      ],
=======
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Registration',
            style: TextStyle(color: Colors.orange)),
        backgroundColor: const Color(0xff121212),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: const Color(0xff121212),
      body: _isUploading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.orange),
                  SizedBox(height: 20),
                  Text('Uploading images...',
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Text(
                      'User ID: ${widget.uid}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    _buildDropdownField(),
                    _buildTextField(_modelController, 'Model'),
                    _buildTextField(_plateNumberController, 'Plate Number'),
                    _buildTextField(_vehicleColorController, 'Vehicle Color'),
                    _buildTextField(
                        _seatingCapacityController, 'Seating Capacity',
                        isNumber: true),
                    _buildTextField(_ownerNameController, 'Owner Full Name'),
                    _buildTextField(_contactNumberController, 'Contact Number',
                        isNumber: true),
                    const SizedBox(height: 20),
                    _buildFileUploadButton('Upload Vehicle Photo', true),
                    _buildFileUploadButton('Upload Driver License', false),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isUploading ? null : _registerVehicle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Register Vehicle',
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _selectedVehicleType,
        decoration: InputDecoration(
          labelText: 'Vehicle Type',
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.orange),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.orangeAccent),
          ),
          filled: true,
          fillColor: const Color(0xff1e1e1e),
        ),
        dropdownColor: const Color(0xff1e1e1e),
        style: const TextStyle(color: Colors.white),
        items: const [
          DropdownMenuItem(value: 'Car', child: Text('Car')),
          DropdownMenuItem(value: 'Van', child: Text('Van')),
          DropdownMenuItem(value: 'Bus', child: Text('Bus')),
          DropdownMenuItem(value: 'Bike', child: Text('Bike')),
        ],
        onChanged: (value) {
          setState(() {
            _selectedVehicleType = value;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please select a vehicle type';
          }
          return null;
        },
        isExpanded: true,
        hint: const Text('Select Vehicle Type',
            style: TextStyle(color: Colors.white70)),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.orange),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.orangeAccent),
          ),
          filled: true,
          fillColor: const Color(0xff1e1e1e),
        ),
        validator: (value) => value!.isEmpty ? '$label is required' : null,
      ),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
    );
  }

  Widget _buildFileUploadButton(String label, bool isVehicleLicense) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
<<<<<<< HEAD
        _buildSectionTitle(label),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.orangePrimary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              ElevatedButton.icon(
                onPressed: _isImageUploading ? null : () => _pickFile(isVehicleLicense),
                icon: Icon(Icons.upload_file,
                    color: _isImageUploading ? Colors.grey : Colors.white),
                label: Text(
                  _isImageUploading ? 'Uploading...' : 'Choose File',
                  style: TextStyle(
                      color: _isImageUploading ? Colors.grey : Colors.white
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isImageUploading
                      ? AppColors.orangePrimary.withOpacity(0.5)
                      : AppColors.orangePrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (isVehicleLicense && _vehicleLicenseFile != null)
                Text(
                  'Selected: ${_vehicleLicenseFile!.path.split('/').last}',
                  style: GoogleFonts.poppins(
                    color: AppColors.orangePrimary,
                    fontSize: 12,
                  ),
                ),
              if (!isVehicleLicense && _driverLicenseFile != null)
                Text(
                  'Selected: ${_driverLicenseFile!.path.split('/').last}',
                  style: GoogleFonts.poppins(
                    color: AppColors.orangePrimary,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: ElevatedButton(
        onPressed: _isUploading ? null : _registerVehicle,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orangePrimary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          shadowColor: AppColors.orangePrimary.withOpacity(0.3),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Center(
            child: _isUploading
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  'Registering...',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            )
                : Text(
              'REGISTER VEHICLE',
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
          'Vehicle Registration',
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
      body: _isUploading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.orangePrimary),
            const SizedBox(height: 20),
            Text(
              'Registering your vehicle...',
              style: GoogleFonts.poppins(
                color: AppColors.textColor(context),
              ),
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
              _buildTextField(
                controller: _modelController,
                label: 'Model',
                icon: Icons.directions_car,
                validator: (value) => value!.isEmpty ? 'Model is required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _plateNumberController,
                label: 'Plate Number',
                icon: Icons.confirmation_number,
                validator: (value) => value!.isEmpty ? 'Plate number is required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _vehicleColorController,
                label: 'Vehicle Color',
                icon: Icons.color_lens,
                validator: (value) => value!.isEmpty ? 'Color is required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _seatingCapacityController,
                label: 'Seating Capacity',
                icon: Icons.event_seat,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Capacity is required';
                  if (int.tryParse(value) == null) return 'Enter a valid number';
                  if (int.parse(value) <= 0) return 'Must be greater than 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _ownerNameController,
                label: 'Owner Full Name',
                icon: Icons.person,
                validator: (value) => value!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _contactNumberController,
                label: 'Contact Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value!.isEmpty) return 'Contact number is required';
                  if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                    return 'Enter a valid 10-digit number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildVehicleTypeField(),
              const SizedBox(height: 16),
              _buildFileUploadButton('Vehicle Photo', true),
              const SizedBox(height: 16),
              _buildFileUploadButton('Driver License', false),
              const SizedBox(height: 16),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }
}
=======
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () => _pickFile(isVehicleLicense),
          icon: const Icon(Icons.upload_file, color: Colors.white),
          label:
              const Text('Choose File', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        if (isVehicleLicense && _vehicleLicenseFile != null)
          Text('File selected: ${_vehicleLicenseFile!.path.split('/').last}',
              style: const TextStyle(color: Colors.white70)),
        if (!isVehicleLicense && _driverLicenseFile != null)
          Text('File selected: ${_driverLicenseFile!.path.split('/').last}',
              style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 10),
      ],
    );
  }
}
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
