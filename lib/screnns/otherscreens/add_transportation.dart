// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:eventory/screnns/transportation/transportation.dart';

class VehicleRegistration extends StatefulWidget {
  final String uid; // Add uid as a parameter
  const VehicleRegistration({super.key, required this.uid}); // Constructor

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

  String? _selectedVehicleType; // For dropdown selection
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> _generateVehicleId() async {
    // Fetch the last vehicle ID from Firestore
    final querySnapshot = await _firestore
        .collection('vehicles')
        .orderBy('vehicleId', descending: true)
        .limit(1)
        .get();

    int newId = 100000; // Default starting ID

    if (querySnapshot.docs.isNotEmpty) {
      // Extract the last vehicle ID and increment it
      String lastVehicleId = querySnapshot.docs.first['vehicleId'];
      newId = int.parse(lastVehicleId.substring(1)) + 1;
    }

    return 'V$newId'; // Return the new vehicle ID
  }

  Future<void> _registerVehicle() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedVehicleType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a vehicle type!')),
        );
        return;
      }

      // Generate a new vehicle ID
      String vehicleId = await _generateVehicleId();

      // Parse seating capacity to an integer
      int seatingCapacity = int.tryParse(_seatingCapacityController.text) ?? 0;

      // Upload data to Firestore
      await _firestore.collection('vehicles').add({
        'vehicleId': vehicleId,
        'userId': widget.uid, // Include the uid in the document
        'vehicleType': _selectedVehicleType,
        'model': _modelController.text,
        'plateNumber': _plateNumberController.text,
        'vehicleColor': _vehicleColorController.text,
        'seatingCapacity': seatingCapacity,
        'availableSeats':
            seatingCapacity, // Set availableSeats equal to seatingCapacity
        'ownerName': _ownerNameController.text,
        'contactNumber': _contactNumberController.text,
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
      });

      // Navigate to the transportation.dart page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TransportationPage()),
      );
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Display the user ID
              Text(
                'User ID: ${widget.uid}', // Display the uid passed to this page
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 20),
              _buildDropdownField(), // Vehicle Type dropdown
              _buildTextField(_modelController, 'Model'),
              _buildTextField(_plateNumberController, 'Plate Number'),
              _buildTextField(_vehicleColorController, 'Vehicle Color'),
              _buildTextField(_seatingCapacityController, 'Seating Capacity',
                  isNumber: true),
              _buildTextField(_ownerNameController, 'Owner Full Name'),
              _buildTextField(_contactNumberController, 'Contact Number',
                  isNumber: true),
              const SizedBox(height: 20),
              _buildFileUploadButton('Upload Vehicle License (Optional)', true),
              _buildFileUploadButton('Upload Driver License (Optional)', false),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registerVehicle,
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
