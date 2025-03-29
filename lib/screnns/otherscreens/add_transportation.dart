// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:eventory/screnns/transportation/transportation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VehicleRegistration extends StatefulWidget {
  final String uid;
  const VehicleRegistration({super.key, required this.uid});

  @override
  _VehicleRegistrationState createState() => _VehicleRegistrationState();
}

class _VehicleRegistrationState extends State<VehicleRegistration> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _plateNumberController = TextEditingController();
  final TextEditingController _vehicleColorController = TextEditingController();
  final TextEditingController _seatingCapacityController =
      TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();

  File? _vehicleLicenseFile;
  File? _driverLicenseFile;
  String? _selectedVehicleType;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isUploading = false;

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
          'vehicleImage': vehiclePhotoData['url'], // New separate column
          'Vphoto': {
            'url': vehiclePhotoData['url'],
            'public_id': vehiclePhotoData['public_id'],
          },
          'Dphoto': {
            'url': driverLicenseData['url'],
            'public_id': driverLicenseData['public_id'],
          },
          'createdAt': FieldValue.serverTimestamp(),
          'status': 'pending', // Added status field
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle Registered Successfully! 🚗✅')),
        );

        // Clear the form after submission
        _formKey.currentState!.reset();
        setState(() {
          _selectedVehicleType = null;
          _vehicleLicenseFile = null;
          _driverLicenseFile = null;
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
      }
    }
  }

  Future<void> _pickFile(bool isVehicleLicense) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
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
    );
  }

  Widget _buildFileUploadButton(String label, bool isVehicleLicense) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
