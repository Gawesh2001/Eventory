// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class VehicleRegistration extends StatefulWidget {
  @override
  _VehicleRegistrationState createState() => _VehicleRegistrationState();
}

class _VehicleRegistrationState extends State<VehicleRegistration> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _vehicleTypeController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _plateNumberController = TextEditingController();
  final TextEditingController _vehicleColorController = TextEditingController();

  final TextEditingController _seatingCapacityController =
      TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();

  final TextEditingController _seatingCapacityController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();


  File? _vehicleLicenseFile;
  File? _driverLicenseFile;

  Future<void> _pickFile(bool isVehicleLicense) async {

    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

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

  void _registerVehicle() {
    if (_formKey.currentState!.validate()) {
      if (_vehicleLicenseFile == null || _driverLicenseFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(
              content: Text(
                  'Please upload both Vehicle License and Driver License!')),

          SnackBar(content: Text('Please upload both Vehicle License and Driver License!')),

        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vehicle Registered Successfully! 🚗✅')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text('Vehicle Registration',
            style: TextStyle(color: Colors.orange)),

        title: Text('Vehicle Registration', style: TextStyle(color: Colors.orange)),

        backgroundColor: Color(0xff121212),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Color(0xff121212),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_vehicleTypeController, 'Vehicle Type'),
              _buildTextField(_modelController, 'Model'),
              _buildTextField(_plateNumberController, 'Plate Number'),
              _buildTextField(_vehicleColorController, 'Vehicle Color'),

              _buildTextField(_seatingCapacityController, 'Seating Capacity',
                  isNumber: true),
              _buildTextField(_ownerNameController, 'Owner Full Name'),
              _buildTextField(_contactNumberController, 'Contact Number',
                  isNumber: true),
              SizedBox(height: 20),
              _buildFileUploadButton('Upload Vehicle License', true),
              _buildFileUploadButton('Upload Driver License', false),

              _buildTextField(_seatingCapacityController, 'Seating Capacity', isNumber: true),
              _buildTextField(_ownerNameController, 'Owner Full Name'),
              _buildTextField(_contactNumberController, 'Contact Number', isNumber: true),
              SizedBox(height: 20),

              _buildFileUploadButton('Upload Vehicle License', true),
              _buildFileUploadButton('Upload Driver License', false),


              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registerVehicle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 16),

                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Register Vehicle',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {

                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Register Vehicle', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.orange),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.orangeAccent),
          ),
        ),
        validator: (value) => value!.isEmpty ? '$label is required' : null,
      ),
    );
  }

  Widget _buildFileUploadButton(String label, bool isVehicleLicense) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white, fontSize: 16)),
        SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () => _pickFile(isVehicleLicense),
          icon: Icon(Icons.upload_file, color: Colors.white),
          label: Text('Choose File', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,

            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

          ),
        ),
        if (isVehicleLicense && _vehicleLicenseFile != null)
          Text('File selected: ${_vehicleLicenseFile!.path.split('/').last}',
              style: TextStyle(color: Colors.white70)),
        if (!isVehicleLicense && _driverLicenseFile != null)
          Text('File selected: ${_driverLicenseFile!.path.split('/').last}',
              style: TextStyle(color: Colors.white70)),
        SizedBox(height: 10),
      ],
    );
  }
}
