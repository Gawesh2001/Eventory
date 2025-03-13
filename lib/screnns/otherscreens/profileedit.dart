// ignore_for_file: unused_field, unused_import, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:eventory/navigators/bottomnavigatorbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileEdit extends StatefulWidget {
  const ProfileEdit({super.key});

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? _username;
  String? _contactNumber;
  DateTime? _dateOfBirth;
  String? _photoUrl;
  File? _profileImage; // Profile image file

  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _userIdController.text = user.uid;
        _emailController.text = user.email ?? '';
      });

      DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance
          .collection('userDetails')
          .doc(user.uid)
          .get();

      if (profileSnapshot.exists) {
        setState(() {
          _username = profileSnapshot['userName'];
          _contactNumber = profileSnapshot['contactNumber'];

          // Check if dpurl exists in the document before accessing it
          _photoUrl = profileSnapshot.data() != null &&
                  (profileSnapshot.data() as Map<String, dynamic>)
                      .containsKey('dpurl')
              ? profileSnapshot['dpurl']
              : 'https://img.freepik.com/premium-vector/professional-male-avatar-profile-picture-employee-work_1322206-66590.jpg';

          _usernameController.text = _username ?? '';
          _contactController.text = _contactNumber ?? '';
          _dateOfBirth = (profileSnapshot.data() as Map<String, dynamic>)
                      .containsKey('DOB') &&
                  profileSnapshot['DOB'] != null
              ? (profileSnapshot['DOB'] as Timestamp).toDate()
              : null;
          _dobController.text = _dateOfBirth != null
              ? '${_dateOfBirth?.toLocal()}'.split(' ')[0]
              : '';
        });
      } else {
        // If no profile data exists, use the default profile picture
        setState(() {
          _photoUrl =
              'https://img.freepik.com/premium-vector/professional-male-avatar-profile-picture-employee-work_1322206-66590.jpg';
        });
      }
    }
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selectedDate != null) {
      setState(() {
        _dateOfBirth = selectedDate;
        _dobController.text = '${_dateOfBirth?.toLocal()}'.split(' ')[0];
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _deleteProfileImage() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null && _photoUrl != null) {
      try {
        // Delete the image from Cloudinary
        final publicId = _photoUrl!.split('/').last.split('.').first;
        await _deleteImageFromCloudinary(publicId);

        // Remove the dpurl from Firestore
        await FirebaseFirestore.instance
            .collection('userDetails')
            .doc(userId)
            .update({'dpurl': FieldValue.delete()});

        // Update the UI
        setState(() {
          _photoUrl = null;
          _profileImage = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile picture deleted successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete profile picture: $e')),
        );
      }
    }
  }

  Future<void> _uploadProfileImageToCloudinary(File file) async {
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
        return jsonResponse['secure_url'];
      } else {
        throw Exception('Failed to upload image to Cloudinary');
      }
    } catch (e) {
      throw Exception('Error uploading image to Cloudinary: $e');
    }
  }

  Future<void> _deleteImageFromCloudinary(String publicId) async {
    try {
      final uri =
          Uri.parse('https://api.cloudinary.com/v1_1/dfnzttf4v/image/destroy');
      final request = http.MultipartRequest('POST', uri)
        ..fields['public_id'] = publicId
        ..fields['upload_preset'] = 'eventoryuploads';

      final response = await request.send();
      if (response.statusCode != 200) {
        throw Exception('Failed to delete image from Cloudinary');
      }
    } catch (e) {
      throw Exception('Error deleting image from Cloudinary: $e');
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        try {
          // Upload profile image to Cloudinary if selected
          if (_profileImage != null) {
            final imageUrl =
                await _uploadProfileImageToCloudinary(_profileImage!) as String;
            setState(() {
              _photoUrl = imageUrl;
            });

            // Save the image URL to Firestore
            await FirebaseFirestore.instance
                .collection('userDetails')
                .doc(userId)
                .set(
              {
                'dpurl': imageUrl,
              },
              SetOptions(merge: true),
            );
          }

          // Update other user details in Firestore
          await FirebaseFirestore.instance
              .collection('userDetails')
              .doc(userId)
              .set(
            {
              'userId': userId,
              'email': _emailController.text,
              'userName': _username,
              'DOB': _dateOfBirth,
              'contactNumber': _contactNumber,
            },
            SetOptions(merge: true),
          );

          // Show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully!')),
          );
        } catch (e) {
          // Handle errors and show an error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff1E1E2C),
      appBar: AppBar(
        title: Text("Edit Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.orange),
        titleTextStyle: TextStyle(color: Colors.orange, fontSize: 20),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                // Profile Picture with Upload and Delete Icons
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : _photoUrl != null
                                ? NetworkImage(_photoUrl!) as ImageProvider
                                : AssetImage('assets/profile.png'),
                        backgroundColor: Colors.grey[800],
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.orange,
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      if (_photoUrl != null)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _deleteProfileImage,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Account Information",
                  style: TextStyle(
                      color: Colors.orange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                _buildReadOnlyField("User ID", _userIdController),
                SizedBox(height: 10),
                _buildReadOnlyField("Email", _emailController),
                SizedBox(height: 20),
                Text(
                  "Personal Information",
                  style: TextStyle(
                      color: Colors.orange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                _buildEditableField("Username", _usernameController,
                    (value) => _username = value),
                SizedBox(height: 10),
                _buildEditableField("Contact Number", _contactController,
                    (value) => _contactNumber = value),
                SizedBox(height: 10),
                _buildDateField("Date of Birth", _dobController),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      'Save Changes',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigatorBar(),
    );
  }

  Widget _buildReadOnlyField(String label, TextEditingController controller) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildEditableField(
      String label, TextEditingController controller, Function(String) onSave) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Enter $label' : null,
        onSaved: (value) => onSave(value ?? ''),
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return GestureDetector(
      onTap: () => _selectDateOfBirth(context),
      child: AbsorbPointer(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
          ),
          child: TextFormField(
            controller: controller,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Enter $label' : null,
          ),
        ),
      ),
    );
  }
}
