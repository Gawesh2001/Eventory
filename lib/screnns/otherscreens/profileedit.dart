// ignore_for_file: unused_field, unused_import

import 'package:flutter/material.dart';
import 'package:eventory/navigators/bottomnavigatorbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

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
          _photoUrl = profileSnapshot['photoURL'];
          _usernameController.text = _username ?? '';
          _contactController.text = _contactNumber ?? '';
          _dateOfBirth = (profileSnapshot['DOB'] != null)
              ? (profileSnapshot['DOB'] as Timestamp).toDate()
              : null;
          _dobController.text = _dateOfBirth != null
              ? '${_dateOfBirth?.toLocal()}'.split(' ')[0]
              : '';
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

  Future<void> _uploadProfileImage(String userId) async {
    if (_profileImage != null) {
      try {
        // Upload image to Firebase Storage
        final ref = _storage.ref().child('profilePictures/$userId.jpg');
        await ref.putFile(_profileImage!);

        // Get the download URL
        String downloadUrl = await ref.getDownloadURL();

        // Update Firestore with the new photoURL
        await FirebaseFirestore.instance
            .collection('userDetails')
            .doc(userId)
            .set(
          {'photoURL': downloadUrl},
          SetOptions(merge: true),
        );

        // Update the _photoUrl to reflect in UI
        setState(() {
          _photoUrl = downloadUrl;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload profile picture: $e')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        try {
          // Upload profile image if selected
          await _uploadProfileImage(userId);

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
                // Profile Picture with Upload Icon
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
