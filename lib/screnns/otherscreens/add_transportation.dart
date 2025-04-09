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

class VehicleRegistration extends StatefulWidget {
  final String uid;
  const VehicleRegistration({super.key, required this.uid});

  @override
  State<VehicleRegistration> createState() => _VehicleRegistrationState();
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
  bool _isImageUploading = false;

  final List<String> _vehicleTypes = [
    'Car',
    'Van',
    'Bus',
    'Bike',
    'Tuk Tuk',
    'Other'
  ];

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
      }
      return null;
    } catch (e) {
      print("Error uploading image to Cloudinary: $e");
      return null;
    } finally {
      setState(() => _isImageUploading = false);
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
                      _buildConfirmationRow(
                          'Vehicle ID', vehicleData['vehicleId']),
                      _buildConfirmationRow('Model', vehicleData['model']),
                      _buildConfirmationRow('Type', vehicleData['vehicleType']),
                      _buildConfirmationRow(
                          'Plate', vehicleData['plateNumber']),
                      _buildConfirmationRow(
                          'Seats', vehicleData['seatingCapacity'].toString()),
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
                        MaterialPageRoute(
                            builder: (context) =>
                                TransportationPage(userId: widget.uid)),
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

      setState(() => _isUploading = true);

      try {
        final vehiclePhotoData =
            await _uploadImageToCloudinary(_vehicleLicenseFile!);
        final driverLicenseData =
            await _uploadImageToCloudinary(_driverLicenseFile!);

        if (vehiclePhotoData == null || driverLicenseData == null) {
          throw Exception('Failed to upload images');
        }

        String vehicleId = await _generateVehicleId();
        int seatingCapacity =
            int.tryParse(_seatingCapacityController.text) ?? 0;

        Map<String, dynamic> vehicleData = {
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
          'vehicleImage': vehiclePhotoData['url'],
          'Vphoto': {
            'url': vehiclePhotoData['url'],
            'public_id': vehiclePhotoData['public_id'],
          },
          'Dphoto': {
            'url': driverLicenseData['url'],
            'public_id': driverLicenseData['public_id'],
          },
          'createdAt': FieldValue.serverTimestamp(),
          'status': 'pending',
        };

        await _firestore.collection('vehicles').add(vehicleData);
        await _showConfirmationDialog(vehicleData);

        _formKey.currentState!.reset();
        setState(() {
          _selectedVehicleType = null;
          _vehicleLicenseFile = null;
          _driverLicenseFile = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() => _isUploading = false);
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
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          validator: (value) =>
              value == null ? 'Please select a vehicle type' : null,
          hint: Text(
            'Select Vehicle Type',
            style: GoogleFonts.poppins(
              color: Theme.of(context).hintColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadButton(String label, bool isVehicleLicense) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                onPressed: _isImageUploading
                    ? null
                    : () => _pickFile(isVehicleLicense),
                icon: Icon(Icons.upload_file,
                    color: _isImageUploading ? Colors.grey : Colors.white),
                label: Text(
                  _isImageUploading ? 'Uploading...' : 'Choose File',
                  style: TextStyle(
                      color: _isImageUploading ? Colors.grey : Colors.white),
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
                      validator: (value) =>
                          value!.isEmpty ? 'Model is required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _plateNumberController,
                      label: 'Plate Number',
                      icon: Icons.confirmation_number,
                      validator: (value) =>
                          value!.isEmpty ? 'Plate number is required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _vehicleColorController,
                      label: 'Vehicle Color',
                      icon: Icons.color_lens,
                      validator: (value) =>
                          value!.isEmpty ? 'Color is required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _seatingCapacityController,
                      label: 'Seating Capacity',
                      icon: Icons.event_seat,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'Capacity is required';
                        if (int.tryParse(value) == null)
                          return 'Enter a valid number';
                        if (int.parse(value) <= 0)
                          return 'Must be greater than 0';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _ownerNameController,
                      label: 'Owner Full Name',
                      icon: Icons.person,
                      validator: (value) =>
                          value!.isEmpty ? 'Name is required' : null,
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
